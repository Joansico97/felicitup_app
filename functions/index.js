/* eslint-disable valid-jsdoc */
/* eslint-disable quotes */
/* eslint-disable require-jsdoc */
/* eslint-disable max-len */
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountMergeKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "felicitup-prod.appspot.com",
});

const functions = require("firebase-functions/v2");

const {sendPushNotification} = require("./notifications/notifications");
const {getUserDataById} = require("./users/users");
const {deleteFelicitupTask} = require("./felicitups/send_felicitup_task");
const {getFelicitupById, getFelicitupRefById} = require("./felicitups/felicitups");
const {execFile} = require("child_process");
const {defineSecret} = require('firebase-functions/params');
const {getFirestore, Timestamp} = require('firebase-admin/firestore');
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onCall} = require('firebase-functions/v2/https');
const {HttpsError} = require('firebase-functions/v2/https');
const {getAuth} = require("firebase-admin/auth");

const ffmpeg = require('fluent-ffmpeg');
const ffmpegPath = require('@ffmpeg-installer/ffmpeg').path;
const ffprobePath = require('ffprobe-static').path;


ffmpeg.setFfmpegPath(ffmpegPath);
ffmpeg.setFfprobePath(ffprobePath);

const fs = require("fs");
const os = require("os");
const path = require("path");

const constants = require("./constants/constants");
const {onSchedule} = require("firebase-functions/scheduler");

const bucket = admin.storage().bucket();

const taskQueueSecret = defineSecret('TASK_QUEUE_SECRET');

exports.testFunction = functions.https.onCall(
    {region: "us-central1"},
    async (data, context) => {
      console.log("Data recibida en testFunction:", data);
      return {message: "Datos recibidos correctamente!", data: data};
    },
);

exports.logErrors = functions.https.onCall(
    {
      region: "us-central1",
      timeoutSeconds: 300,
      memory: "256MiB",
    },
    async (data, context) => {
      console.log("Data recibida en sendNotification:", data.data.error);
    },
);

exports.sendNotification = functions.https.onCall(
    {
      region: "us-central1",
      timeoutSeconds: 300,
      memory: "256MiB",
    },
    async (data, context) => {
      try {
        const userId = data.data.userId;
        const title = data.data.title;
        const message = data.data.message;
        const currentChat = data.data.currentChat;
        const dataInfo = data.data.dataInfo;

        console.log("Data recibida en sendNotification:", {
          userId,
          title,
          message,
          currentChat,
        });

        if (!userId) {
          throw new functions.https.HttpsError("invalid-argument", "El ID del usuario es requerido.");
        }

        const db = admin.firestore();
        const userDoc = await db.collection("Users").doc(userId).get();

        if (!userDoc.exists) {
          console.warn(`Usuario ${userId} no encontrado, omitiendo...`);
          return {success: false, error: `Usuario ${userId} no encontrado`};
        }

        const userData = userDoc.data();
        const token = userData.fcmToken;

        if (!token) {
          console.warn(`Usuario ${userId} no tiene FCMToken, omitiendo...`);
          return {success: false, error: `Usuario ${userId} sin FCMToken`};
        }

        if (!currentChat || userData.currentChat !== currentChat) {
          console.log("Enviando notificación a:", userId, "con token:", token);
          const payload = {
            token,
            notification: {
              title: title,
              body: message,
            },
            data: dataInfo,
          };

          try {
            await sendPushNotification(payload);
            console.log(`Notificación enviada exitosamente a ${userId}`);
            return {success: true, message: `Notificación enviada a ${userId}`};
          } catch (notificationError) {
            console.error(`Error enviando notificación a ${userId}:`, notificationError);
            return {success: false, error: `Error enviando a ${userId}: ${notificationError.message}`};
          }
        } else {
          console.log(`Usuario ${userId} está en el chat actual, omitiendo notificación`);
          return {success: false, error: `Usuario ${userId} está en el chat`};
        }
      } catch (error) {
        functions.logger.error("Error en sendNotification:", error, {
          userId: data ? data.userId : undefined,
        });

        if (error instanceof functions.https.HttpsError) {
          throw error;
        }
        throw new functions.https.HttpsError("internal", "Error al enviar la notificación", error);
      }
    },
);

exports.sendNotificationToMultiple = functions.https.onCall(
    {
      region: "us-central1",
      timeoutSeconds: 300,
      memory: "256MiB",
    },
    async (data, context) => {
      try {
        const userIds = data.data.userIds;
        const title = data.data.title;
        const message = data.data.message;
        const currentChat = data.data.currentChat;
        const dataInfo = data.data.dataInfo;

        if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
          throw new functions.https.HttpsError("invalid-argument", "Se requieren IDs de usuarios válidos.");
        }

        console.log(`Enviando notificación a ${userIds.length} usuarios`);

        const db = admin.firestore();
        const results = {
          success: 0,
          failed: 0,
          details: [],
        };


        for (const userId of userIds) {
          try {
            const userDoc = await db.collection("Users").doc(userId).get();

            if (!userDoc.exists) {
              console.warn(`Usuario ${userId} no encontrado, omitiendo...`);
              results.details.push({userId, status: 'failed', reason: 'Usuario no encontrado'});
              results.failed++;
              continue;
            }

            const userData = userDoc.data();
            const token = userData.fcmToken;

            if (!token) {
              console.warn(`Usuario ${userId} no tiene FCMToken, omitiendo...`);
              results.details.push({userId, status: 'failed', reason: 'Sin FCMToken'});
              results.failed++;
              continue;
            }

            if (!currentChat || userData.currentChat !== currentChat) {
              console.log("Enviando notificación a:", userId);
              const payload = {
                token,
                notification: {
                  title: title,
                  body: message,
                },
                data: dataInfo,
              };

              await sendPushNotification(payload);
              results.details.push({userId, status: 'success'});
              results.success++;
            } else {
              console.log(`Usuario ${userId} está en el chat actual, omitiendo...`);
              results.details.push({userId, status: 'skipped', reason: 'En chat actual'});
            }
          } catch (userError) {
            console.error(`Error procesando usuario ${userId}:`, userError);
            results.details.push({userId, status: 'failed', reason: userError.message});
            results.failed++;
          }
        }

        console.log(`Resultado: ${results.success} exitosos, ${results.failed} fallidos`);
        return {
          success: true,
          summary: results,
          message: `Notificaciones enviadas: ${results.success} exitosas, ${results.failed} fallidas`,
        };
      } catch (error) {
        functions.logger.error("Error en sendNotificationToMultiple:", error);
        throw new functions.https.HttpsError("internal", "Error al enviar notificaciones", error);
      }
    },
);

