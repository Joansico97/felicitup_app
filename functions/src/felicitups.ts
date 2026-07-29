import { onCall, HttpsError, CallableRequest } from "firebase-functions/v2/https";
import { onRequest } from "firebase-functions/v2/https";
import { Request, Response } from "express";
import { logger } from "firebase-functions";
import { defineSecret } from "firebase-functions/params";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { getDb } from "./lib/admin";
import { CloudTasksClient } from "@google-cloud/tasks";
import { sendPushNotification } from "./notifications";

const taskQueueSecret = defineSecret("TASK_QUEUE_SECRET");

export async function deleteFelicitupTask(taskName: string): Promise<void> {
  if (!taskName) return;
  try {
    const client = new CloudTasksClient();
    await client.deleteTask({ name: taskName });
    logger.info(`Task deleted: ${taskName}`);
  } catch (err: unknown) {
    const e = err as { code?: number; message?: string };
    if (e.code === 5) {
      logger.info(`Task not found or already deleted: ${taskName}`);
    } else {
      logger.error(`Error deleting task ${taskName}:`, err);
    }
  }
}

export async function completeFelicitup(felicitupId: string): Promise<void> {
  const db = getDb();
  const felicitupRef = db.collection("Felicitups").doc(felicitupId);

  try {
    const felicitupDoc = await felicitupRef.get();
    if (!felicitupDoc.exists) {
      logger.error(`Felicitup ${felicitupId} not found`);
      return;
    }

    const felicitup = felicitupDoc.data();
    if (!felicitup) return;

    const invitedUserDetails: Array<any> = Array.isArray(felicitup.invitedUserDetails)
      ? felicitup.invitedUserDetails
      : [];

    const atLeastOneVideo = invitedUserDetails.some(
      (user) =>
        user &&
        user.videoData &&
        typeof user.videoData.videoUrl === "string" &&
        user.videoData.videoUrl.trim() !== ""
    );

    if (atLeastOneVideo && Array.isArray(felicitup.owner)) {
      const videoMergeJobRef = db.collection("VideoMergeJobs").doc(felicitupId);
      const videoMergeJobDoc = await videoMergeJobRef.get();
      if (videoMergeJobDoc.exists) {
        await videoMergeJobRef.delete();
      }

      await videoMergeJobRef.set({
        userId: felicitup.createdBy,
        status: "pending",
        createdAt: FieldValue.serverTimestamp(),
        videoUrls: invitedUserDetails
          .filter(
            (user) =>
              user &&
              user.videoData &&
              typeof user.videoData.videoUrl === "string" &&
              user.videoData.videoUrl.trim() !== ""
          )
          .map((user) => user.videoData.videoUrl),
      });

      for (const owner of felicitup.owner) {
        if (!owner || !owner.id) continue;
        const ownerDoc = await db.collection("Users").doc(owner.id).get();
        if (!ownerDoc.exists) continue;
        const ownerData = ownerDoc.data();
        if (!ownerData) continue;

        const newElement = {
          assistanceStatus: "accepted",
          id: ownerDoc.id,
          idInformation: "",
          paid: "paid",
          name: ownerData.fullName || `${ownerData.firstName || ""} ${ownerData.lastName || ""}`.trim(),
          userImage: ownerData.userImg || "",
          videoData: { videoUrl: "", videoThumbnail: "" },
        };

        await felicitupRef.update({
          invitedUserDetails: FieldValue.arrayUnion(newElement),
          invitedUsers: FieldValue.arrayUnion(ownerDoc.id),
          sentAt: FieldValue.serverTimestamp(),
          status: "Finished",
        });

        if (ownerData.fcmToken) {
          const payload = {
            token: ownerData.fcmToken,
            notification: {
              title: `Hola, ${ownerData.firstName || "amigo"}`,
              body: "¡Tienes una nueva Felicitup lista para ver!",
            },
            data: {
              type: "past",
              felicitupId: felicitupId,
              chatId: "",
              name: "",
              friendId: "",
              userImage: "",
            },
          };
          try {
            await sendPushNotification(payload);
          } catch (pushErr) {
            logger.error(`Error sending push to ${ownerDoc.id}:`, pushErr);
          }
        }
      }
    } else {
      logger.info(`No video or owner found for Felicitup ${felicitupId}`);
    }
  } catch (error) {
    logger.error(`Error completing Felicitup ${felicitupId}:`, error);
    throw error;
  }
}

