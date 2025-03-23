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
const {exec, spawn} = require("child_process");

const fs = require("fs");
const os = require("os");
const path = require("path");
const {ffmpegPath} = require("ffmpeg-static");
const constants = require("./constants/constants");

const bucket = admin.storage().bucket();

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
        functions.logger.error("Error en sendNotification:", error, {userId: data && data.data ? data.data.userId : undefined}); // Log estructurado.
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

/**
 * Downloads a file from Firebase Storage to a temporary local path.
 * @param {string} filePath - The path of the file in the Firebase Storage bucket.
 * @param {string} tempFilePath - The local temporary file path where the file will be downloaded.
 * @return {Promise<void>} - Resolves when the file is successfully downloaded.
 */
async function downloadFileToTemp(filePath, tempFilePath) {
  const file = bucket.file(filePath);
  await file.download({destination: tempFilePath});
  console.log(`Archivo descargado a: ${tempFilePath}`);
}

/**
 * Normalizes a video by forcing aspect ratio 9/16, resolution 1080x1920, maintaining original rotation, and normalizing audio.
 * @param {string} inputPath - The path to the input video file.
 * @param {string} outputPath - The path to save the normalized video file.
 * @return {Promise<void>} - Resolves when the video is successfully normalized.
 */
async function normalizeVideo(inputPath, outputPath) {
  return new Promise((resolve, reject) => {
    const ffmpegCommand = `ffmpeg -i ${inputPath} -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" -c:v libx264 -c:a aac -strict experimental -r 30 ${outputPath}`;

    exec(ffmpegCommand, (error, stdout, stderr) => {
      if (error) {
        console.error("Error al normalizar el video:", error);
        console.error("Salida de error de FFmpeg:", stderr);
        reject(new functions.https.HttpsError("internal", "Error al normalizar el video", error));
        return;
      }
      console.log("Video normalizado exitosamente!");
      console.log("Salida de FFmpeg:", stdout);
      resolve();
    });
  });
}

/**
 * Merges multiple video files into one using the FFmpeg concat filter.
 * @param {string[]} videoPaths - Array of paths to the video files to be merged.
 * @param {string} outputFilePath - The path to save the merged video file.
 * @return {Promise<void>} - Resolves when the videos are successfully merged.
 */
async function mergeVideosWithConcatFilter(videoPaths, outputFilePath) {
  return new Promise((resolve, reject) => {
    // Crear el comando de ffmpeg con el filtro concat
    const inputArgs = videoPaths.map((path) => `-i ${path}`).join(" ");
    const filterComplex = `"${videoPaths.map((_, i) => `[${i}:v][${i}:a]`).join("")}concat=n=${videoPaths.length}:v=1:a=1[outv][outa]"`;

    const ffmpegCommand = `ffmpeg ${inputArgs} -filter_complex ${filterComplex} -map "[outv]" -map "[outa]" -c:v libx264 -c:a aac -strict experimental ${outputFilePath}`;

    exec(ffmpegCommand, (error, stdout, stderr) => {
      if (error) {
        console.error("Error al unir los videos:", error);
        console.error("Salida de error de FFmpeg:", stderr);
        reject(new functions.https.HttpsError("internal", "Error al unir los videos", error));
        return;
      }
      console.log("Videos unidos exitosamente!");
      console.log("Salida de FFmpeg:", stdout);
      resolve();
    });
  });
}

