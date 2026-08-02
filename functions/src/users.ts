import { onCall, HttpsError, CallableRequest } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminAuth, getAdminStorage, getDb } from "./lib/admin";
import { getMessaging, Message } from "firebase-admin/messaging";
import { resolveMx } from "dns/promises";

/**
 * @function checkBirthdaysAndCreateAlerts
 * @description Tarea programada (Cron Job) que se ejecuta cada 12 horas.
 * Evalúa los cumpleaños próximos de los amigos del usuario (matchList) y genera notificaciones push.
 * Utiliza un ID determinista (`año`) para la alerta asegurando Idempotencia ante reejecuciones.
 */
export const checkBirthdaysAndCreateAlerts = onSchedule(
  {
    schedule: "every 12 hours",
    timeZone: "UTC",
    timeoutSeconds: 540,
    memory: "1GiB",
    maxInstances: 1,
  },
  async () => {
    const db = getDb();
    const today = new Date();
    logger.info(`Starting birthday check from ${today.toISOString()}`);

    try {
      for (let dayOffset = 0; dayOffset < 5; dayOffset++) {
        const targetDate = new Date(today);
        targetDate.setDate(today.getDate() + dayOffset);

        const targetMonth = targetDate.getUTCMonth() + 1;
        const targetDay = targetDate.getUTCDate();
        const isToday = dayOffset === 0;

        await processBirthdaysForDate(db, targetMonth, targetDay, targetDate, isToday);
      }

      logger.info("Birthday alerts processing completed successfully");
      return;
    } catch (error: unknown) {
      logger.error("Error in checkBirthdaysAndCreateAlerts:", error);
      throw new HttpsError("internal", "Error processing birthday alerts", (error as Error).message);
    }
  }
);

async function processBirthdaysForDate(
  db: FirebaseFirestore.Firestore,
  targetMonth: number,
  targetDay: number,
  targetDate: Date,
  shouldSendNotifications: boolean
): Promise<void> {
  const birthdayUsersSnapshot = await db
    .collection("Users")
    .where("birthMonth", "==", targetMonth)
    .where("birthDay", "==", targetDay)
    .get();

  if (birthdayUsersSnapshot.empty) return;

  const processingPromises = birthdayUsersSnapshot.docs.map(async (birthdayUserDoc) => {
    const birthdayUser = birthdayUserDoc.data();
    const birthdayUserId = birthdayUserDoc.id;

    if (!birthdayUser.matchList || !Array.isArray(birthdayUser.matchList) || birthdayUser.matchList.length === 0) {
      return;
    }

    const filteredMatchList = birthdayUser.matchList.filter((friendId: string) => friendId !== birthdayUserId);
    if (filteredMatchList.length === 0) return;

    await processFriendsForBirthdayUser(db, birthdayUser, birthdayUserId, filteredMatchList, targetDate, shouldSendNotifications);
  });

  await Promise.all(processingPromises);
}

async function processFriendsForBirthdayUser(
  db: FirebaseFirestore.Firestore,
  birthdayUser: FirebaseFirestore.DocumentData,
  birthdayUserId: string,
  matchList: string[],
  targetDate: Date,
  shouldSendNotifications: boolean
): Promise<void> {
  const batch = db.batch();
  const friendsToNotify: Array<{ token: string; friendName: string; friendId: string }> = [];

  const friendsSnapshots = await Promise.all(matchList.map((friendId) => db.collection("Users").doc(friendId).get()));

  for (let i = 0; i < matchList.length; i++) {
    const friendId = matchList[i];
    const friendDoc = friendsSnapshots[i];
    if (!friendDoc.exists) continue;

    const friendData = friendDoc.data();
    if (!friendData) continue;

    const existingAlerts: Array<any> = friendData.birthdateAlerts || [];
    const alertExists = existingAlerts.some((alert) => alert.friendId === birthdayUserId);
    if (alertExists) continue;

    const alertDate = new Date(targetDate);
    alertDate.setFullYear(new Date().getFullYear());

    const newAlert = {
      id: `${birthdayUserId}-${alertDate.getFullYear()}`,
      friendId: birthdayUserId,
      friendName: birthdayUser.fullName || `User ${birthdayUserId}`,
      friendProfilePic: birthdayUser.userImg || "",
      targetDate: alertDate,
    };

    const friendRef = db.collection("Users").doc(friendId);
    batch.update(friendRef, {
      birthdateAlerts: FieldValue.arrayUnion(newAlert),
    });

    if (shouldSendNotifications && friendData.fcmToken) {
      friendsToNotify.push({
        token: friendData.fcmToken,
        friendName: friendData.fullName || `User ${friendId}`,
        friendId: friendId,
      });
    }
  }

  if (matchList.length > 0) {
    await batch.commit();
    if (shouldSendNotifications && friendsToNotify.length > 0) {
      await sendBirthdayNotifications(friendsToNotify, birthdayUser.fullName, birthdayUserId, birthdayUser.userImg);
    }
  }
}

