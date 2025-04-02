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
const {exec, spawn, execFile} = require("child_process");

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

async function getVideoMetadata(filePath) {
  return new Promise((resolve, reject) => {
    exec(`ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,rotation -of json ${filePath}`,
        (error, stdout, stderr) => {
          if (error) {
            console.error(`Error en ffprobe: ${stderr}`);
            return reject(error);
          }
          try {
            const metadata = JSON.parse(stdout).streams[0];
            resolve(metadata);
          } catch (parseError) {
            reject(parseError);
          }
        });
  });
}

async function normalizeVideoCodec(inputPath, outputPath) {
  return new Promise((resolve, reject) => {
    const command = [
      "ffmpeg",
      "-i", inputPath,
      "-c:v", "libx264",
      "-profile:v", "high",
      "-preset", "slow",
      "-crf", "23",
      "-pix_fmt", "yuv420p",
      "-movflags", "+faststart",
      "-vf", "\"scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1\"",
      "-c:a", "aac",
      "-b:a", "128k",
      "-r", "30",
      "-y", outputPath,
    ].join(" ");

    exec(command, {timeout: 300000}, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error en normalización: ${stderr}`);
        return reject(new Error(`FFmpeg error: ${stderr}`));
      }
      resolve();
    });
  });
}

async function convertHEVC(inputPath, outputPath) {
  return new Promise((resolve, reject) => {
    const command = [
      "ffmpeg",
      "-i", inputPath,
      "-c:v", "libx264",
      "-profile:v", "high",
      "-preset", "slower",
      "-tag:v", "avc1",
      "-vf", "\"scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black\"",
      "-c:a", "aac",
      "-b:a", "128k",
      "-movflags", "+faststart",
      "-y", outputPath,
    ].join(" ");

    exec(command, {timeout: 300000}, (error) => {
      if (error) return reject(error);
      resolve();
    });
  });
}

async function attemptFallbackConversion(inputPath, outputPath) {
  return new Promise((resolve, reject) => {
    const command = [
      "ffmpeg",
      "-i", inputPath,
      "-c:v", "libx264",
      "-preset", "ultrafast",
      "-vf", "\"scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black\"",
      "-c:a", "copy",
      "-y", outputPath,
    ].join(" ");

    exec(command, {timeout: 300000}, (error) => {
      if (error) reject(new Error(`Fallback conversion failed`));
      else resolve();
    });
  });
}

async function smartNormalize(inputPath, outputPath) {
  try {
    const metadata = await getVideoMetadata(inputPath);

    if (metadata.codec_name === "hevc") {
      console.log("Detectado video HEVC (iOS), aplicando conversión específica");
      return await convertHEVC(inputPath, outputPath);
    } else if (metadata.codec_name === "h264") {
      console.log("Detectado video H.264 (Android), aplicando normalización estándar");
      return await normalizeVideoCodec(inputPath, outputPath);
    } else {
      console.log("Códec no estándar detectado, aplicando normalización genérica");
      return await normalizeVideoCodec(inputPath, outputPath);
    }
  } catch (error) {
    console.warn(`No se pudieron leer metadatos, usando normalización genérica: ${error.message}`);
    try {
      return await normalizeVideoCodec(inputPath, outputPath);
    } catch (normalizeError) {
      console.error(`Normalización estándar falló, intentando fallback: ${normalizeError.message}`);
      return await attemptFallbackConversion(inputPath, outputPath);
    }
  }
}

async function downloadFileToTemp(filePath, tempFilePath) {
  const file = bucket.file(filePath);
  await file.download({destination: tempFilePath});
  console.log(`Archivo descargado a: ${tempFilePath}`);
}

async function mergeVideosWithConcatFilter(videoPaths, outputFilePath) {
  return new Promise((resolve, reject) => {
    // Verificar que los archivos existen
    videoPaths.forEach((path) => {
      if (!fs.existsSync(path)) {
        return reject(new Error(`Archivo ${path} no existe`));
      }
    });

    // Crear un archivo temporal con la lista de videos
    const listFilePath = `${outputFilePath}.txt`;
    const fileList = videoPaths.map((path) => `file '${path}'`).join('\n');

    try {
      fs.writeFileSync(listFilePath, fileList);
    } catch (err) {
      return reject(new Error(`Error al crear archivo de lista: ${err.message}`));
    }

    // Argumentos para ffmpeg (concatenación simple)
    const args = [
      '-f', 'concat',
      '-safe', '0',
      '-i', listFilePath,
      '-c', 'copy', // Copiar los streams sin re-codificar
      '-movflags', '+faststart',
      '-y', outputFilePath,
    ];

    console.log('Ejecutando ffmpeg con args:', ['ffmpeg', ...args].join(' '));

    const ffmpegProcess = execFile(
        'ffmpeg',
        args,
        {timeout: 600000, maxBuffer: 1024 * 1024 * 64},
        (error, stdout, stderr) => {
        // Eliminar el archivo de lista temporal
          try {
            fs.unlinkSync(listFilePath);
          } catch (err) {
            console.warn('No se pudo eliminar el archivo temporal', listFilePath);
          }

          if (error) {
            console.error('Error FFmpeg:', {error, stdout, stderr});
            reject(new Error(`FFmpeg falló: ${stderr}`));
            return;
          }
          resolve();
        },
    );

    ffmpegProcess.stdout.on('data', (data) => {
      console.log('FFmpeg stdout:', data.toString());
    });

    ffmpegProcess.stderr.on('data', (data) => {
      console.error('FFmpeg stderr:', data.toString());
    });
  });
}

// async function mergeVideosWithConcatFilter(videoPaths, outputFilePath) {
//   return new Promise((resolve, reject) => {
//     // Verificar que los archivos existen
//     videoPaths.forEach((path) => {
//       if (!fs.existsSync(path)) {
//         return reject(new Error(`Archivo ${path} no existe`));
//       }
//     });

//     // Construir el comando como ARRAY (evitando problemas de escapado)
//     const args = [
//       ...videoPaths.flatMap((path) => ['-i', path]),
//       // ... agregar más inputs si es necesario
//       '-filter_complex',
//       // Filtros de escala/pad para cada input
//       `[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,` +
//       `pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1[v0];` +
//       `[1:v]scale=1080:1920:force_original_aspect_ratio=decrease,` +
//       `pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1[v1];` +
//       // Concatenación
//       `[v0][0:a][v1][1:a]concat=n=2:v=1:a=1[outv][outa]`,
//       '-map', '[outv]',
//       '-map', '[outa]',
//       '-c:v', 'libx264',
//       '-preset', 'fast',
//       '-crf', '23',
//       '-c:a', 'aac',
//       '-b:a', '128k',
//       '-movflags', '+faststart',
//       '-y', outputFilePath,
//     ];

//     console.log('Ejecutando ffmpeg con args:', ['ffmpeg', ...args].join(' '));

//     const ffmpegProcess = execFile(
//         'ffmpeg',
//         args, // Array de argumentos (escapado automático)
//         {timeout: 600000, maxBuffer: 1024 * 1024 * 64},
//         (error, stdout, stderr) => {
//           if (error) {
//             console.error('Error FFmpeg:', {error, stdout, stderr});
//             reject(new Error(`FFmpeg falló: ${stderr}`));
//             return;
//           }
//           resolve();
//         },
//     );

//     ffmpegProcess.stdout.on('data', (data) => {
//       console.log('FFmpeg stdout:', data.toString());
//     });

//     ffmpegProcess.stderr.on('data', (data) => {
//       console.error('FFmpeg stderr:', data.toString());
//     });
//   });
// }

// Función principal
exports.mergeVideos = functions.https.onCall({
  region: "us-central1",
  timeoutSeconds: 540,
  memory: "8GiB",
}, async (data, context) => {
  // Validación de entrada
  // if (!context.auth) {
  //   throw new functions.https.HttpsError("unauthenticated", "Debes estar autenticado");
  // }

  const {videoUrls, userId, felicitupId} = data.data;
  if (!videoUrls || !Array.isArray(videoUrls) || videoUrls.length === 0) {
    throw new functions.https.HttpsError("invalid-argument", "Debe proporcionar una lista de URLs de videos.");
  }

  const tempDir = os.tmpdir();
  const outputFileName = `merged-${Date.now()}.mp4`;
  const outputFilePath = path.join(tempDir, outputFileName);
  const tempFiles = [];
  const normalizedFiles = [];

  try {
    // 1. Descargar y normalizar cada video
    for (const [index, url] of videoUrls.entries()) {
      const tempFilePath = path.join(tempDir, `source-${index}.mp4`);
      const normalizedPath = path.join(tempDir, `normalized-${index}.mp4`);

      console.log(`Procesando video ${index + 1}/${videoUrls.length}`);

      await downloadFileToTemp(url, tempFilePath);
      await smartNormalize(tempFilePath, normalizedPath);

      tempFiles.push(tempFilePath);
      normalizedFiles.push(normalizedPath);
    }

    // 2. Unir los videos normalizados
    console.log("Uniendo videos...");
    await mergeVideosWithConcatFilter(normalizedFiles, outputFilePath);

    // 3. Subir el video final a Storage
    const destinationPath = `videos/${felicitupId}/${outputFileName}`;
    await bucket.upload(outputFilePath, {destination: destinationPath});
    console.log(`Video subido a ${destinationPath}`);

    // 4. Obtener URL firmada
    const mergedFile = bucket.file(destinationPath);
    const [url] = await mergedFile.getSignedUrl({action: "read", expires: "03-01-2500"});

    // 5. Actualizar Firestore
    const docRef = admin.firestore().collection("Felicitups").doc(felicitupId);
    await docRef.update({finalVideoUrl: url});

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
        },
      });
    }

    return {success: true, videoUrl: url};
  } catch (error) {
    console.error("Error en mergeVideos:", error);
    throw new functions.https.HttpsError("internal", "Error al procesar los videos", error.message);
  } finally {
    // Limpieza de archivos temporales
    const allTempFiles = [...tempFiles, ...normalizedFiles, outputFilePath];
    await Promise.all(
        allTempFiles.map((file) => {
          if (fs.existsSync(file)) {
            return fs.promises.unlink(file).catch((unlinkError) => {
              console.error(`Error eliminando ${file}:`, unlinkError);
            });
          }
          return Promise.resolve();
        }),
    );
  }
});

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
  const filePath = data.data.filePath;
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
    const userId = data.data.userId;

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