// Función principal
exports.mergeVideos = functions.https.onCall({
  region: "us-central1",
  timeoutSeconds: 540,
  memory: "8GiB",
}, async (data, context) => {
  const videoUrls = data.data.videoUrls; // La lista de URLs que tu app envía
  const outputFileName = `merged-${Date.now()}.mp4`;
  const tempDir = os.tmpdir();
  const outputFilePath = path.join(tempDir, outputFileName);
  const userId = data.data.userId;
  const felicitupId = data.data.felicitupId;

  if (!videoUrls || !Array.isArray(videoUrls) || videoUrls.length === 0) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Debe proporcionar una lista de URLs de videos.",
    );
  }

  let tempFiles = [];
  try {
    // 1. Descargar los videos a archivos temporales
    tempFiles = [];
    await Promise.all(
        videoUrls.map(async (url, index) => {
          const fileName = `temp-file.mp4`;
          const tempFilePath = path.join(tempDir, fileName);
          tempFiles.push(tempFilePath);
          await downloadFileToTemp(url, tempFilePath);
          console.log(`Video ${index} descargado a ${tempFilePath}`);
        }),
    );

    // 2. Normalizar los videos (forzar aspect ratio 9/16, resolución 1080x1920, mantener rotación original y normalizar audio)
    const normalizedFiles = [];
    await Promise.all(
        tempFiles.map(async (file, index) => {
          const normalizedFileName = `normalized-${index}.mp4`;
          const normalizedFilePath = path.join(tempDir, normalizedFileName);
          await normalizeVideo(file, normalizedFilePath);
          normalizedFiles.push(normalizedFilePath);
        }),
    );

    // 3. Unir los videos usando el filtro concat de ffmpeg
    await mergeVideosWithConcatFilter(normalizedFiles, outputFilePath);

    // 4. Subir el video unido a Firebase Storage
    const destinationPath = `videos/${felicitupId}/${outputFileName}`;
    await bucket.upload(outputFilePath, {destination: destinationPath});
    console.log(`Video subido a ${destinationPath}`);

    // 5. Obtener la URL firmada del video unido
    const mergedFile = bucket.file(destinationPath);
    const [url] = await mergedFile.getSignedUrl({action: "read", expires: "03-01-2500"});
    console.log(`URL del video unido: ${url}`);

    // 6. Actualizar Firestore con la URL del video unido
    const docRef = await getFelicitupRefById(felicitupId);
    await docRef.update({finalVideoUrl: url});
    console.log("Documento actualizado exitosamente!");

    // 7. Enviar notificación push al usuario
    const token = await getDeviceToken(userId);
    const payload = {
      token,
      notification: {
        title: "Felicitup lista",
        body: "Tu felicitup está lista para ser vista!",
      },
    };
    await sendPushNotification(payload);
    console.log("Notificación push enviada.");
  } catch (error) {
    console.error("Error en la función:", error);
    throw new functions.https.HttpsError("internal", "Error en la función", error);
  } finally {
    // 8. Eliminar archivos temporales
    const filesToDelete = [outputFilePath, ...tempFiles];
    await Promise.all(
        filesToDelete.map((file) => {
          if (fs.existsSync(file)) {
            fs.unlinkSync(file);
            console.log(`Archivo temporal ${file} eliminado`);
          } else {
            console.log(`El archivo temporal ${file} no existe`);
          }
        }),
    );
  }
});

