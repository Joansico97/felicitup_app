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

const {getDeviceToken, sendPushNotification, sendPushNotificationToListContacts} = require("./notifications/notifications");
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

// Configura las rutas de FFmpeg (ESTO ES CLAVE)
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
    {region: "us-central1"}, // ¡Siempre especifica la región!
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
      // Accede a los datos dentro de 'data.data':
        const userId = data.data.userId; // <-- data.data
        const title = data.data.title; // <-- data.data
        const message = data.data.message;// <-- data.data
        const currentChat = data.data.currentChat; // <-- data.data
        const dataInfo = data.data.dataInfo; // <-- data.data  O data.data.dataInfo, según necesites.
        console.log("Data recibida en sendNotification:", dataInfo);

        if (!userId) {
          throw new functions.https.HttpsError("invalid-argument", "El ID del usuario es requerido.");
        }

        // ... resto de tu lógica, usando userId, title, message, etc. ...
        const db = admin.firestore();
        const userDoc = await db.collection("Users").doc(userId).get();

        if (!userDoc.exists) {
          throw new functions.https.HttpsError("not-found", "No se encontró el usuario con el ID proporcionado.");
        }

        const userData = userDoc.data();
        const token = userData.fcmToken;

        if (!token) {
          throw new functions.https.HttpsError(
              "not-found",
              "El usuario no tiene un token de FCM registrado.",
          );
        }

        if (!currentChat || userData.currentChat !== currentChat) {
          console.log("Enviando notificación a:", token);
          const payload = {
            token,
            notification: {
              title: title,
              body: message,
            },
            data: dataInfo,
          };
          await sendPushNotification(payload);
          // await admin.messaging().send(payload);
          return {success: true};
        }
      } catch (error) {
        functions.console.error("Error en sendNotification:", error, {userId: data && data.data ? data.data.userId : undefined}); // Log estructurado.
        if (error instanceof functions.https.HttpsError) {
          throw error;
        }
        throw new functions.https.HttpsError("internal", "Error al enviar la notificación", error);
      }
    },
);

exports.sendNotificationToList = functions.https.onCall(
    async (data) => {
      try {
        const userIds = data.data.userIds; // Lista de IDs de usuarios
        const title = data.data.title;
        const message = data.data.message;
        const dataInfo = data.data.dataInfo;
        const currentChat = data.data.currentChat;

        if (!Array.isArray(userIds)) {
          console.table(userIds);
          throw new functions.https.HttpsError("invalid-argument", "La lista de IDs de usuarios no es válida.");
        }

        // Obtener los tokens de los usuarios que cumplen con la condición
        const tokensToSend = [];
        for (const userId of userIds) {
          try {
            const userData = await getUserDataById(userId);
            const token = await getDeviceToken(userId);
            if (token && (!currentChat || userData.currentChat !== currentChat)) {
              tokensToSend.push(token);
            }
          } catch (error) {
            console.error(`Error al obtener datos del usuario ${userId}:`, error);
          }
        }

        if (tokensToSend.length > 0) {
          const payload = {
            tokens: tokensToSend,
            notification: {
              title: title,
              body: message,
            },
            data: dataInfo,
          };

          console.log("Sending Notifications to tokens:", tokensToSend);
          await sendPushNotificationToListContacts(payload);
        } else {
          console.log("No se encontraron tokens válidos para enviar notificaciones.");
        }
      } catch (e) {
        console.log("Firebase Notification Failed: " + e.message);
        throw new functions.https.HttpsError("internal", "Error al enviar notificaciones", e.message);
      }
    });

