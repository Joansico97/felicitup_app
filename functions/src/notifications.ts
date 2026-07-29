import { onCall, HttpsError, CallableRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import { getAdminApp, getDb } from "./lib/admin";
import { getMessaging, TokenMessage } from "firebase-admin/messaging";

export async function sendPushNotification(payload: TokenMessage): Promise<{ success: boolean; error?: string }> {
  if (!payload.token) {
    logger.warn("Error: User has no push notification token!");
    return { success: false, error: "No token provided" };
  }

  try {
    const messaging = getMessaging(getAdminApp());
    const response = await messaging.send(payload);
    logger.info("Successfully sent message:", response);
    return { success: true };
  } catch (error: unknown) {
    const err = error as { code?: string; message?: string };
    logger.error("Error sending push notification:", err);
    return { success: false, error: err.code || err.message };
  }
}

export const sendNotification = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 300,
    memory: "256MiB",
  },
  async (request: CallableRequest) => {
    try {
      const { userId, title, message, currentChat, dataInfo } = request.data?.data || request.data || {};

      logger.info("Data recibida en sendNotification:", {
        userId,
        title,
        message,
        currentChat,
      });

      if (!userId) {
        throw new HttpsError("invalid-argument", "El ID del usuario es requerido.");
      }

      const db = getDb();
      const userDoc = await db.collection("Users").doc(userId).get();

      if (!userDoc.exists) {
        logger.warn(`Usuario ${userId} no encontrado, omitiendo...`);
        return { success: false, error: `Usuario ${userId} no encontrado` };
      }

      const userData = userDoc.data();
      const token = userData?.fcmToken;

      if (!token) {
        logger.warn(`Usuario ${userId} no tiene FCMToken, omitiendo...`);
        return { success: false, error: `Usuario ${userId} sin FCMToken` };
      }

      if (!currentChat || userData?.currentChat !== currentChat) {
        const payload: TokenMessage = {
          token,
          notification: {
            title: title || "",
            body: message || "",
          },
          data: dataInfo ? Object.fromEntries(Object.entries(dataInfo).map(([k, v]) => [k, String(v)])) : undefined,
        };

        const result = await sendPushNotification(payload);
        if (result.success) {
          return { success: true, message: `Notificación enviada a ${userId}` };
        } else {
          return { success: false, error: `Error enviando a ${userId}: ${result.error}` };
        }
      } else {
        logger.info(`Usuario ${userId} está en el chat actual, omitiendo notificación`);
        return { success: false, error: `Usuario ${userId} está en el chat` };
      }
    } catch (error: unknown) {
      logger.error("Error en sendNotification:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Error al enviar la notificación", error);
    }
  }
);

export const sendNotificationToMultiple = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 300,
    memory: "256MiB",
  },
  async (request: CallableRequest) => {
    try {
      const { userIds, title, message, currentChat, dataInfo } = request.data?.data || request.data || {};

      if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
        throw new HttpsError("invalid-argument", "Se requieren IDs de usuarios válidos.");
      }

      logger.info(`Enviando notificación a ${userIds.length} usuarios`);
      const db = getDb();
      const results = {
        success: 0,
        failed: 0,
        details: [] as Array<{ userId: string; status: string; reason?: string }>,
      };

      for (const userId of userIds) {
        try {
          const userDoc = await db.collection("Users").doc(userId).get();

          if (!userDoc.exists) {
            results.details.push({ userId, status: "failed", reason: "Usuario no encontrado" });
            results.failed++;
            continue;
          }

          const userData = userDoc.data();
          const token = userData?.fcmToken;

          if (!token) {
            results.details.push({ userId, status: "failed", reason: "Sin FCMToken" });
            results.failed++;
            continue;
          }

          if (!currentChat || userData?.currentChat !== currentChat) {
            const payload: TokenMessage = {
              token,
              notification: {
                title: title || "",
                body: message || "",
              },
              data: dataInfo ? Object.fromEntries(Object.entries(dataInfo).map(([k, v]) => [k, String(v)])) : undefined,
            };

            await sendPushNotification(payload);
            results.details.push({ userId, status: "success" });
            results.success++;
          } else {
            results.details.push({ userId, status: "skipped", reason: "En chat actual" });
          }
        } catch (userError: unknown) {
          const err = userError as Error;
          results.details.push({ userId, status: "failed", reason: err.message });
          results.failed++;
        }
      }

      return {
        success: true,
        summary: results,
        message: `Notificaciones enviadas: ${results.success} exitosas, ${results.failed} fallidas`,
      };
    } catch (error: unknown) {
      logger.error("Error en sendNotificationToMultiple:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Error al enviar notificaciones", error);
    }
  }
);