exports.sendManualFelicitup = functions.https.onCall(async (data) => {
  try {
    const felicitupId = data.felicitupId;

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

exports.generateThumbnail = functions.https.onCall(async (data) => {
  const filePath = data.filePath;
  const file = bucket.file(filePath);
  const tempDir = os.tmpdir();

  const fileName = `temp-temp_file.mp4`;
  const tempFilePath = path.join(tempDir, fileName);

  try {
    await downloadFileToTemp(file, tempFilePath);
  } catch (error) {
    throw new functions.https.HttpsError("Error de descarga", "Error en la función", error);
  }

  const thumbFileName = `thumb_${fileName.substring(0, fileName.lastIndexOf("."))}.jpg`;
  const tempThumbPath = path.join(os.tmpdir(), thumbFileName);

  try {
    spawn(ffmpegPath, [
      "-i",
      tempFilePath,
      "-ss",
      "00:00:01",
      "-vframes",
      "1",
      "-q:v",
      "2",
      tempThumbPath,
      "-y",
    ]);
    const felicitupId = data.felicitupId;

    if (!felicitupId) {
      throw new functions.https.HttpsError("invalid-argument", "El ID de la felicitup es requerido.");
    }

    const docRef = await getFelicitupRefById(felicitupId);
    const felicitup = await docRef.get();

    if (!felicitup.exists) {
      throw new functions.https.HttpsError("not-found", "No se encontró la felicitup.");
    }

    const invitedUserDetails = felicitup.data().invitedUserDetails || [];
    const userId = data.userId;

    const updatedDetails = invitedUserDetails.map((user) => {
      if (user.id === userId) {
        return {
          ...user,
          videoData: {
            ...user.videoData,
            videoThumbnail: tempThumbPath,
          },
        };
      }
      return user;
    });

    await docRef.update({invitedUserDetails: updatedDetails});
    console.log("Miniatura asignada correctamente en la felicitup.");
    console.log("Miniatura generada en:", tempThumbPath);
  } catch (error) {
    console.error("Error al generar la miniatura:", error);
    fs.unlinkSync(tempFilePath);
    if (fs.existsSync(tempThumbPath)) {
      fs.unlinkSync(tempThumbPath);
    }
    return;
  }
});

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
    const alertsToRemove = userDoc.data().birthdayAlerts.filter((alert) => alert.id === id); // Filtra las alertas

    // Usa Promise all para ejecutar las promesas al tiempo
    await Promise.all(alertsToRemove.map((alert) =>
      db.collection(constants.usersPath).doc(userId).update({
        birthdayAlerts: admin.firestore.FieldValue.arrayRemove(alert),
      }),
    ));
    console.log(`Alertas de cumpleaños eliminada para el usuario ${userId}`);
    return {message: "Tarea programada exitosamente."}; // Devuelve un mensaje
  } catch (error) {
    console.error("Error al programar la tarea:", error);
    throw new functions.https.HttpsError("internal", "Error al programar la tarea.", error);
  }
};

exports.checkBirthdays = functions.https.onRequest( // Cambio a https.onRequest
    {
      schedule: "0 0 * * *", //  Cron schedule.
      region: "us-central1", //  ¡SIEMPRE especifica la región!  Cambia a tu región.
      timeZone: "UTC", //  ¡SIEMPRE especifica la zona horaria!
      timeoutSeconds: 300, //  Opcional:  Aumenta el timeout si es necesario (máximo 540s para onRequest)
      memory: "256MiB", //  Opcional:  Ajusta la memoria si es necesario.
    },
    async (req, res) => { //  onRun cambia a onRequest, y recibe req, res.
      const now = new Date();
      const today = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
      const db = admin.firestore();
      const usersRef = db.collection(constants.usersPath); //  Asegúrate de que 'constants' esté definido.

      try {
        const snapshot = await usersRef
            .where("birthDate.month", "==", today.getUTCMonth() + 1)
            .where("birthDate.day", "==", today.getUTCDate())
            .get();

        if (snapshot.empty) {
          functions.logger.info("No hay usuarios que cumplan años hoy."); // Usa functions.logger
          res.status(200).send("No birthdays today"); // Respuesta en lugar de return null
          return;
        }

        for (const userDoc of snapshot.docs) {
          const userData = userDoc.data();
          const userId = userDoc.id;
          const userName = userData.name || "Un usuario";
          const friendProfilePic = userData.userImg || "";

          functions.logger.info(`Cumpleaños de ${userName} (${userId})`); // Usa functions.logger

          const friends = userData.friends;
          if (!friends || friends.length === 0) {
            functions.logger.info(`${userName} no tiene amigos.`); // Usa functions.logger
            continue;
          }

          for (const friendId of friends) {
            const friendDocRef = usersRef.doc(friendId);

            try {
              // Verificamos que exista
              const friendDoc = await friendDocRef.get();
              if (friendDoc.exists) { // Si existe
                const id = admin.firestore.FieldValue.serverTimestamp().toMillis().toString() + "-" + friendId;
                await friendDocRef.update({
                  birthdayAlerts: admin.firestore.FieldValue.arrayUnion({
                    id: id,
                    friendId: userId,
                    friendName: userName,
                    friendProfilePic: friendProfilePic,
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                  }),
                });
                // Llama a la función auxiliar *después* de actualizar Firestore.
                await deleterBirthdayAlert(userId, id);
                functions.logger.info(`Información de cumpleaños agregada al documento de ${friendId}`);
              } else {
                functions.logger.info(`El amigo con id ${friendId} no existe`);
              }
            } catch (error) {
              functions.logger.error("Error al actualizar el documento del amigo:", error, {userId, friendId}); // Log estructurado.
              //  NO uses 'return' aquí. Continúa con los otros amigos.
            }
          }
        }

        res.status(200).send("Birthday check completed"); // Responde
      } catch (error) {
        functions.logger.error("Error en checkBirthdays", error);
        res.status(500).send("Internal Server Error");
      }
    },
);

// exports.deleterBirthdayAlert = functions.region("us-central1").https.onCall(async (data) => {
//   const userId = data.userId;
//   const id = data.id;

//   if (!userId) {
//     throw new functions.https.HttpsError("invalid-argument", "El ID del usuario es requerido.");
//   }

//   const db = admin.firestore();
//   const usersRef = db.collection(constants.usersPath);
//   const userDoc = await usersRef.doc(userId).get();
//   try {
//     const now = admin.firestore.Timestamp.now();
//     const executionTime = new Date(now.toDate().getTime() + 24 * 60 * 60 * 1000); // 24 horas después
//     userDoc.data().birthdayAlerts.forEach(async (alert) => {
//       if (alert.id === id) {
//         await db.collection(constants.usersPath).doc(userId).update({
//           birthdayAlerts: admin.firestore.FieldValue.arrayRemove(alert),
//         });
//         console.log(`Alerta de cumpleaños eliminada para el usuario ${userId}`);
//       }
//     },
//     );

//     console.log(`Tarea programada para el usuario ${userId} a las ${executionTime}`);
//     return {message: "Tarea programada exitosamente."};
//   } catch (error) {
//     console.error("Error al programar la tarea:", error);
//     throw new functions.https.HttpsError("internal", "Error al programar la tarea.", error);
//   }
// });
