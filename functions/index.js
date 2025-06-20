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

// Función principal con mejor manejo de errores
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

    // 3. Subir el resultado
    const destinationPath = `videos/${felicitupId}/${outputFileName}`;
    await bucket.upload(outputFilePath, {destination: destinationPath});

    // 4. Generar y subir thumbnail
    const thumbnailFileName = `thumbnail-${Date.now()}.jpg`;
    const thumbnailTempPath = path.join(tempDir, thumbnailFileName);
    const thumbnailDestinationPath = `thumbnails/${felicitupId}/${thumbnailFileName}`;

    console.log("Generating thumbnail...");
    await generateThumbnail(outputFilePath, thumbnailTempPath);
    await bucket.upload(thumbnailTempPath, {destination: thumbnailDestinationPath});

    // 5. Obtener URL y actualizar Firestore
    const mergedFile = bucket.file(destinationPath);
    const thumbnailFile = bucket.file(thumbnailDestinationPath);
    const [url] = await mergedFile.getSignedUrl({action: "read", expires: "03-01-2500"});
    const [thumbnailUrl] = await thumbnailFile.getSignedUrl({action: "read", expires: "03-01-2500"});

    await admin.firestore().collection("Felicitups").doc(felicitupId)
        .update({finalVideoUrl: url, thumbnailUrl: thumbnailUrl});

    // 6. Enviar notificación (implementación básica)
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

    return {success: true, videoUrl: url};
  } catch (error) {
    console.error("Error in mergeVideos:", error);
    throw new functions.https.HttpsError("internal", "Video processing failed", error.message);
  } finally {
    // Limpieza más robusta
    const allTempFiles = [...tempFiles, ...processedFiles, outputFilePath];
    for (const file of allTempFiles) {
      try {
        if (fs.existsSync(file)) {
          fs.unlinkSync(file);
          console.log(`Deleted temp file: ${file}`);
        }
      } catch (e) {
        console.warn(`Could not delete temp file ${file}:`, e);
      }
    }
  }
});

// Modifica la función normalizeVideo para manejar codecs desconocidos
async function normalizeVideo(inputPath, outputPath) {
  return new Promise((resolve, reject) => {
    const command = ffmpeg(inputPath)
        .inputOptions([
          '-ignore_unknown', // Ignora streams desconocidos
          '-analyzeduration 10M', // Aumenta tiempo de análisis
          '-probesize 10M', // Aumenta tamaño de sondeo
        ])
        .videoCodec('libx264')
        .audioCodec('aac')
        .outputOptions([
          '-map 0:v', // Solo el stream de video
          '-map 0:a:0?', // Solo el primer stream de audio (si existe)
          '-movflags +faststart',
          '-preset fast',
          '-strict experimental', // Permite codecs experimentales
        ])
        .videoFilter('scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1')
        .audioFilter('aresample=async=1000')
        .on('start', (cmd) => console.log('Ejecutando:', cmd))
        .on('progress', (progress) => console.log(`Progreso: ${progress.percent}%`))
        .on('end', () => {
          console.log('Normalización completada');
          resolve();
        })
        .on('error', (err) => {
          console.error('Error en normalización:', err);
          reject(new Error(`Error al normalizar video: ${err.message}`));
        });

    command.save(outputPath);
  });
}

// Función concatVideos actualizada
async function concatVideos(videoPaths, outputFilePath) {
  return new Promise((resolve, reject) => {
    const command = ffmpeg();

    // Añadir inputs con opciones para manejar codecs especiales
    videoPaths.forEach((path) => {
      command.input(path)
          .inputOptions([
            '-ignore_unknown',
            '-analyzeduration 10M',
            '-probesize 10M',
          ]);
    });

    // Configurar filtros complejos
    command.complexFilter([
      {
        filter: 'concat',
        options: {
          n: videoPaths.length,
          v: 1,
          a: 1,
        },
        inputs: videoPaths.map((_, i) => `[${i}:v] [${i}:a]`).join(' '),
        outputs: '[outv][outa]',
      },
    ])
        .outputOptions([
          '-map', '[outv]',
          '-map', '[outa]',
          '-c:v', 'libx264',
          '-c:a', 'aac',
          '-preset', 'fast',
          '-movflags', '+faststart',
          '-shortest',
          '-strict', 'experimental',
        ])
        .on('start', (cmd) => console.log('Ejecutando concatenación:', cmd))
        .on('progress', (progress) => console.log(`Progreso: ${progress.percent}%`))
        .on('end', () => {
          console.log('Concatenación completada');
          resolve();
        })
        .on('error', (err, stdout, stderr) => {
          console.error('Error en concatenación:', stderr);
          reject(new Error(`Error al concatenar videos: ${stderr || err.message}`));
        });

    command.save(outputFilePath);
  });
}

// Función para obtener metadatos (versión segura)
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

async function generateThumbnail(videoPath, outputPath) {
  return new Promise((resolve, reject) => {
    execFile('ffmpeg', [
      '-i', videoPath,
      '-ss', '00:00:01', // Captura en el segundo 1
      '-vframes', '1', // Solo 1 frame
      '-q:v', '2', // Calidad del thumbnail (2 es alta calidad)
      '-vf', 'scale=540:960', // Tamaño reducido para thumbnail
      '-y',
      outputPath,
    ], {timeout: 30000}, (error, stdout, stderr) => {
      if (error) return reject(new Error(`FFmpeg thumbnail error: ${stderr}`));
      resolve();
    });
  });
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