exports.sendFelicitup = onCall(
    {
      secrets: [taskQueueSecret],
      timeoutSeconds: 120,
      memory: '512MiB',
      region: 'us-central1',
    },
    async (request) => {
    // 1. Verificación de autenticación
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

      // 2. Validación de parámetros
      const felicitupId = request.data.felicitupId;

      if (!felicitupId || typeof felicitupId !== 'string') {
        throw new HttpsError(
            'invalid-argument',
            'El parámetro felicitupId es requerido y debe ser un string',
        );
      }

      try {
        const db = getFirestore();
        // 3. Obtener la Felicitup de Firestore
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

        // 4. Verificar si la fecha ya pasó
        if (eventDate <= now) {
          await completeFelicitup(felicitupId);
          return {
            success: true,
            message: 'Felicitup completada inmediatamente',
            executedImmediately: true,
          };
        }

        // 5. Programar la tarea con Cloud Tasks
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

        // 6. Actualizar estado en Firestore
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
          throw error; // Reenviar errores ya tipados
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

    // Aquí colocas tu lógica original para completar la Felicitup
    // (similar a tu función sendManualFelicitup pero sin la parte HTTP)

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

        // Enviar notificación push
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

    // Marcar como completada
    await felicitupRef.update({
      // status: "Finished",
    });

    console.log(`Felicitup ${felicitupId} completada exitosamente`);
  } catch (error) {
    console.error(`Error al completar la Felicitup ${felicitupId}:`, error);
    // await felicitupRef.update({status: "failed"});
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

exports.mergeVideos = functions.https.onCall({
  region: "us-central1",
  timeoutSeconds: 540,
  memory: "8GiB",
}, async (data, context) => {
  const {videoUrls, userId, felicitupId} = data.data;
  if (!videoUrls || !Array.isArray(videoUrls)) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid video URLs");
  }

  const tempDir = os.tmpdir();
  const outputFileName = `merged-${Date.now()}.mp4`;
  const outputFilePath = path.join(tempDir, outputFileName);
  const tempFiles = [];
  const processedFiles = [];
  let watermarkTempPath; // Para la limpieza

  try {
    // 1. Descargar y normalizar cada video
    for (const [index, url] of videoUrls.entries()) {
      const tempFilePath = path.join(tempDir, `source-${index}.mp4`);
      const processedPath = path.join(tempDir, `processed-${index}.mp4`);

      console.log(`Processing video ${index + 1}/${videoUrls.length}`);

      // Descargar el video
      const file = bucket.file(url);
      await file.download({destination: tempFilePath});

      // Normalizar TODOS los videos para consistencia
      console.log(`Normalizing video ${index + 1}`);
      await normalizeVideo(tempFilePath, processedPath);

      processedFiles.push(processedPath);
      tempFiles.push(tempFilePath);

      // Verificar metadatos del video normalizado
      try {
        const meta = await getVideoMetadata(processedPath);
        console.log(`Video ${index + 1} metadata:`, {
          codec: meta.codec_name,
          width: meta.width,
          height: meta.height,
          fps: meta.fps,
          duration: meta.duration,
        });
      } catch (metaError) {
        console.warn(`Could not get metadata for video ${index + 1}:`, metaError);
      }
    }

    // 2. Concatenar los videos normalizados
    console.log("Concatenating normalized videos...");
    await concatVideos(processedFiles, outputFilePath);

    // 3. Subir el resultado original
    const destinationPath = `videos/${felicitupId}/${outputFileName}`;
    await bucket.upload(outputFilePath, {destination: destinationPath});

    // --- INICIO DEL CAMBIO SOLICITADO ---

    // 3.1. Generar y subir video con marca de agua
    console.log("Adding watermark to the final video...");
    const watermarkedFileName = `export-${outputFileName}`;
    const watermarkedFilePath = path.join(tempDir, watermarkedFileName);
    const watermarkDestinationPath = `videos/${felicitupId}/${watermarkedFileName}`;

    // Descargar el archivo de la marca de agua desde el bucket
    const watermarkFile = bucket.file("watermark.png"); // El archivo debe estar en la raíz del bucket
    watermarkTempPath = path.join(tempDir, "watermark.png");
    await watermarkFile.download({destination: watermarkTempPath});

    // Aplicar la marca de agua
    // await addWatermark(outputFilePath, watermarkedFilePath, watermarkTempPath);

    // Subir el video con marca de agua
    await bucket.upload(watermarkedFilePath, {destination: watermarkDestinationPath});

    // --- FIN DEL CAMBIO SOLICITADO ---

    // 4. Generar y subir thumbnail
    const thumbnailFileName = `thumbnail-${Date.now()}.jpg`;
    const thumbnailTempPath = path.join(tempDir, thumbnailFileName);
    const thumbnailDestinationPath = `thumbnails/${felicitupId}/${thumbnailFileName}`;

    console.log("Generating thumbnail...");
    await generateThumbnail(outputFilePath, thumbnailTempPath);
    await bucket.upload(thumbnailTempPath, {destination: thumbnailDestinationPath});

    // 5. Obtener URLs y actualizar Firestore
    const mergedFile = bucket.file(destinationPath);
    const thumbnailFile = bucket.file(thumbnailDestinationPath);
    const watermarkedFile = bucket.file(watermarkDestinationPath); // Referencia al archivo con marca de agua

    const [url] = await mergedFile.getSignedUrl({action: "read", expires: "03-01-2500"});
    const [thumbnailUrl] = await thumbnailFile.getSignedUrl({action: "read", expires: "03-01-2500"});
    const [exportVideoUrl] = await watermarkedFile.getSignedUrl({action: "read", expires: "03-01-2500"}); // URL del video con marca de agua

    await admin.firestore().collection("Felicitups").doc(felicitupId)
        .update({
          finalVideoUrl: url,
          thumbnailUrl: thumbnailUrl,
          exportVideoUrl: exportVideoUrl, // Nueva propiedad
        });

    // 6. Enviar notificación
    const userDoc = await admin.firestore().collection("Users").doc(userId).get();
    if (userDoc.exists && userDoc.data().fcmToken) {
      await admin.messaging().send({
        token: userDoc.data().fcmToken,
        notification: {
          title: "¡Tu video está listo!",
          body: "La combinación de videos se ha completado exitosamente.",
        },
        data: {
          "type": "video",
          "felicitupId": felicitupId,
          "chatId": "",
          "name": "",
          "friendId": "",
          "userImage": "",
        },
      });
    }

    return {success: true, videoUrl: url, exportVideoUrl: exportVideoUrl};
  } catch (error) {
    console.error("Error in mergeVideos:", error);
    throw new functions.https.HttpsError("internal", "Video processing failed", error.message);
  } finally {
    // Limpieza más robusta
    const allTempFiles = [...tempFiles, ...processedFiles, outputFilePath, watermarkTempPath];
    for (const file of allTempFiles) {
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
});

async function getVideoMetadata(filePath) {
  return new Promise((resolve, reject) => {
    execFile('ffprobe', [
      '-v', 'error',
      '-select_streams', 'v:0',
      '-show_entries', 'stream=codec_name,width,height,r_frame_rate,duration',
      '-of', 'json',
      filePath,
    ], (error, stdout, stderr) => {
      if (error) return reject(new Error(`FFprobe error: ${stderr}`));
      try {
        const metadata = JSON.parse(stdout).streams[0];
        const [numerator, denominator] = metadata.r_frame_rate.split('/');
        metadata.fps = numerator / denominator;
        resolve(metadata);
      } catch (e) {
        reject(new Error('Invalid metadata'));
      }
    });
  });
}

exports.processVideoMerge = onDocumentCreated(
    {
      document: "videoMergeJobs/{felicitupId}",
      timeoutSeconds: 540,
      memory: "4GB",
      maxInstances: 2,
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

      await snap.ref.update({
        status: "processing",
        startedAt: admin.firestore.FieldValue.serverTimestamp(),
        totalVideos: videoUrls.length,
        processedVideos: 0,
      });

      const tempDir = os.tmpdir();
      const outputFileName = `merged-${Date.now()}.mp4`;
      const outputFilePath = path.join(tempDir, outputFileName);
      const tempFiles = [];
      const processedFiles = [];

      try {
      // 1. Descargar y normalizar videos en paralelo (con limitación de concurrencia)
        console.log(`Downloading and processing ${videoUrls.length} videos`);

        // Procesar videos con concurrencia limitada para no saturar recursos
        const concurrencyLimit = 3;
        const processVideo = async (url, index) => {
          const tempFilePath = path.join(tempDir, `source-${index}-${Date.now()}.mp4`);
          const processedPath = path.join(tempDir, `processed-${index}-${Date.now()}.mp4`);

          console.log(`Processing video ${index + 1}/${videoUrls.length}: ${url}`);

          try {
          // Descargar el video
            const file = bucket.file(url);
            await file.download({destination: tempFilePath});
            console.log(`Downloaded video ${index + 1}`);

            // Normalizar el video
            console.log(`Normalizing video ${index + 1}`);
            await normalizeVideo(tempFilePath, processedPath);
            console.log(`Normalized video ${index + 1}`);

            processedFiles.push(processedPath);
            tempFiles.push(tempFilePath);

            // Limpiar archivo fuente inmediatamente
            try {
              if (fs.existsSync(tempFilePath)) {
                fs.unlinkSync(tempFilePath);
                console.log(`Deleted source file: ${tempFilePath}`);
              }
            } catch (e) {
              console.warn(`Could not delete source file: ${e}`);
            }

            // Actualizar progreso
            await snap.ref.update({
              processedVideos: index + 1,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
          } catch (videoError) {
            console.error(`Error processing video ${index + 1}:`, videoError);
            throw new Error(`Failed to process video ${index + 1}: ${videoError.message}`);
          }
        };

        // Ejecutar con limitación de concurrencia
        for (let i = 0; i < videoUrls.length; i += concurrencyLimit) {
          const chunk = videoUrls.slice(i, i + concurrencyLimit);
          await Promise.all(chunk.map((url, idx) => processVideo(url, i + idx)));
        }

        // 2. Concatenar los videos normalizados
        console.log("Concatenating normalized videos...");
        await concatVideos(processedFiles, outputFilePath);
        console.log("Videos concatenated successfully");

        // Limpiar archivos procesados inmediatamente
        for (const processedFile of processedFiles) {
          try {
            if (fs.existsSync(processedFile)) {
              fs.unlinkSync(processedFile);
              console.log(`Deleted processed file: ${processedFile}`);
            }
          } catch (e) {
            console.warn(`Could not delete processed file: ${e}`);
          }
        }

        // 3. Subir el resultado original
        const destinationPath = `videos/${felicitupId}/${outputFileName}`;
        await bucket.upload(outputFilePath, {destination: destinationPath});
        console.log("Original video uploaded");

        // 4. Procesar marca de agua (versión simplificada)
        console.log("Processing watermark...");
        let exportVideoUrl = null;

        try {
          exportVideoUrl = await processWatermarkSimple(
              outputFilePath,
              felicitupId,
              tempDir,
          );
          console.log("Watermark processed successfully");
        } catch (watermarkError) {
          console.error("Watermark processing failed, using original video:", watermarkError);
          // Obtener URL del video original como fallback
          const [originalUrl] = await bucket.file(destinationPath).getSignedUrl({
            action: "read",
            expires: "03-01-2500",
          });
          exportVideoUrl = originalUrl;
        }

        // 5. Generar y subir thumbnail
        console.log("Generating thumbnail...");
        const thumbnailUrl = await generateAndUploadThumbnail(
            outputFilePath,
            felicitupId,
            tempDir,
        );
        console.log("Thumbnail uploaded");

        // 6. Obtener URL del video final
        const [finalVideoUrl] = await bucket.file(destinationPath).getSignedUrl({
          action: "read",
          expires: "03-01-2500",
        });

        // 7. Actualizar Firestore
        await admin.firestore().collection("Felicitups").doc(felicitupId).update({
          finalVideoUrl: finalVideoUrl,
          thumbnailUrl: thumbnailUrl,
          exportVideoUrl: exportVideoUrl,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          processingStatus: "completed",
        });

        console.log("Firestore updated successfully");

        // 8. Enviar notificación
        await sendNotification(userId, felicitupId);

        // 9. Marcar trabajo como completado
        await snap.ref.update({
          status: "completed",
          finishedAt: admin.firestore.FieldValue.serverTimestamp(),
          result: {
            finalVideoUrl: finalVideoUrl,
            thumbnailUrl: thumbnailUrl,
            exportVideoUrl: exportVideoUrl,
          },
        });

        console.log(`Job ${felicitupId} completed successfully.`);
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

        throw new functions.https.HttpsError("internal", "Video processing failed", error.message);
      } finally {
        await cleanupTempFiles([...tempFiles, outputFilePath]);
      }
    },
);

async function normalizeVideo(inputPath, outputPath) {
  return new Promise((resolve, reject) => {
    const command = ffmpeg(inputPath)
        .inputOptions([
          '-analyzeduration 1M',
          '-probesize 1M',
        ])
        .videoCodec('libx264')
        .audioCodec('aac')
        .outputOptions([
          // Map ONLY video and audio streams, ignore all others
          '-map', '0:v:0', // Primer stream de video solamente
          '-map', '0:a:0?', // Primer stream de audio (opcional)
          '-ignore_unknown', // Ignorar streams desconocidos
          '-dn', // Descartar metadata
          '-sn', // Descartar subtítulos
          '-profile:v', 'baseline',
          '-level', '3.1',
          '-pix_fmt', 'yuv420p',
          '-movflags', '+faststart',
          '-preset', 'ultrafast',
          '-crf', '23',
          '-b:a', '128k',
          '-ar', '44100',
          '-max_muxing_queue_size', '1024',
          '-threads', '2',
        ])
        .videoFilter('scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1')
        .audioFilter('aresample=async=1000')
        .on('start', (cmd) => console.log('Normalizing video with compatible codecs:', cmd))
        .on('end', () => {
          console.log('Normalization with compatible codecs completed');
          resolve();
        })
        .on('error', (err) => {
          console.error('Error in normalization:', err);
          reject(new Error(`Error al normalizar video: ${err.message}`));
        });

    command.save(outputPath);
  });
}

/**
 * Concatenar videos con normalización de codecs para compatibilidad entre Android e iOS
 * Y en el orden correcto (primero al último)
 */
async function concatVideos(videoPaths, outputFilePath) {
  console.log("Starting concatenation with codec normalization...");

  // INVERTIR EL ORDEN DEL ARRAY para que concatene en el orden correcto
  const reversedVideoPaths = [...videoPaths].reverse();
  console.log(`Original order: ${videoPaths.length} videos`);
  console.log(`Reversed order for concatenation`);

  return new Promise((resolve, reject) => {
    const command = ffmpeg();

    // Agregar todos los inputs con opciones para manejar formatos diversos
    reversedVideoPaths.forEach((videoPath) => {
      command.input(videoPath)
          .inputOptions([
            '-analyzeduration 1M',
            '-probesize 1M',
          ]);
    });

    // Construir el filtro complex para concatenación
    const filterComplex = reversedVideoPaths.map((_, i) => {
      return `[${i}:v] [${i}:a]`;
    }).join(' ');

    command.complexFilter([
      {
        filter: 'concat',
        options: {
          n: reversedVideoPaths.length,
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
          '-ignore_unknown', // Ignorar streams desconocidos
          '-dn', // Descartar metadata
          '-sn', // Descartar subtítulos
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
        ])
        .on('start', (cmd) => {
          console.log('Starting reliable concatenation with codec normalization:', cmd);
        })
        .on('end', () => {
          console.log('Concatenation with codec normalization completed successfully');
          resolve();
        })
        .on('error', (err, stdout, stderr) => {
          console.error('Error in concatenation with codec normalization:', stderr);
          reject(new Error(`Error al concatenar videos: ${stderr || err.message}`));
        });

    command.save(outputFilePath);
  });
}

/**
 * Procesar marca de agua (versión optimizada)
 */
async function processWatermarkSimple(inputVideoPath, felicitupId, tempDir) {
  const watermarkFileName = `watermark-${Date.now()}.png`;
  const watermarkTempPath = path.join(tempDir, watermarkFileName);

  const watermarkedFileName = `export-${path.basename(inputVideoPath)}`;
  const watermarkedFilePath = path.join(tempDir, watermarkedFileName);
  const watermarkDestinationPath = `videos/${felicitupId}/${watermarkedFileName}`;

  try {
    // Descargar watermark
    console.log("Downloading watermark...");
    const watermarkFile = bucket.file("watermark.png");
    await watermarkFile.download({destination: watermarkTempPath});
    console.log("Watermark downloaded");

    // Verificar que el watermark existe
    if (!fs.existsSync(watermarkTempPath)) {
      throw new Error("Watermark file not found after download");
    }

    // Aplicar marca de agua simplificada
    console.log("Applying simple watermark...");
    await applySimpleWatermark(inputVideoPath, watermarkedFilePath, watermarkTempPath);
    console.log("Simple watermark applied");

    // Subir video con marca de agua
    console.log("Uploading watermarked video...");
    await bucket.upload(watermarkedFilePath, {destination: watermarkDestinationPath});
    console.log("Watermarked video uploaded");

    // Obtener URL
    const [exportVideoUrl] = await bucket.file(watermarkDestinationPath).getSignedUrl({
      action: "read",
      expires: "03-01-2500",
    });

    return exportVideoUrl;
  } catch (error) {
    console.error("Error in simple watermark process:", error);
    throw error;
  } finally {
    // Limpiar archivos temporales
    try {
      if (fs.existsSync(watermarkTempPath)) fs.unlinkSync(watermarkTempPath);
      if (fs.existsSync(watermarkedFilePath)) fs.unlinkSync(watermarkedFilePath);
    } catch (cleanupError) {
      console.warn("Error cleaning watermark temp files:", cleanupError);
    }
  }
}

/**
 * Aplicar marca de agua simplificada (optimizada)
 */
async function applySimpleWatermark(inputPath, outputPath, watermarkPath) {
  return new Promise((resolve, reject) => {
    const args = [
      '-i', inputPath,
      '-i', watermarkPath,
      '-filter_complex', '[1]format=rgba,colorchannelmixer=aa=0.7[wm];[0][wm]overlay=W-w-10:H-h-10:format=auto', // Mejor control de transparencia
      '-c:v', 'libx264',
      '-preset', 'ultrafast', // Más rápido
      '-crf', '24', // Calidad ligeramente inferior para mayor velocidad
      '-c:a', 'copy', // Copiar audio en lugar de re-codificar
      '-movflags', '+faststart',
      '-threads', '2', // Limitar threads
      '-y',
      outputPath,
    ];

    console.log('Executing optimized ffmpeg with args:', args);

    const process = execFile('ffmpeg', args, {timeout: 120000}, (error, stdout, stderr) => {
      if (error) {
        console.error('Optimized FFmpeg error:', stderr);
        reject(new Error(`Optimized FFmpeg failed: ${stderr || error.message}`));
        return;
      }
      console.log('Optimized FFmpeg completed successfully');
      resolve();
    });

    // Log en tiempo real
    process.stderr.on('data', (data) => {
      const output = data.toString();
      if (output.includes('time=')) {
        console.log('FFmpeg progress:', output.trim());
      }
    });

    process.stdout.on('data', (data) => {
      console.log('FFmpeg stdout:', data.toString().trim());
    });
  });
}

/**
 * Generar y subir thumbnail (optimizado)
 */
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

  // Limpiar thumbnail temporal
  try {
    if (fs.existsSync(thumbnailTempPath)) {
      fs.unlinkSync(thumbnailTempPath);
    }
  } catch (e) {
    console.warn("Could not delete thumbnail temp file:", e);
  }

  return thumbnailUrl;
}

/**
 * Generar thumbnail (optimizado)
 */
async function generateThumbnail(videoPath, outputPath) {
  return new Promise((resolve, reject) => {
    execFile('ffmpeg', [
      '-i', videoPath,
      '-ss', '00:00:01',
      '-vframes', '1',
      '-q:v', '3', // Calidad ligeramente inferior para mayor velocidad
      '-vf', 'scale=540:960',
      '-threads', '1', // Solo un thread para thumbnail
      '-y',
      outputPath,
    ], {timeout: 15000}, (error, stdout, stderr) => { // Timeout reducido
      if (error) return reject(new Error(`FFmpeg thumbnail error: ${stderr}`));
      resolve();
    });
  });
}

/**
 * Enviar notificación (sin cambios)
 */
async function sendNotification(userId, felicitupId) {
  try {
    const userDoc = await admin.firestore().collection("Users").doc(userId).get();
    if (userDoc.exists && userDoc.data().fcmToken) {
      await admin.messaging().send({
        token: userDoc.data().fcmToken,
        notification: {
          title: "¡Tu video está listo!",
          body: "La combinación de videos se ha completado exitosamente.",
        },
        data: {
          "type": "video",
          "felicitupId": felicitupId,
          "chatId": "",
          "name": "",
          "friendId": "",
          "userImage": "",
        },
      });
      console.log("Notification sent");
    }
  } catch (notificationError) {
    console.warn("Failed to send notification:", notificationError);
  }
}

/**
 * Limpieza de archivos temporales (sin cambios)
 */
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

exports.checkBirthdaysAndCreateAlerts = onSchedule({
  // schedule: 'every 24 hours',
  schedule: 'every 5 minutes',
  timeZone: 'UTC',
  timeoutSeconds: 540,
  memory: '1GB',
  maxInstances: 1,
}, async (event) => {
  const db = admin.firestore();
  const today = new Date();

  console.log(`Starting birthday check from ${today.toISOString()}`);

  try {
    // Procesar para hoy + 4 días siguientes (total 5 días)
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

      // Filtrar el propio ID del usuario de su matchList
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
    // Obtener datos de todos los amigos a la vez
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

      // Preparar actualización
      const friendRef = db.collection(constants.usersPath).doc(friendId);
      batch.update(friendRef, {
        birthdateAlerts: admin.firestore.FieldValue.arrayUnion(newAlert),
      });

      // Solo agregar a notificaciones si es el día exacto del cumpleaños
      if (shouldSendNotifications && friendData.fcmToken) {
        friendsToNotify.push({
          token: friendData.fcmToken,
          friendName: friendData.fullName || `User ${friendId}`,
          friendId: friendId,
        });
      }
    }

    // Ejecutar actualizaciones
    if (matchList.length > 0) {
      await batch.commit();
      console.log(`Created alerts for ${matchList.length} friends of ${birthdayUserId}`);

      // Enviar notificaciones solo si es el día exacto
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
        // Deshabilitar el usuario utilizando el Admin SDK.
        await getAuth().updateUser(uid, {disabled: true});

        // Revocar los tokens de actualización para cerrar la sesión inmediatamente.
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