export const sendFelicitup = onCall(
  {
    secrets: [taskQueueSecret],
    timeoutSeconds: 120,
    memory: "512MiB",
    region: "us-central1",
  },
  async (request: CallableRequest) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Debes iniciar sesión para enviar una Felicitup");
    }

    const { felicitupId } = request.data?.data || request.data || {};
    if (!felicitupId || typeof felicitupId !== "string") {
      throw new HttpsError("invalid-argument", "El parámetro felicitupId es requerido y debe ser un string");
    }

    try {
      const db = getDb();
      const felicitupRef = db.collection("Felicitups").doc(felicitupId);
      const felicitupDoc = await felicitupRef.get();

      if (!felicitupDoc.exists) {
        throw new HttpsError("not-found", "No se encontró la Felicitup con el ID proporcionado");
      }

      const felicitupData = felicitupDoc.data();
      if (felicitupData?.taskName) {
        await deleteFelicitupTask(felicitupData.taskName);
      }

      if (!felicitupData?.date || typeof felicitupData.date.toDate !== "function") {
        throw new HttpsError("invalid-argument", "La Felicitup no tiene una fecha válida");
      }

      const eventDate: Date = felicitupData.date.toDate();
      const now = new Date();

      if (eventDate <= now) {
        await completeFelicitup(felicitupId);
        return {
          success: true,
          message: "Felicitup completada inmediatamente",
          executedImmediately: true,
        };
      }

      const delaySeconds = Math.max(0, Math.floor((eventDate.getTime() - now.getTime()) / 1000));
      const client = new CloudTasksClient();
      const projectId = process.env.GCLOUD_PROJECT || "felicitup-prod";
      const region = "us-central1";
      const functionUrl = `https://${region}-${projectId}.cloudfunctions.net/executeFelicitupCompletion`;
      const secret = taskQueueSecret.value();

      const parent = client.queuePath(projectId, region, "felicitup-completion-queue");

      const task = {
        httpRequest: {
          httpMethod: "POST" as const,
          url: functionUrl,
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${secret}`,
          },
          body: Buffer.from(JSON.stringify({ felicitupId, userId: request.auth.uid })).toString("base64"),
        },
        scheduleTime: { seconds: Math.floor(Date.now() / 1000) + delaySeconds },
      };

      const [response] = await client.createTask({ parent, task });
      const newTaskName = response?.name;

      await felicitupRef.update({
        scheduledCompletionTime: felicitupData.date,
        lastUpdated: Timestamp.now(),
        scheduledBy: request.auth.uid,
        taskName: newTaskName,
      });

      return {
        success: true,
        scheduledTime: eventDate.toISOString(),
        message: `Felicitup programada para completarse el ${eventDate.toLocaleString()}`,
      };
    } catch (error: unknown) {
      logger.error("Error en sendFelicitup:", error);
      if (error instanceof HttpsError) throw error;
      const err = error as Error;
      throw new HttpsError("internal", "Ocurrió un error al programar la Felicitup", err.message);
    }
  }
);

export const executeFelicitupCompletion = onRequest({ region: "us-central1" }, async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization || "";
    const token = authHeader.replace("Bearer ", "");
    const expected = taskQueueSecret.value();
    if (!expected || token !== expected) {
      logger.error("Unauthorized request - secret mismatch");
      res.status(403).send("Unauthorized");
      return;
    }

    const decodedBody = typeof req.body === "object" ? req.body : JSON.parse(Buffer.from(req.body, "base64").toString());
    const { felicitupId } = decodedBody || {};
    if (!felicitupId) {
      res.status(400).send("Missing felicitupId");
      return;
    }

    await completeFelicitup(felicitupId);
    res.status(200).send("OK");
  } catch (err) {
    logger.error("Error executeFelicitupCompletion:", err);
    res.status(500).send("Error");
  }
});

export const sendManualFelicitup = onCall(async (request: CallableRequest) => {
  try {
    const { felicitupId } = request.data?.data || request.data || {};

    if (!felicitupId) {
      throw new HttpsError("invalid-argument", "El ID de la felicitup es requerido.");
    }

    const db = getDb();
    const docRef = db.collection("Felicitups").doc(felicitupId);
    const felicitupDoc = await docRef.get();

    if (!felicitupDoc.exists) {
      throw new HttpsError("not-found", "Felicitup no encontrada");
    }

    const felicitup = felicitupDoc.data();
    if (!felicitup) return;

    const invitedUserDetails: Array<any> = Array.isArray(felicitup.invitedUserDetails) ? felicitup.invitedUserDetails : [];
    const atLeastOneVideo = invitedUserDetails.some(
      (user) => user && user.videoData && user.videoData.videoUrl && user.videoData.videoUrl.trim() !== ""
    );

    if (atLeastOneVideo && Array.isArray(felicitup.owner)) {
      for (const owner of felicitup.owner) {
        if (!owner || !owner.id) continue;
        const ownerDoc = await db.collection("Users").doc(owner.id).get();
        if (!ownerDoc.exists) continue;
        const ownerData = ownerDoc.data();
        if (!ownerData) continue;

        const ownerToken = ownerData.fcmToken;
        const ownerName = ownerData.firstName || "";
        const ownerFullName = ownerData.fullName || ownerName;

        const newElement = {
          assistanceStatus: "accepted",
          id: ownerDoc.id,
          idInformation: "",
          paid: "paid",
          name: ownerFullName,
          userImage: ownerData.userImg || "",
          videoData: { videoUrl: "", videoThumbnail: "" },
        };

        await docRef.update({
          invitedUserDetails: FieldValue.arrayUnion(newElement),
          invitedUsers: FieldValue.arrayUnion(ownerDoc.id),
          sentAt: FieldValue.serverTimestamp(),
        });

        if (ownerToken) {
          const payload = {
            token: ownerToken,
            data: {
              type: "past",
              felicitupId: felicitupId,
              chatId: "",
              name: ownerName,
              friendId: "",
              userImage: "",
            },
            notification: {
              title: "Hola, " + ownerName,
              body: "¡Tienes una nueva felicitup lista para ser vista!",
            },
          };
          await sendPushNotification(payload);
        }
      }
    }

    await docRef.update({ status: "Finished" });
    if (felicitup.taskName) {
      await deleteFelicitupTask(felicitup.taskName);
    }

    return { success: true };
  } catch (error: unknown) {
    logger.error("Error en sendManualFelicitup:", error);
    if (error instanceof HttpsError) throw error;
    const err = error as Error;
    throw new HttpsError("internal", "Error al ejecutar la tarea.", err.message);
  }
});