async function sendBirthdayNotifications(
  friendsToNotify: Array<{ token: string; friendName: string; friendId: string }>,
  birthdayUserName: string,
  friendId: string,
  friendImage: string
): Promise<void> {
  try {
    const messaging = getMessaging();
    const batchSize = 500;
    for (let i = 0; i < friendsToNotify.length; i += batchSize) {
      const batch = friendsToNotify.slice(i, i + batchSize);
      const messages: Message[] = batch.map((friend) => ({
        token: friend.token,
        notification: {
          title: "🎉 ¡Cumpleaños hoy!",
          body: `${birthdayUserName} está celebrando su cumpleaños hoy. ¡Envíale tus felicitaciones!`,
        },
        data: {
          type: "reminder",
          felicitupId: "",
          chatId: "",
          name: birthdayUserName,
          friendId: friendId,
          userImage: friendImage || "",
        },
      }));

      await messaging.sendEach(messages);
    }
  } catch (error) {
    logger.error("Error sending birthday notifications:", error);
  }
}

/**
 * @function getTemporaryImageUrl
 * @description Obtiene una Signed URL temporal (15 min) para leer una imagen subida al directorio `temp/` de Storage.
 * @param {CallableRequest} request - Payload con `imageName`. Requiere autenticación.
 */
export const getTemporaryImageUrl = onCall(
  {
    timeoutSeconds: 120,
    memory: "512MiB",
    region: "us-central1",
  },
  async (request: CallableRequest) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "El usuario debe estar autenticado para obtener la URL de la imagen temporal.");
    }

    const { imageName } = request.data?.data || request.data || {};
    if (!imageName) {
      throw new HttpsError("invalid-argument", "Se requiere el parámetro 'imageName' en la solicitud.");
    }

    const bucket = getAdminStorage().bucket();
    const [signedUrl] = await bucket.file(`temp/${imageName}`).getSignedUrl({
      action: "read",
      expires: Date.now() + 15 * 60 * 1000,
    });

    return { success: true, url: signedUrl };
  }
);

/**
 * @function disableCurrentUser
 * @description Bloquea la cuenta del usuario autenticado de Firebase Auth y revoca sus refresh tokens.
 * Aplica Autocuración y limpieza de estado eliminando el token FCM y limpiando la sesión activa.
 * @param {CallableRequest} request - Requiere autenticación.
 */
export const disableCurrentUser = onCall(
  {
    timeoutSeconds: 120,
    memory: "512MiB",
    region: "us-central1",
  },
  async (request: CallableRequest) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "El usuario debe estar autenticado para poder bloquear su cuenta.");
    }

    const uid = request.auth.uid;
    try {
      const auth = getAdminAuth();
      await auth.updateUser(uid, { disabled: true });
      await auth.revokeRefreshTokens(uid);

      // Self-Healing & Higiene del Estado: Limpiar tokens y estados activos
      const db = getDb();
      await db.collection("Users").doc(uid).update({
        fcmToken: null,
        currentChat: null,
        isOnline: false,
      });

      logger.info(`Usuario ${uid} deshabilitado exitosamente y datos de sesión limpiados.`);
      return { success: true, message: "Tu cuenta ha sido bloqueada exitosamente." };
    } catch (error: unknown) {
      logger.error("Error al deshabilitar el usuario:", error);
      throw new HttpsError("internal", "Ocurrió un error al intentar bloquear tu cuenta.");
    }
  }
);

/**
 * @function validateEmailDomain
 * @description Valida si el dominio de un correo electrónico tiene registros MX asociados resolviendo el DNS.
 * @param {CallableRequest} request - Payload con `email`.
 */
export const validateEmailDomain = onCall(
  {
    region: "us-central1",
  },
  async (request: CallableRequest) => {
    const { email } = request.data?.data || request.data || {};
    if (!email || typeof email !== "string" || !email.includes("@")) {
      throw new HttpsError("invalid-argument", "El email proporcionado es inválido o no es un string.");
    }

    const domain = email.split("@")[1].toLowerCase();
    try {
      const mxRecords = await resolveMx(domain);
      if (!mxRecords || mxRecords.length === 0) {
        return { valid: false, reason: "NO_MX_RECORDS" };
      }
      return {
        valid: true,
        mx: mxRecords.sort((a, b) => a.priority - b.priority).map((r) => r.exchange),
      };
    } catch (error: any) {
      logger.error(`Error resolviendo MX para ${domain}:`, error);
      if (error.code === "ENODATA" || error.code === "ENOTFOUND") {
        return { valid: false, reason: "DOMAIN_NOT_FOUND" };
      }
      return { valid: false, reason: "DNS_QUERY_FAILED" };
    }
  }
);