exports.sendFelicitup = onCall(
    {
      secrets: [taskQueueSecret],
      timeoutSeconds: 120,
      memory: '512MiB',
      region: 'us-central1',
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            'unauthenticated',
            'Debes iniciar sesión para enviar una Felicitup',
        );
      }

      console.log('Solicitud recibida', {
        auth: request.auth,
        data: request.data,
      });


      const felicitupId = request.data.felicitupId;

      if (!felicitupId || typeof felicitupId !== 'string') {
        throw new HttpsError(
            'invalid-argument',
            'El parámetro felicitupId es requerido y debe ser un string',
        );
      }

      try {
        const db = getFirestore();

        const felicitupRef = db.collection('Felicitups').doc(felicitupId);
        const felicitupDoc = await felicitupRef.get();

        if (!felicitupDoc.exists) {
          throw new HttpsError(
              'not-found',
              'No se encontró la Felicitup con el ID proporcionado',
          );
        }

        const felicitupData = felicitupDoc.data();
        const eventDate = felicitupData.date.toDate();
        const now = new Date();


        if (eventDate <= now) {
          await completeFelicitup(felicitupId);
          return {
            success: true,
            message: 'Felicitup completada inmediatamente',
            executedImmediately: true,
          };
        }


        const delaySeconds = Math.floor((eventDate - now) / 1000);

        const {CloudTasksClient} = require('@google-cloud/tasks');
        const client = new CloudTasksClient();

        const parent = client.queuePath(
            process.env.GCLOUD_PROJECT,
            'us-central1',
            'felicitup-completion-queue',
        );

        const task = {
          httpRequest: {
            httpMethod: 'POST',
            url: `https://${request.rawRequest.headers.host}/executeFelicitupCompletion`,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${taskQueueSecret.value()}`,
            },
            body: Buffer.from(JSON.stringify({
              felicitupId,
              userId: request.auth.uid,
            })).toString('base64'),
            scheduleTime: {
              seconds: delaySeconds + Math.floor(Date.now() / 1000),
            },
          },
        };

        await client.createTask({parent, task});


        await felicitupRef.update({
          scheduledCompletionTime: felicitupData.date,
          lastUpdated: Timestamp.now(),
          scheduledBy: request.auth.uid,
        });

        console.log(`Felicitup programada para ${eventDate.toISOString()}`);

        return {
          success: true,
          scheduledTime: eventDate.toISOString(),
          message: `Felicitup programada para completarse el ${eventDate.toLocaleString()}`,
        };
      } catch (error) {
        console.error('Error en sendFelicitup:', error);

        if (error instanceof HttpsError) {
          throw error;
        }

        throw new HttpsError(
            'internal',
            'Ocurrió un error al programar la Felicitup',
            error.message,
        );
      }
    },
);

async function completeFelicitup(felicitupId) {
  const db = admin.firestore();
  const felicitupRef = db.collection('Felicitups').doc(felicitupId);

  try {
    const felicitupDoc = await felicitupRef.get();
    if (!felicitupDoc.exists) {
      console.error(`Felicitup ${felicitupId} no encontrada`);
      return;
    }

    const felicitup = felicitupDoc.data();


    const atLeastOneVideo = felicitup.invitedUserDetails.some((user) =>
      user.videoData && user.videoData.videoUrl && user.videoData.videoUrl.trim(),
    );

    if (atLeastOneVideo) {
      for (const owner of felicitup.owner) {
        const ownerData = await getUserDataById(owner.id);

        const newElement = {
          assistanceStatus: "accepted",
          id: ownerData.id,
          idInformation: "",
          paid: "paid",
          name: ownerData.fullName,
          userImage: ownerData.userImg,
          videoData: {videoUrl: "", videoThumbnail: ""},
        };

        await felicitupRef.update({
          invitedUserDetails: admin.firestore.FieldValue.arrayUnion(newElement),
          invitedUsers: admin.firestore.FieldValue.arrayUnion(ownerData.id),
        });


        const payload = {
          token: ownerData.fcmToken,
          notification: {
            title: "Hola, " + ownerData.firstName,
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
        await sendPushNotification(payload);
      }
    }


    await felicitupRef.update({

    });

    console.log(`Felicitup ${felicitupId} completada exitosamente`);
  } catch (error) {
    console.error(`Error al completar la Felicitup ${felicitupId}:`, error);

    throw error;
  }
}

exports.sendManualFelicitup = functions.https.onCall(async (data, context) => {
  try {
    const felicitupId = data.data.felicitupId;

    if (!felicitupId) {
      throw new functions.https.HttpsError("invalid-argument", "El ID de la felicitup es requerido.");
    }

    const felicitup = await getFelicitupById(felicitupId);
    const docRef = await getFelicitupRefById(felicitupId);

    const atLeastOneVideo = felicitup.invitedUserDetails.some((user) => user.videoData && user.videoData.videoUrl && user.videoData.videoUrl.trim() !== "");

    console.log("atLeastOneVideo", atLeastOneVideo);

    if (atLeastOneVideo) {
      for (let index = 0; index < felicitup.owner.length; index++) {
        const owner = felicitup.owner[index];
        const ownerData = await getUserDataById(owner.id);
        const ownerToken = ownerData.fcmToken;
        const ownerName = ownerData.firstName;
        const ownerFullName = ownerData.fullName;
        const status = "accepted";
        const id = ownerData.id;
        const idInformation = "";
        const paid = "paid";
        const userImage = ownerData.userImg;
        const videoUrl = "";

        const subElement = {
          videoUrl: videoUrl,
          videoThumbnail: "",
        };

        const newElement = {
          assistanceStatus: status,
          id: id,
          idInformation: idInformation,
          paid: paid,
          name: ownerFullName,
          userImage: userImage,
          videoData: subElement,
        };

        await docRef.update({
          invitedUserDetails: admin.firestore.FieldValue.arrayUnion(newElement),
          invitedUsers: admin.firestore.FieldValue.arrayUnion(id),
        });

        console.log(`User ${ownerName} added to felicitup ${felicitupId}`);

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
            body: "Tienes una nueva felicitup lista para ser vista!",
          },
        };
        await sendPushNotification(payload);
      }
    }


    await docRef.update({status: "Finished"});
    deleteFelicitupTask(felicitupId);
  } catch (error) {
    console.error("Error al ejecutar la tarea:", error);
    throw new functions.https.HttpsError("internal", "Error al programar la tarea.", error);
  }
});

exports.normalizeSingleVideo = functions.https.onCall({
  region: "us-central1",
  timeoutSeconds: 540,
  memory: "512MiB",
}, async (data, context) => {
  const {videoUrl, userId, felicitupId} = data.data;

  if (!videoUrl || !userId || !felicitupId) {
    throw new functions.https.HttpsError('invalid-argument', 'videoUrl, userId and felicitupId are required');
  }

  try {
    // 3. Obtener el documento de Felicitups
    const felicitupRef = admin.firestore().collection("Felicitups").doc(felicitupId);
    const felicitupDoc = await felicitupRef.get();

    if (!felicitupDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Felicitups document not found');
    }

    const felicitupData = felicitupDoc.data();
    const invitedUserDetails = felicitupData.invitedUserDetails || [];

    // 4. Buscar el usuario específico en invitedUserDetails
    const userIndex = invitedUserDetails.findIndex((user) => user.id === userId);
    console.log('User index found:', userIndex);

    if (userIndex === -1) {
      throw new functions.https.HttpsError('not-found', 'User not found in invitedUserDetails');
    }

    // 5. Actualizar estado a "processing" manteniendo todos los demás datos intactos
    const userToUpdate = invitedUserDetails[userIndex];
    const processingVideoData = {
      ...userToUpdate.videoData, // Mantenemos todos los datos existentes
      processingStatus: "processing", // Solo actualizamos el estado
    };

    const processingUpdateData = {
      invitedUserDetails: invitedUserDetails.map((user, index) =>
        index === userIndex ?
          {...user, videoData: processingVideoData} :
          user,
      ),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await felicitupRef.update(processingUpdateData);
    console.log('Processing status set to "processing" for user:', userId);

    const tempDir = os.tmpdir();
    const tempFilePath = path.join(tempDir, `source-${Date.now()}.mp4`);
    const processedPath = path.join(tempDir, `processed-${Date.now()}.mp4`);

    // Descargar el video
    const file = bucket.file(videoUrl);
    await file.download({destination: tempFilePath});
    console.log('Video downloaded for normalization');

    // Normalizar el video
    await normalizeVideo(tempFilePath, processedPath);
    console.log('Video normalized for user:', userId);

    // Subir el video normalizado
    const normalizedFileName = `normalized-${Date.now()}-${path.basename(videoUrl)}`;
    const destinationPath = `normalized-videos/${userId}/${normalizedFileName}`;

    await bucket.upload(processedPath, {destination: destinationPath});
    console.log('Normalized video uploaded');

    // Obtener URL firmada del video
    const [normalizedVideoUrl] = await bucket.file(destinationPath).getSignedUrl({
      action: 'read',
      expires: '03-01-2500',
    });

    // Generar y subir thumbnail
    let thumbnailUrl = null;
    try {
      const thumbnailFileName = `thumbnail-${Date.now()}.jpg`;
      const thumbnailTempPath = path.join(tempDir, thumbnailFileName);
      const thumbnailDestinationPath = `thumbnails/${userId}/${thumbnailFileName}`;

      await generateThumbnail(processedPath, thumbnailTempPath);
      await bucket.upload(thumbnailTempPath, {destination: thumbnailDestinationPath});

      [thumbnailUrl] = await bucket.file(thumbnailDestinationPath).getSignedUrl({
        action: 'read',
        expires: '03-01-2500',
      });

      console.log('Thumbnail generated and uploaded');

      // Limpiar thumbnail temporal
      if (fs.existsSync(thumbnailTempPath)) {
        fs.unlinkSync(thumbnailTempPath);
      }
    } catch (thumbnailError) {
      console.warn('Thumbnail generation failed:', thumbnailError);
      // Continuamos sin thumbnail si falla
    }

    // 6. Actualizar SOLO el videoData manteniendo todos los demás datos y cambiar estado a "completed"
    const completedVideoData = {
      ...userToUpdate.videoData, // Mantenemos los datos originales
      videoUrl: normalizedVideoUrl, // Actualizamos la URL del video
      ...(thumbnailUrl && {videoThumbnail: thumbnailUrl}), // Actualizamos thumbnail solo si existe
      processingStatus: "completed", // Cambiamos estado a completed
    };

    const updateData = {
      invitedUserDetails: invitedUserDetails.map((user, index) =>
        index === userIndex ?
          {...user, videoData: completedVideoData} :
          user,
      ),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await felicitupRef.update(updateData);

    // Limpiar archivos temporales
    try {
      if (fs.existsSync(tempFilePath)) fs.unlinkSync(tempFilePath);
      if (fs.existsSync(processedPath)) fs.unlinkSync(processedPath);
    } catch (cleanupError) {
      console.warn('Error cleaning temp files:', cleanupError);
    }

    return {
      success: true,
      normalizedVideoUrl: normalizedVideoUrl,
      thumbnailUrl: thumbnailUrl,
      message: 'Video normalized successfully',
    };
  } catch (error) {
    console.error('Error in normalizeSingleVideo:', error);

    // 7. Actualizar estado de error en Firestore
    try {
      const felicitupRef = admin.firestore().collection("Felicitups").doc(felicitupId);
      const felicitupDoc = await felicitupRef.get();

      if (felicitupDoc.exists) {
        const felicitupData = felicitupDoc.data();
        const invitedUserDetails = felicitupData.invitedUserDetails || [];
        const userIndex = invitedUserDetails.findIndex((user) => user.id === userId);

        if (userIndex !== -1) {
          const userToUpdate = invitedUserDetails[userIndex];
          const errorVideoData = {
            ...userToUpdate.videoData, // Mantenemos todos los datos existentes
            processingStatus: "failed", // Solo actualizamos el estado a failed
            error: error.message,
          };

          const errorUpdateData = {
            invitedUserDetails: invitedUserDetails.map((user, index) =>
              index === userIndex ?
                {...user, videoData: errorVideoData} :
                user,
            ),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };

          await felicitupRef.update(errorUpdateData);
        }
      }
    } catch (updateError) {
      console.error('Failed to update Felicitups document with error:', updateError);
    }

    throw new functions.https.HttpsError('internal', 'Video normalization failed', error.message);
  }
});

exports.enqueueVideoProcessing = onCall({
  region: "us-central1",
  timeoutSeconds: 30,
  memory: "256MiB",
}, async (request) => {
  const {videoUrl, userId, felicitupId} = request.data;

  if (!videoUrl || !userId || !felicitupId) {
    throw new functions.https.HttpsError('invalid-argument',
        'videoUrl, userId and felicitupId are required');
  }

  // Crear documento en la cola de procesamiento
  const queueRef = admin.firestore().collection("processingQueue").doc();

  const queueItem = {
    videoUrl,
    userId,
    felicitupId,
    status: "pending",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    attempts: 0,
    maxAttempts: 3,
  };

  await queueRef.set(queueItem);

  // Actualizar estado inicial en Felicitups
  const felicitupRef = admin.firestore().collection("Felicitups").doc(felicitupId);
  const felicitupDoc = await felicitupRef.get();

  if (!felicitupDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Felicitups document not found');
  }

  const felicitupData = felicitupDoc.data();
  const invitedUserDetails = felicitupData.invitedUserDetails || [];
  const userIndex = invitedUserDetails.findIndex((user) => user.id === userId);

  if (userIndex === -1) {
    throw new functions.https.HttpsError('not-found', 'User not found in invitedUserDetails');
  }

  const userToUpdate = invitedUserDetails[userIndex];
  const queuedVideoData = {
    ...userToUpdate.videoData,
    processingStatus: "queued",
    queueId: queueRef.id,
  };

  const updateData = {
    invitedUserDetails: invitedUserDetails.map((user, index) =>
      index === userIndex ? {...user, videoData: queuedVideoData} : user,
    ),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await felicitupRef.update(updateData);

  return {success: true, queueId: queueRef.id, message: "Video enqueued for processing"};
});

// Worker que procesa la cola
exports.processVideoQueue = onDocumentCreated({
  region: "us-central1",
  timeoutSeconds: 540,
  memory: "512MiB",
  document: "processingQueue/{queueId}",
}, async (event) => {
  const queueData = event.data.data();

  // Solo procesar items pendientes
  if (queueData.status !== "pending") {
    return;
  }

  const {videoUrl, userId, felicitupId, attempts, maxAttempts} = queueData;
  const queueRef = event.data.ref;

  try {
    // Marcar como procesando
    await queueRef.update({
      status: "processing",
      startedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Actualizar estado en Felicitups
    const felicitupRef = admin.firestore().collection("Felicitups").doc(felicitupId);
    const felicitupDoc = await felicitupRef.get();

    if (!felicitupDoc.exists) {
      throw new Error('Felicitups document not found');
    }

    const felicitupData = felicitupDoc.data();
    const invitedUserDetails = felicitupData.invitedUserDetails || [];
    const userIndex = invitedUserDetails.findIndex((user) => user.id === userId);

    if (userIndex === -1) {
      throw new Error('User not found in invitedUserDetails');
    }

    const userToUpdate = invitedUserDetails[userIndex];
    const processingVideoData = {
      ...userToUpdate.videoData,
      processingStatus: "processing",
    };

    const processingUpdateData = {
      invitedUserDetails: invitedUserDetails.map((user, index) =>
        index === userIndex ? {...user, videoData: processingVideoData} : user,
      ),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await felicitupRef.update(processingUpdateData);

    // Procesar el video (tu lógica original de normalización)
    const tempDir = os.tmpdir();
    const tempFilePath = path.join(tempDir, `source-${Date.now()}.mp4`);
    const processedPath = path.join(tempDir, `processed-${Date.now()}.mp4`);

    // Descargar el video
    const file = bucket.file(videoUrl);
    await file.download({destination: tempFilePath});

    // Normalizar el video
    await normalizeVideo(tempFilePath, processedPath);

    // Subir el video normalizado
    const normalizedFileName = `normalized-${Date.now()}-${path.basename(videoUrl)}`;
    const destinationPath = `normalized-videos/${userId}/${normalizedFileName}`;
    await bucket.upload(processedPath, {destination: destinationPath});

    const [normalizedVideoUrl] = await bucket.file(destinationPath).getSignedUrl({
      action: 'read',
      expires: '03-01-2500',
    });

    let thumbnailUrl = null;
    try {
      const thumbnailFileName = `thumbnail-${Date.now()}.jpg`;
      const thumbnailTempPath = path.join(tempDir, thumbnailFileName);
      const thumbnailDestinationPath = `thumbnails/${userId}/${thumbnailFileName}`;

      await generateThumbnail(processedPath, thumbnailTempPath);
      await bucket.upload(thumbnailTempPath, {destination: thumbnailDestinationPath});

      [thumbnailUrl] = await bucket.file(thumbnailDestinationPath).getSignedUrl({
        action: 'read',
        expires: '03-01-2500',
      });

      console.log('Thumbnail generated and uploaded');

      // Limpiar thumbnail temporal
      if (fs.existsSync(thumbnailTempPath)) {
        fs.unlinkSync(thumbnailTempPath);
      }
    } catch (thumbnailError) {
      console.warn('Thumbnail generation failed:', thumbnailError);
      // Continuamos sin thumbnail si falla
    }

    // Actualizar estado a completado
    const completedVideoData = {
      ...userToUpdate.videoData,
      videoUrl: normalizedVideoUrl,
      ...(thumbnailUrl && {videoThumbnail: thumbnailUrl}),
      processingStatus: "completed",
    };

    const finalUpdateData = {
      invitedUserDetails: invitedUserDetails.map((user, index) =>
        index === userIndex ? {...user, videoData: completedVideoData} : user,
      ),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await felicitupRef.update(finalUpdateData);

    // Marcar como completado en la cola
    await queueRef.update({
      status: "completed",
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
      normalizedVideoUrl: normalizedVideoUrl,
      thumbnailUrl: thumbnailUrl,
    });

    // Limpiar archivos temporales
    try {
      if (fs.existsSync(tempFilePath)) fs.unlinkSync(tempFilePath);
      if (fs.existsSync(processedPath)) fs.unlinkSync(processedPath);
    } catch (cleanupError) {
      console.warn('Error cleaning temp files:', cleanupError);
    }
  } catch (error) {
    console.error('Error processing video:', error);

    // Manejar reintentos
    const newAttempts = attempts + 1;

    if (newAttempts >= maxAttempts) {
      // Máximo de intentos alcanzado, marcar como fallido
      await queueRef.update({
        status: "failed",
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Actualizar estado de error en Felicitups
      try {
        const felicitupRef = admin.firestore().collection("Felicitups").doc(felicitupId);
        const felicitupDoc = await felicitupRef.get();

        if (felicitupDoc.exists) {
          const felicitupData = felicitupDoc.data();
          const invitedUserDetails = felicitupData.invitedUserDetails || [];
          const userIndex = invitedUserDetails.findIndex((user) => user.id === userId);

          if (userIndex !== -1) {
            const userToUpdate = invitedUserDetails[userIndex];
            const errorVideoData = {
              ...userToUpdate.videoData,
              processingStatus: "failed",
              error: error.message,
            };

            const errorUpdateData = {
              invitedUserDetails: invitedUserDetails.map((user, index) =>
                index === userIndex ? {...user, videoData: errorVideoData} : user,
              ),
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            await felicitupRef.update(errorUpdateData);
          }
        }
      } catch (updateError) {
        console.error('Failed to update error status:', updateError);
      }
    } else {
      // Reintentar
      await queueRef.update({
        status: "pending",
        attempts: newAttempts,
        nextRetry: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
});

exports.processVideoMerge = onDocumentCreated(
    {
      document: "VideoMergeJobs/{felicitupId}",
      timeoutSeconds: 540,
      memory: "2GB",
      maxInstances: 3,
    },
    async (event) => {
      const snap = event.data;
      if (!snap) {
        console.log("No data associated with the event");
        return;
      }

      const jobData = snap.data();
      const {videoUrls, userId} = jobData;
      const {felicitupId} = event.params;

      console.log(`Starting video merge job: ${felicitupId} for user: ${userId}`);

      if (!videoUrls || !Array.isArray(videoUrls) || videoUrls.length === 0) {
        console.error("Invalid video URLs in job:", felicitupId, videoUrls);
        await snap.ref.update({
          status: "failed",
          error: "Invalid video URLs",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return;
      }

      // FUNCIÓN PARA EXTRAER LA RUTA DEL ARCHIVO DESDE URLS FIRMADAS
      const extractFilePathFromUrl = (fullUrl) => {
        try {
          const url = new URL(fullUrl);

          // Para URLs de Google Cloud Storage con signed URLs
          if (url.hostname === 'storage.googleapis.com') {
            // La ruta está después del nombre del bucket
            const pathname = url.pathname;
            const bucketName = 'felicitup-prod.appspot.com'; // Tu nombre de bucket

            // Encontrar la posición del bucket name en el path
            const bucketIndex = pathname.indexOf(bucketName);
            if (bucketIndex !== -1) {
              // Extraer todo después del bucket name + 1 (por el slash)
              const filePath = pathname.substring(bucketIndex + bucketName.length + 1);

              // Decodificar URL encoding (espacios como %20, etc.)
              return decodeURIComponent(filePath.split('?')[0]); // Remover query parameters
            }
          }

          // Si no es una URL de storage.googleapis.com, intentar extraer de otro modo
          const pathSegments = url.pathname.split('/');
          const oIndex = pathSegments.indexOf('o');
          if (oIndex !== -1 && oIndex < pathSegments.length - 1) {
            return decodeURIComponent(pathSegments.slice(oIndex + 1).join('/').split('?')[0]);
          }

          // Si todo falla, devolver la última parte del path
          return decodeURIComponent(pathSegments.pop().split('?')[0]);
        } catch (error) {
          console.warn('Error parsing URL, using as-is:', fullUrl);
          return fullUrl; // Devolver original si hay error
        }
      };

      // EXTRAER RUTAS DE ARCHIVOS DE LAS URLs
      const filePaths = videoUrls
          .filter((url) => url && typeof url === 'string' && url.trim() !== '')
          .map(extractFilePathFromUrl)
          .filter((path) => path && path.trim() !== '');

      if (filePaths.length === 0) {
        console.error("No valid file paths found after processing URLs:", videoUrls);
        await snap.ref.update({
          status: "failed",
          error: "No valid file paths found",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return;
      }

      console.log(`Found ${filePaths.length} valid file paths out of ${videoUrls.length} URLs`);

      await snap.ref.update({
        status: "processing",
        startedAt: admin.firestore.FieldValue.serverTimestamp(),
        totalVideos: filePaths.length,
        processedVideos: 0,
      });

      const tempDir = os.tmpdir();
      const outputFileName = `merged-${Date.now()}.mp4`;
      const outputFilePath = path.join(tempDir, outputFileName);
      const tempFiles = [];

      try {
        console.log(`Downloading ${filePaths.length} pre-normalized videos`);

        const concurrencyLimit = 6;
        const snapRef = snap;

        const downloadVideo = async (filePath, index) => {
          if (!filePath || typeof filePath !== 'string' || filePath.trim() === '') {
            console.error(`Invalid file path at index ${index}:`, filePath);
            throw new Error(`Invalid file path at index ${index}`);
          }

          const tempFilePath = path.join(tempDir, `source-${index}-${Date.now()}.mp4`);

          console.log(`Downloading video ${index + 1}/${filePaths.length}: ${filePath}`);

          try {
            const file = bucket.file(filePath); // ← Ahora usa la ruta del archivo, no la URL
            await file.download({destination: tempFilePath});
            console.log(`Downloaded video ${index + 1}`);

            tempFiles.push(tempFilePath);

            if ((index + 1) % concurrencyLimit === 0 || (index + 1) === filePaths.length) {
              await snapRef.ref.update({
                processedVideos: index + 1,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              });
            }
          } catch (downloadError) {
            console.error(`Error downloading video ${index + 1}:`, downloadError);
            throw new Error(`Failed to download video ${index + 1}: ${downloadError.message}`);
          }
        };

        const downloadVideoBatch = async (paths, startIndex) => {
          const promises = paths.map((path, idx) =>
            downloadVideo(path, startIndex + idx),
          );
          return Promise.all(promises);
        };

        // USAR filePaths EN LUGAR DE videoUrls
        for (let i = 0; i < filePaths.length; i += concurrencyLimit) {
          const chunk = filePaths.slice(i, i + concurrencyLimit);
          await downloadVideoBatch(chunk, i);
        }

        if (tempFiles.length === 0) {
          throw new Error("No videos were successfully downloaded");
        }

        console.log("All videos downloaded, starting concatenation...");
        await concatVideos(tempFiles, outputFilePath);
        console.log("Videos concatenated successfully");

        const destinationPath = `videos/${felicitupId}/${outputFileName}`;
        await bucket.upload(outputFilePath, {destination: destinationPath});
        console.log("Merged video uploaded");

        const [finalVideoUrl] = await bucket.file(destinationPath).getSignedUrl({
          action: "read",
          expires: "03-01-2500",
        });

        console.log("Generating thumbnail for merged video...");
        let thumbnailUrl = null;

        try {
          thumbnailUrl = await generateAndUploadThumbnail(
              outputFilePath,
              felicitupId,
              tempDir,
          );
          console.log("Thumbnail uploaded");
        } catch (thumbnailError) {
          console.error("Thumbnail generation failed:", thumbnailError);
          thumbnailUrl = await getDefaultThumbnail(felicitupId);
        }

        await admin.firestore().collection("Felicitups").doc(felicitupId).update({
          finalVideoUrl: finalVideoUrl,
          thumbnailUrl: thumbnailUrl,
          exportVideoUrl: finalVideoUrl,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          processingStatus: "merged",
          needsWatermark: true,
        });

        console.log("Firestore updated successfully - ready for watermarking");

        try {
          await sendNotification(userId, felicitupId, "merged");
        } catch (notificationError) {
          console.warn("Failed to send notification:", notificationError);
        }

        await snap.ref.update({
          status: "completed",
          finishedAt: admin.firestore.FieldValue.serverTimestamp(),
          result: {
            finalVideoUrl: finalVideoUrl,
            thumbnailUrl: thumbnailUrl,
            exportVideoUrl: finalVideoUrl,
          },
        });

        console.log(`Job ${felicitupId} completed successfully. Ready for watermark processing.`);
      } catch (error) {
        console.error("Error in mergeVideos:", error);

        await snap.ref.update({
          status: "failed",
          error: error.message,
          failedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        try {
          await admin.firestore().collection("Felicitups").doc(felicitupId).update({
            processingStatus: "failed",
            error: error.message,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        } catch (updateError) {
          console.error("Failed to update Felicitups document:", updateError);
        }

        throw new functions.https.HttpsError("internal", "Video merging failed", error.message);
      } finally {
        await cleanupTempFiles([...tempFiles, outputFilePath]);
      }
    },
);


async function normalizeVideo(inputPath, outputPath) {
  return new Promise((resolve, reject) => {
    const command = ffmpeg(inputPath)
        .inputOptions([
          '-analyzeduration 500K',
          '-probesize 500K',
        ])
        .videoCodec('libx264')
        .audioCodec('aac')
        .outputOptions([
          '-map', '0:v:0',
          '-map', '0:a:0?',
          '-ignore_unknown',
          '-dn',
          '-sn',
          '-profile:v', 'baseline',
          '-level', '3.1',
          '-pix_fmt', 'yuv420p',
          '-movflags', '+faststart',
          '-preset', 'ultrafast',
          '-crf', '23',
          '-b:a', '128k',
          '-ar', '44100',
          '-max_muxing_queue_size', '512',
          '-threads', '2',
          '-x264-params', 'ref=3:bframes=0:scenecut=0',
        ])
        .videoFilter('scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1')
        .audioFilter('aresample=async=1000')
        .on('start', (cmd) => console.log('Optimized normalization:', cmd))
        .on('end', () => {
          console.log('Optimized normalization completed');
          resolve();
        })
        .on('error', (err) => {
          console.error('Error in normalization:', err);
          reject(new Error(`Error al normalizar video: ${err.message}`));
        });

    command.save(outputPath);
  });
}

async function concatVideos(videoPaths, outputFilePath) {
  console.log("Starting optimized concatenation...");

  const reversedVideoPaths = [...videoPaths].reverse();
  const totalVideos = reversedVideoPaths.length;

  return new Promise((resolve, reject) => {
    const command = ffmpeg();

    reversedVideoPaths.forEach((videoPath) => {
      command.input(videoPath)
          .inputOptions([
            '-analyzeduration 500K',
            '-probesize 500K',
          ]);
    });

    const filterComplex = reversedVideoPaths.map((_, i) => {
      return `[${i}:v] [${i}:a]`;
    }).join(' ');

    command.complexFilter([
      {
        filter: 'concat',
        options: {
          n: totalVideos,
          v: 1,
          a: 1,
        },
        inputs: filterComplex,
        outputs: '[outv][outa]',
      },
    ])
        .outputOptions([
          '-map', '[outv]',
          '-map', '[outa]',
          '-ignore_unknown',
          '-dn',
          '-sn',
          '-c:v', 'libx264',
          '-profile:v', 'baseline',
          '-level', '3.1',
          '-pix_fmt', 'yuv420p',
          '-c:a', 'aac',
          '-b:a', '128k',
          '-ar', '44100',
          '-preset', 'ultrafast',
          '-movflags', '+faststart',
          '-shortest',
          '-threads', '2',
          '-x264-params', 'ref=3:bframes=0:scenecut=0',
        ])
        .on('start', (cmd) => {
          console.log('Starting optimized concatenation:', cmd);
        })
        .on('progress', (progress) => {
          if (progress.percent) {
            const normalizedPercent = Math.min(Math.round(progress.percent / totalVideos), 100);
            console.log(`Processing: ${normalizedPercent}% done`);
          }
        })
        .on('end', () => {
          console.log('Optimized concatenation completed successfully');
          resolve();
        })
        .on('error', (err, stdout, stderr) => {
          console.error('Error in optimized concatenation:', stderr);
          reject(new Error(`Error al concatenar videos: ${stderr || err.message}`));
        });

    command.save(outputFilePath);
  });
}

async function generateAndUploadThumbnail(videoPath, felicitupId, tempDir) {
  const thumbnailFileName = `thumbnail-${Date.now()}.jpg`;
  const thumbnailTempPath = path.join(tempDir, thumbnailFileName);
  const thumbnailDestinationPath = `thumbnails/${felicitupId}/${thumbnailFileName}`;

  await generateThumbnail(videoPath, thumbnailTempPath);
  await bucket.upload(thumbnailTempPath, {destination: thumbnailDestinationPath});

  const [thumbnailUrl] = await bucket.file(thumbnailDestinationPath).getSignedUrl({
    action: "read",
    expires: "03-01-2500",
  });


  try {
    if (fs.existsSync(thumbnailTempPath)) {
      fs.unlinkSync(thumbnailTempPath);
    }
  } catch (e) {
    console.warn("Could not delete thumbnail temp file:", e);
  }

  return thumbnailUrl;
}

async function generateThumbnail(videoPath, outputPath) {
  return new Promise((resolve, reject) => {
    const args = [
      '-i', videoPath,
      '-ss', '00:00:01',
      '-vframes', '1',
      '-q:v', '3',
      '-vf', 'scale=540:960',
      '-threads', '1',
      '-y',
      outputPath,
    ];

    console.log('Generating thumbnail for single video:', args);

    const process = execFile('ffmpeg', args, {timeout: 15000}, (error, stdout, stderr) => {
      if (error) {
        console.error('FFmpeg thumbnail error details:', stderr);


        const alternativeArgs = [
          '-i', videoPath,
          '-ss', '00:00:03',
          '-vframes', '1',
          '-q:v', '5',
          '-vf', 'scale=270:480',
          '-threads', '1',
          '-y',
          outputPath,
        ];

        console.log('Trying alternative thumbnail method:', alternativeArgs);

        execFile('ffmpeg', alternativeArgs, {timeout: 10000}, (altError, altStdout, altStderr) => {
          if (altError) {
            reject(new Error(`Both thumbnail methods failed: ${stderr} | ${altStderr}`));
            return;
          }
          resolve();
        });
        return;
      }
      resolve();
    });


    setTimeout(() => {
      try {
        process.kill();
        reject(new Error('Thumbnail generation timeout'));
      } catch (e) {
        console.log('Process already terminated', e);
      }
    }, 16000);
  });
}

async function getDefaultThumbnail(felicitupId) {
  try {
    const defaultThumbnailPath = 'default-thumbnail.jpg';
    const thumbnailDestinationPath = `thumbnails/${felicitupId}/default.jpg`;

    const [exists] = await bucket.file(defaultThumbnailPath).exists();

    if (exists) {
      await bucket.file(defaultThumbnailPath).copy(thumbnailDestinationPath);
      const [thumbnailUrl] = await bucket.file(thumbnailDestinationPath).getSignedUrl({
        action: "read",
        expires: "03-01-2500",
      });
      return thumbnailUrl;
    }
  } catch (error) {
    console.warn("Could not get default thumbnail:", error);
  }

  return null;
}

async function sendNotification(userId, felicitupId, type = "merged") {
  try {
    const userDoc = await admin.firestore().collection("Users").doc(userId).get();
    if (userDoc.exists && userDoc.data().fcmToken) {
      let title; let body;

      if (type === "merged") {
        title = "¡Tu video está listo!";
        body = "La combinación de videos se ha completado exitosamente.";
      } else if (type === "watermarked") {
        title = "¡Video finalizado!";
        body = "Tu video con marca de agua está listo para exportar.";
      }

      await admin.messaging().send({
        token: userDoc.data().fcmToken,
        notification: {
          title: title,
          body: body,
        },
        data: {
          "type": "video",
          "felicitupId": felicitupId,
          "chatId": "",
          "name": "",
          "friendId": "",
          "userImage": "",
          "processingStage": type,
        },
      });
      console.log(`Notification sent for stage: ${type}`);
    }
  } catch (notificationError) {
    console.warn("Failed to send notification:", notificationError);
  }
}

async function cleanupTempFiles(files) {
  for (const file of files) {
    try {
      if (file && fs.existsSync(file)) {
        fs.unlinkSync(file);
        console.log(`Deleted temp file: ${file}`);
      }
    } catch (e) {
      console.warn(`Could not delete temp file ${file}:`, e);
    }
  }
}

exports.processWatermark = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const {videoUrl, felicitupId, userId} = data.data;


  if (!videoUrl || !felicitupId || !userId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters: videoUrl, felicitupId, userId');
  }

  console.log(`Starting watermark processing for felicitup: ${felicitupId}, user: ${userId}`);

  const tempDir = os.tmpdir();
  let tempVideoPath = null;
  const watermarkedFilePath = null;
  const watermarkTempPath = null;

  try {
    console.log("Downloading video for watermark processing...");
    tempVideoPath = path.join(tempDir, `source-${Date.now()}.mp4`);


    const urlObj = new URL(videoUrl);
    const filePath = decodeURIComponent(urlObj.pathname.split('/o/')[1]);
    const file = bucket.file(filePath);

    await file.download({destination: tempVideoPath});
    console.log("Video downloaded successfully");


    console.log("Processing watermark...");
    const exportVideoUrl = await processWatermarkSimple(
        tempVideoPath,
        felicitupId,
        tempDir,
    );
    console.log("Watermark processed successfully");


    await admin.firestore().collection("Felicitups").doc(felicitupId).update({
      exportVideoUrl: exportVideoUrl,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      processingStatus: "completed",
      needsWatermark: false,
    });

    console.log("Firestore updated with watermarked video");


    try {
      await sendNotification(userId, felicitupId, "watermarked");
    } catch (notificationError) {
      console.warn("Failed to send watermark completion notification:", notificationError);
    }

    return {
      success: true,
      exportVideoUrl: exportVideoUrl,
      message: "Watermark processing completed successfully",
    };
  } catch (error) {
    console.error("Error in watermark processing:", error);


    await admin.firestore().collection("Felicitups").doc(felicitupId).update({
      processingStatus: "watermark_failed",
      error: error.message,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      warning: "Watermark processing failed, using original video",
    });

    throw new functions.https.HttpsError("internal", "Watermark processing failed", error.message);
  } finally {
    const filesToCleanup = [];
    if (tempVideoPath) filesToCleanup.push(tempVideoPath);
    if (watermarkedFilePath) filesToCleanup.push(watermarkedFilePath);
    if (watermarkTempPath) filesToCleanup.push(watermarkTempPath);

    await cleanupTempFiles(filesToCleanup);
  }
});

async function processWatermarkSimple(inputVideoPath, felicitupId, tempDir) {
  const watermarkFileName = `watermark-${Date.now()}.png`;
  const watermarkTempPath = path.join(tempDir, watermarkFileName);

  const watermarkedFileName = `export-${path.basename(inputVideoPath)}`;
  const watermarkedFilePath = path.join(tempDir, watermarkedFileName);
  const watermarkDestinationPath = `videos/${felicitupId}/${watermarkedFileName}`;

  try {
    console.log("Downloading watermark...");
    const watermarkFile = bucket.file("watermark.png");
    await watermarkFile.download({destination: watermarkTempPath});
    console.log("Watermark downloaded");


    if (!fs.existsSync(watermarkTempPath)) {
      throw new Error("Watermark file not found after download");
    }


    console.log("Applying simple watermark...");
    await applySimpleWatermark(inputVideoPath, watermarkedFilePath, watermarkTempPath);
    console.log("Simple watermark applied");


    console.log("Uploading watermarked video...");
    await bucket.upload(watermarkedFilePath, {destination: watermarkDestinationPath});
    console.log("Watermarked video uploaded");


    const [exportVideoUrl] = await bucket.file(watermarkDestinationPath).getSignedUrl({
      action: "read",
      expires: "03-01-2500",
    });

    return exportVideoUrl;
  } catch (error) {
    console.error("Error in simple watermark process:", error);
    throw error;
  } finally {
    try {
      if (fs.existsSync(watermarkTempPath)) fs.unlinkSync(watermarkTempPath);
      if (fs.existsSync(watermarkedFilePath)) fs.unlinkSync(watermarkedFilePath);
    } catch (cleanupError) {
      console.warn("Error cleaning watermark temp files:", cleanupError);
    }
  }
}

async function applySimpleWatermark(inputPath, outputPath, watermarkPath) {
  return new Promise((resolve, reject) => {
    const args = [
      '-i', inputPath,
      '-i', watermarkPath,
      '-filter_complex', '[1]format=rgba,colorchannelmixer=aa=0.7,scale=iw*0.2:-1[wm];[0][wm]overlay=W-w-10:H-h-10:format=auto,format=yuv420p',
      '-c:v', 'libx264',
      '-preset', 'ultrafast',
      '-crf', '24',
      '-c:a', 'copy',
      '-movflags', '+faststart',
      '-threads', '2',
      '-x264-params', 'ref=3:bframes=0:scenecut=0',
      '-y',
      outputPath,
    ];

    console.log('Executing optimized ffmpeg watermark with args:', args);

    const process = execFile('ffmpeg', args, {timeout: 300000}, (error, stdout, stderr) => {
      if (error) {
        console.error('Optimized FFmpeg watermark error:', stderr);


        console.log('Trying alternative watermark method without transparency...');
        applySimpleWatermarkAlternative(inputPath, outputPath, watermarkPath)
            .then(resolve)
            .catch(reject);
        return;
      }
      console.log('Optimized FFmpeg watermark completed successfully');
      resolve();
    });

    process.stderr.on('data', (data) => {
      const output = data.toString();
      if (output.includes('time=')) {
        console.log('FFmpeg watermark progress:', output.trim());
      }
    });


    const timeout = setTimeout(() => {
      try {
        process.kill();
        reject(new Error('Watermark processing timeout after 300 seconds'));
      } catch (e) {
        console.log('Process already terminated', e);
      }
    }, 305000);

    process.on('close', () => {
      clearTimeout(timeout);
    });
  });
}

async function applySimpleWatermarkAlternative(inputPath, outputPath, watermarkPath) {
  return new Promise((resolve, reject) => {
    const args = [
      '-i', inputPath,
      '-i', watermarkPath,
      '-filter_complex', '[1]format=rgb24,scale=iw*0.2:-1[wm];[0][wm]overlay=W-w-10:H-h-10:format=auto',
      '-c:v', 'libx264',
      '-preset', 'ultrafast',
      '-crf', '24',
      '-pix_fmt', 'yuv420p',
      '-c:a', 'copy',
      '-movflags', '+faststart',
      '-threads', '2',
      '-x264-params', 'ref=3:bframes=0:scenecut=0',
      '-y',
      outputPath,
    ];

    console.log('Executing alternative ffmpeg watermark without transparency:', args);

    const process = execFile('ffmpeg', args, {timeout: 300000}, (error, stdout, stderr) => {
      if (error) {
        console.error('Alternative FFmpeg watermark error:', stderr);
        reject(new Error(`Both watermark methods failed: ${stderr || error.message}`));
        return;
      }
      console.log('Alternative FFmpeg watermark completed successfully');
      resolve();
    });

    process.stderr.on('data', (data) => {
      const output = data.toString();
      if (output.includes('time=')) {
        console.log('Alternative FFmpeg watermark progress:', output.trim());
      }
    });
  });
}

exports.checkBirthdaysAndCreateAlerts = onSchedule({

  schedule: 'every 12 hours',
  timeZone: 'UTC',
  timeoutSeconds: 540,
  memory: '1GB',
  maxInstances: 1,
}, async (event) => {
  const db = admin.firestore();
  const today = new Date();

  console.log(`Starting birthday check from ${today.toISOString()}`);

  try {
    for (let dayOffset = 0; dayOffset < 5; dayOffset++) {
      const targetDate = new Date(today);
      targetDate.setDate(today.getDate() + dayOffset);

      const targetMonth = targetDate.getUTCMonth() + 1;
      const targetDay = targetDate.getUTCDate();
      const isToday = dayOffset === 0;

      console.log(`Checking for ${targetMonth}/${targetDay} (${isToday ? 'TODAY' : 'future'})`);

      await processBirthdaysForDate(db, targetMonth, targetDay, targetDate, isToday);
    }

    console.log('Birthday alerts processing completed successfully for 5-day window');
    return {success: true, message: 'Birthday alerts processed successfully for 5-day window'};
  } catch (error) {
    console.error('Error in checkBirthdaysAndCreateAlerts:', error);
    throw new functions.https.HttpsError('internal', 'Error processing birthday alerts', error);
  }
});

async function processBirthdaysForDate(db, targetMonth, targetDay, targetDate, shouldSendNotifications) {
  try {
    const birthdayUsersSnapshot = await db.collection(constants.usersPath)
        .where('birthMonth', '==', targetMonth)
        .where('birthDay', '==', targetDay)
        .get();

    if (birthdayUsersSnapshot.empty) {
      console.log(`No birthdays found for ${targetMonth}/${targetDay}`);
      return;
    }

    console.log(`Found ${birthdayUsersSnapshot.size} users with birthdays on ${targetMonth}/${targetDay}`);

    const processingPromises = birthdayUsersSnapshot.docs.map(async (birthdayUserDoc) => {
      const birthdayUser = birthdayUserDoc.data();
      const birthdayUserId = birthdayUserDoc.id;

      if (!birthdayUser.matchList || birthdayUser.matchList.length === 0) {
        console.log(`User ${birthdayUserId} has no matchList, skipping`);
        return;
      }


      const filteredMatchList = birthdayUser.matchList.filter((friendId) => friendId !== birthdayUserId);

      if (filteredMatchList.length === 0) {
        console.log(`User ${birthdayUserId} has no valid friends in matchList`);
        return;
      }

      console.log(`Processing birthday user ${birthdayUserId} with ${filteredMatchList.length} valid matches`);
      await processFriendsForBirthdayUser(
          db,
          birthdayUser,
          birthdayUserId,
          filteredMatchList,
          targetDate,
          shouldSendNotifications,
      );
    });

    await Promise.all(processingPromises);
  } catch (error) {
    console.error(`Error processing date ${targetMonth}/${targetDay}:`, error);
    throw error;
  }
}

async function processFriendsForBirthdayUser(db, birthdayUser, birthdayUserId, matchList, targetDate, shouldSendNotifications) {
  const batch = db.batch();
  const friendsToNotify = [];

  try {
    const friendsSnapshots = await Promise.all(
        matchList.map((friendId) =>
          db.collection(constants.usersPath).doc(friendId).get(),
        ),
    );

    for (let i = 0; i < matchList.length; i++) {
      const friendId = matchList[i];
      const friendDoc = friendsSnapshots[i];

      if (!friendDoc.exists) {
        console.log(`Friend ${friendId} not found, skipping`);
        continue;
      }

      const friendData = friendDoc.data();

      const existingAlerts = friendData.birthdateAlerts || [];
      const alertExists = existingAlerts.some((alert) =>
        alert.friendId === birthdayUserId,
      );

      if (alertExists) {
        console.log(`Alert already exists for ${birthdayUserId} in ${friendId}`);
        continue;
      }

      const alertDate = new Date(targetDate);
      alertDate.setFullYear(new Date().getFullYear());

      const newAlert = {
        id: `${birthdayUserId}-${alertDate.getTime()}`,
        friendId: birthdayUserId,
        friendName: birthdayUser.fullName || `User ${birthdayUserId}`,
        friendProfilePic: birthdayUser.userImg || "",
        targetDate: alertDate,
      };


      const friendRef = db.collection(constants.usersPath).doc(friendId);
      batch.update(friendRef, {
        birthdateAlerts: admin.firestore.FieldValue.arrayUnion(newAlert),
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
      console.log(`Created alerts for ${matchList.length} friends of ${birthdayUserId}`);


      if (shouldSendNotifications && friendsToNotify.length > 0) {
        await sendBirthdayNotifications(friendsToNotify, birthdayUser.fullName, birthdayUserId, birthdayUser.userImg);
      }
    }
  } catch (error) {
    console.error(`Error processing friends for ${birthdayUserId}:`, error);
    throw error;
  }
}

async function sendBirthdayNotifications(friendsToNotify, birthdayUserName, friendId, friendImage) {
  try {
    const batchSize = 500;
    for (let i = 0; i < friendsToNotify.length; i += batchSize) {
      const batch = friendsToNotify.slice(i, i + batchSize);
      const messages = batch.map((friend) => ({
        token: friend.token,
        notification: {
          title: '🎉 ¡Cumpleaños hoy!',
          body: `${birthdayUserName} está celebrando su cumpleaños hoy. ¡Envíale tus felicitaciones!`,
        },
        data: {
          type: "reminder",
          felicitupId: "",
          chatId: "",
          name: birthdayUserName,
          friendId: friendId,
          userImage: friendImage,
        },
      }));

      await admin.messaging().sendEach(messages);
      console.log(`Sent ${messages.length} notifications in batch`);
    }
    console.log(`Total notifications sent: ${friendsToNotify.length}`);
  } catch (error) {
    console.error('Error sending notifications:', error);
  }
}

exports.getTemporaryImageUrl = onCall(
    {
      timeoutSeconds: 120,
      memory: '512MiB',
      region: 'us-central1',
    },
    async (request) => {
      if (!request.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "El usuario debe estar autenticado para obtener la URL de la imagen temporal.",
        );
      }

      const imageName = request.data.imageName;
      if (!imageName) {
        throw new HttpsError(
            "invalid-argument",
            "Se requiere el parámetro 'imageName' en la solicitud.",
        );
      }
    });


exports.disableCurrentUser = onCall(
    {
      timeoutSeconds: 120,
      memory: '512MiB',
      region: 'us-central1',
    },
    async (request) => {
      if (!request.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "El usuario debe estar autenticado para poder bloquear su cuenta.",
        );
      }

      const uid = request.auth.uid;

      try {
        await getAuth().updateUser(uid, {disabled: true});


        await getAuth().revokeRefreshTokens(uid);

        console.log(`Usuario ${uid} deshabilitado exitosamente (v2).`);
        return {success: true, message: "Tu cuenta ha sido bloqueada exitosamente."};
      } catch (error) {
        console.error("Error al deshabilitar el usuario (v2):", error);
        throw new functions.https.HttpsError(
            "internal",
            "Ocurrió un error al intentar bloquear tu cuenta.",
        );
      }
    });
