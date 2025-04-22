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
          status: 'scheduled',
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
        };
        await sendPushNotification(payload);
      }
    }

    // Marcar como completada
    await felicitupRef.update({
      status: "Finished",
      completedAt: Timestamp.now(),
    });

    console.log(`Felicitup ${felicitupId} completada exitosamente`);
  } catch (error) {
    console.error(`Error al completar la Felicitup ${felicitupId}:`, error);
    await felicitupRef.update({status: "failed"});
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

// Función para concatenar videos (versión corregida)
async function concatVideos(videoPaths, outputFilePath) {
  return new Promise((resolve, reject) => {
    const listFilePath = `${outputFilePath}.txt`;

    try {
      // Eliminé el 'outpoint 1' que causaba el problema de duración
      const fileList = videoPaths.map((p) => `file '${p}'`).join('\n');
      fs.writeFileSync(listFilePath, fileList);
    } catch (err) {
      return reject(new Error(`Error creating file list: ${err.message}`));
    }

    execFile('ffmpeg', [
      '-f', 'concat',
      '-safe', '0',
      '-i', listFilePath,
      '-c:v', 'libx264',
      '-profile:v', 'high',
      '-preset', 'fast',
      '-r', '30',
      '-g', '60',
      '-keyint_min', '60',
      '-sc_threshold', '0',
      '-movflags', '+faststart',
      '-c:a', 'aac',
      '-b:a', '128k',
      '-ar', '44100',
      '-ac', '2',
      '-vsync', 'cfr',
      '-async', '1',
      '-filter_complex', 'apad',
      '-shortest',
      '-y',
      outputFilePath,
    ], {timeout: 600000}, (error, stdout, stderr) => {
      // Limpieza del archivo temporal
      try {
        fs.unlinkSync(listFilePath);
      } catch (e) {
        console.warn('Could not delete temp list file:', e);
      }

      if (error) {
        console.error('FFmpeg stderr:', stderr);
        return reject(new Error(`FFmpeg concat failed: ${error.message}`));
      }

      if (!fs.existsSync(outputFilePath)) {
        return reject(new Error('Output file not created'));
      }

      // Verificar la duración del video resultante
      getVideoMetadata(outputFilePath)
          .then((metadata) => {
            console.log('Merged video duration:', metadata.duration);
            resolve();
          })
          .catch((e) => {
            console.warn('Could not verify output duration:', e);
            resolve(); // Resolvemos igual aunque no podamos verificar
          });
    });
  });
}

// Función para normalizar videos (versión optimizada)
async function normalizeVideo(inputPath, outputPath) {
  return new Promise((resolve, reject) => {
    execFile('ffmpeg', [
      '-i', inputPath,
      '-c:v', 'libx264',
      '-profile:v', 'high',
      '-preset', 'fast',
      '-r', '30',
      '-g', '60',
      '-keyint_min', '60',
      '-sc_threshold', '0',
      '-movflags', '+faststart',
      '-c:a', 'aac',
      '-b:a', '128k',
      '-ar', '44100',
      '-ac', '2',
      '-filter_complex',
      '[0:v]scale=w=1080:h=1920:force_original_aspect_ratio=decrease,' +
      'pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1[outv]',
      '-map', '[outv]',
      '-map', '0:a?',
      '-af', 'aresample=async=1000',
      '-y',
      outputPath,
    ], {timeout: 300000}, (error, stdout, stderr) => {
      if (error) {
        console.error('FFmpeg error details:', stderr);
        return reject(new Error(`FFmpeg error: ${stderr}`));
      }

      // Verificar que el video normalizado tenga la duración correcta
      getVideoMetadata(outputPath)
          .then((metadata) => {
            console.log(`Normalized video duration: ${metadata.duration}s`);
            resolve();
          })
          .catch((e) => {
            console.warn('Could not verify normalized video duration:', e);
            resolve(); // Continuamos aunque no podamos verificar
          });
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

const deleterBirthdayAlert = async (userId, id) => {
  if (!userId) {
    throw new functions.https.HttpsError("invalid-argument", "El ID del usuario es requerido.");
  }

  const db = admin.firestore();
  const usersRef = db.collection(constants.usersPath);
  const userDoc = await usersRef.doc(userId).get();

  if (!userDoc.exists) { // <--- ¡Importante! Verifica si el documento existe.
    console.log(`Usuario con ID ${userId} no encontrado.`);
    return; // O maneja el error como sea apropiado.
  }

  try {
    const alertsToRemove = userDoc.data().birthdateAlerts.filter((alert) => alert.id === id); // Filtra las alertas

    // Usa Promise all para ejecutar las promesas al tiempo
    await Promise.all(alertsToRemove.map((alert) =>
      db.collection(constants.usersPath).doc(userId).update({
        birthdateAlerts: admin.firestore.FieldValue.arrayRemove(alert),
      }),
    ));
    console.log(`Alertas de cumpleaños eliminada para el usuario ${userId}`);
    return {message: "Tarea programada exitosamente."}; // Devuelve un mensaje
  } catch (error) {
    console.error("Error al programar la tarea:", error);
    throw new functions.https.HttpsError("internal", "Error al programar la tarea.", error);
  }
};

exports.checkBirthdays = onSchedule({
  schedule: 'every 24 hours',
  timeZone: 'UTC',
  timeoutSeconds: 300,
  memory: '512MiB',
}, async (event) => {
  const db = admin.firestore();
  const usersRef = db.collection(constants.usersPath);
  const today = new Date();

  try {
    // Procesar para hoy + 4 días siguientes
    for (let dayOffset = 0; dayOffset < 5; dayOffset++) {
      const targetDate = new Date(today);
      targetDate.setDate(today.getDate() + dayOffset);

      const targetMonth = targetDate.getUTCMonth() + 1;
      const targetDay = targetDate.getUTCDate();

      const birthdayUsers = await usersRef
          .where("birthMonth", "==", targetMonth)
          .where("birthDay", "==", targetDay)
          .get();

      for (const userDoc of birthdayUsers.docs) {
        await processBirthdayUser(userDoc, dayOffset, db);
      }
    }
  } catch (error) {
    console.error("Error en checkBirthdays:", error);
    throw error;
  }
});

async function processBirthdayUser(userDoc, dayOffset, db) {
  const birthdayUser = userDoc.data();
  const birthdayUserId = userDoc.id;
  const usersRef = db.collection(constants.usersPath);

  // Verificar si el usuario tiene matchList
  if (!birthdayUser.matchList || birthdayUser.matchList.length === 0) {
    console.log(`Usuario ${birthdayUserId} no tiene matchList`);
    return;
  }

  // Procesar cada amigo en matchList
  for (const friendId of birthdayUser.matchList) {
    await verifyAndCreateAlert(birthdayUser, birthdayUserId, friendId, dayOffset, usersRef);
  }
}

async function verifyAndCreateAlert(birthdayUser, birthdayUserId, friendId, dayOffset, usersRef) {
  try {
    const friendDoc = await usersRef.doc(friendId).get();

    // Verificar existencia del amigo y su matchList
    if (!friendDoc.exists) {
      console.log(`Amigo ${friendId} no encontrado`);
      return;
    }

    const friendData = friendDoc.data();

    // Validación bidireccional: ¿El amigo también tiene al usuario en su matchList?
    if (!friendData.matchList || !friendData.matchList.includes(birthdayUserId)) {
      console.log(`Relación no recíproca entre ${birthdayUserId} y ${friendId}`);
      return;
    }

    // Verificar si ya existe alerta
    const existingAlerts = friendData.birthdateAlerts || [];
    const alertExists = existingAlerts.some((alert) =>
      alert.friendId === birthdayUserId &&
      alert.daysOffset === dayOffset,
    );

    if (alertExists) {
      console.log(`Alerta ya existe para ${birthdayUserId} en ${friendId}`);
      return;
    }

    // Crear nueva alerta
    const newAlert = {
      id: `${birthdayUserId}-${friendId}-${Date.now()}`,
      friendId: birthdayUserId,
      friendName: birthdayUser.name || `Usuario ${birthdayUserId}`,
      friendProfilePic: birthdayUser.userImg || "",
      daysOffset: dayOffset,
      targetDate: formatDate(addDays(new Date(), dayOffset)),
    };

    await usersRef.doc(friendId).update({
      birthdateAlerts: admin.firestore.FieldValue.arrayUnion(newAlert),
    });

    await deleterBirthdayAlert(friendId, `${birthdayUserId}-${friendId}-${Date.now()}`);

    // Enviar notificación si tiene token
    if (friendData.fcmToken) {
      await sendBirthdayNotification(
          friendData.fcmToken,
          birthdayUser.name,
          dayOffset,
      );
    }

    console.log(`Alerta creada para ${friendId} sobre cumpleaños de ${birthdayUserId}`);
  } catch (error) {
    console.error(`Error procesando amigo ${friendId}:`, error);
  }
}

async function sendBirthdayNotification(friendData, userName, dayOffset) {
  if (!friendData.fcmToken) return;

  const daysText = dayOffset === 0 ? "hoy" : `en ${dayOffset} día(s)`;
  const notification = {
    token: friendData.fcmToken,
    notification: {
      title: "🎉 Recordatorio de cumpleaños",
      body: `${userName} cumple años ${daysText}!`,
    },
    data: {
      "type": "reminder",
      "felicitupId": "",
      "chatId": "",
      "name": "",
      "friendId": "",
      "userImage": "",
    },
  };

  try {
    await admin.messaging().send(notification);
  } catch (error) {
    console.error("Error enviando notificación FCM:", error);
  }
}

function addDays(date, days) {
  const result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}

// exports.checkBirthdays = onSchedule({
//   schedule: 'every 24 hours',
//   timeZone: 'UTC',
//   timeoutSeconds: 300,
//   memory: '256MiB',
// }, async (event) => {
//   const today = new Date();
//   const currentMonth = today.getUTCMonth() + 1;
//   const currentDay = today.getUTCDate();
//   const db = admin.firestore();
//   const usersRef = db.collection(constants.usersPath);

//   try {
//     const snapshot = await usersRef
//         .where("birthMonth", "==", currentMonth)
//         .where("birthDay", "==", currentDay)
//         .get();

//     if (snapshot.empty) {
//       console.log("No hay usuarios que cumplan años hoy.");
//       return;
//     }

//     for (const userDoc of snapshot.docs) {
//       const userData = userDoc.data();
//       const userId = userDoc.id;
//       const userName = userData.name || "Un usuario";
//       const friendProfilePic = userData.userImg || "";

//       console.log(`Cumpleaños de ${userName} (${userId})`);

//       const friends = userData.matchList || [];
//       if (friends.length === 0) {
//         console.log(`${userName} no tiene amigos.`);
//         continue;
//       }

//       for (const friendId of friends) {
//         const friendDocRef = usersRef.doc(friendId);

//         try {
//           const friendDoc = await friendDocRef.get();
//           if (friendDoc.exists) {
//             // Verificar si ya existe una alerta para este usuario
//             const existingAlerts = friendDoc.data().birthdateAlerts || [];
//             const alreadyExists = existingAlerts.some(
//                 (alert) => alert.friendId === userId,
//             );

//             if (alreadyExists) {
//               console.log(`Alerta de cumpleaños para ${userName} ya existe en ${friendId}`);
//               continue;
//             }

//             // Generar ID único
//             const id = `${userId}-${friendId}-${Date.now()}`;

//             await friendDocRef.update({
//               birthdateAlerts: admin.firestore.FieldValue.arrayUnion({
//                 id: id,
//                 friendId: userId,
//                 friendName: userName,
//                 friendProfilePic: friendProfilePic,
//               }),
//             });

//             await admin.messaging().send({
//               token: friendDoc.data().fcmToken,
//               notification: {
//                 title: "Recordatorio de cumpleaños",
//                 body: `${userDoc.data().firstName} cumpleaños hoy!`,
//               },
//               data: {
//                 "type": "reminder",
//                 "felicitupId": "",
//                 "chatId": "",
//                 "name": "",
//                 "friendId": "",
//                 "userImage": "",
//               },
//             });

//             await deleterBirthdayAlert(userId, id);
//             console.log(`Información de cumpleaños agregada al documento de ${friendId}`);
//           } else {
//             console.log(`El amigo con id ${friendId} no existe`);
//           }
//         } catch (error) {
//           console.error("Error al actualizar el documento del amigo:", error, {userId, friendId});
//         }
//       }
//     }
//   } catch (error) {
//     console.error("Error en checkBirthdays", error);
//     throw error;
//   }
// });

exports.createBirthdayReminders = onSchedule({
  schedule: 'every 24 hours',
  timeZone: 'UTC',
  timeoutSeconds: 300,
}, async () => {
  try {
    const today = new Date();
    // const currentYear = today.getUTCFullYear();
    const db = admin.firestore();

    // Evaluar los próximos 3 días
    for (let daysToAdd = 1; daysToAdd <= 3; daysToAdd++) {
      const targetDate = new Date(today);
      targetDate.setDate(today.getDate() + daysToAdd);

      const targetMonth = targetDate.getUTCMonth() + 1;
      const targetDay = targetDate.getUTCDate();
      const formattedTargetDate = formatDate(targetDate);

      // Buscar usuarios que cumplen años en esta fecha
      const birthdayUsers = await db.collection('Users')
          .where('birthMonth', '==', targetMonth)
          .where('birthDay', '==', targetDay)
          .get();

      if (!birthdayUsers.empty) {
        for (const birthdayUserDoc of birthdayUsers.docs) {
          const birthdayUser = birthdayUserDoc.data();
          const birthdayUserId = birthdayUserDoc.id;

          // Verificar si el usuario tiene amigos
          if (birthdayUser.friends && birthdayUser.friends.length > 0) {
            for (const friendId of birthdayUser.friends) {
              try {
                const friendRef = db.collection('Users').doc(friendId);
                const friendDoc = await friendRef.get();

                if (friendDoc.exists) {
                  const friendData = friendDoc.data();
                  const existingReminders = friendData.reminders || [];

                  // Verificar si ya existe un recordatorio para este cumpleaños
                  const reminderExists = existingReminders.some((reminder) =>
                    reminder.birthdayUserId === birthdayUserId &&
                    reminder.targetDate === formattedTargetDate,
                  );

                  if (!reminderExists) {
                    const newReminder = {
                      birthdayUserId: birthdayUserId,
                      birthdayUserName: birthdayUser.name || 'A friend',
                      targetDate: formattedTargetDate,
                      createdAt: admin.firestore.FieldValue.serverTimestamp(),
                      status: 'pending',
                      profileImage: birthdayUser.userImg || '',
                      notificationSent: false,
                    };

                    // Actualizar el array de reminders del amigo
                    await friendRef.update({
                      reminders: admin.firestore.FieldValue.arrayUnion(newReminder),
                    });

                    console.log(`Reminder created for friend ${friendId} about ${birthdayUser.name}'s birthday on ${formattedTargetDate}`);
                  }
                }
              } catch (error) {
                console.error(`Error processing friend ${friendId} for user ${birthdayUserId}:`, error);
              }
            }
          }
        }
      }
    }

    console.log('Birthday reminders creation process completed');
  } catch (error) {
    console.error('Error in createBirthdayReminders:', error);
    throw error;
  }
});

function formatDate(date) {
  const year = date.getUTCFullYear();
  const month = String(date.getUTCMonth() + 1).padStart(2, '0');
  const day = String(date.getUTCDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}
