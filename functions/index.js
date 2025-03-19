const { onRequest } = require("firebase-functions/v2/https");
const functions = require('firebase-functions');
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

const { getDeviceToken, sendPushNotification } = require("./notifications/notifications");
const { getUserDataById, getUserDataByPhone } = require("./users/users");
const { getFelicitupById, getFelicitupRefById } = require("./felicitups/felicitups");
const { exec, spawn } = require('child_process');

const fs = require("fs");
const os = require("os");
const path = require("path");
const { ffmpegPath } = require("ffmpeg-static");
const constants = require("./constants/constants");

const bucket = admin.storage().bucket();

const serviceAccount = require("./serviceAccountMergeKey.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: "felicitup-prod.appspot.com",
});

exports.sendNotification = functions.https.onCall(
    async (data, context) => {
        try {
            const userId = data.userId;
            const title = data.title;
            const message = data.message;
            const currentChat = data.currentChat;
            const userData = await getUserDataById(userId);
            const token = await getDeviceToken(userId);
            const dataInfo = data.data;
            
            console.log("Current Chat: " + currentChat);
            console.log("User Data: " + userData.currentChat);
            console.log("data info: " + dataInfo);
            if (!currentChat || userData.currentChat !== currentChat) {
                const payload = {
                    token,
                    notification: {
                        title: title,
                        body: message,
                    },
                    data: dataInfo,
                };
                console.log("Sending Notification to: " + userId);
                await sendPushNotification(payload);
            }

        } catch (e) {
            console.log("Firebase Notification Failed: " + e.message);
            return { error: { message: e.message} };
        }
    });

async function downloadFileToTemp(filePath, tempFilePath) {
    const file = bucket.file(filePath);
    await file.download({ destination: tempFilePath });
    console.log(`Archivo descargado a: ${tempFilePath}`);
}

// Función para normalizar un video (forzar aspect ratio 9/16, resolución 1080x1920, mantener rotación original y normalizar audio)
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

// Función para unir los videos usando el filtro concat de ffmpeg
async function mergeVideosWithConcatFilter(videoPaths, outputFilePath) {
  return new Promise((resolve, reject) => {
    // Crear el comando de ffmpeg con el filtro concat
    const inputArgs = videoPaths.map((path) => `-i ${path}`).join(' ');
    const filterComplex = `"${videoPaths.map((_, i) => `[${i}:v][${i}:a]`).join('')}concat=n=${videoPaths.length}:v=1:a=1[outv][outa]"`;

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
exports.mergeVideos = functions.runWith({
  timeoutSeconds: 540, // 9 minutos (máximo)
  memory: "8GB", // Ejemplo con 2GB (puedes usar 256MB, 512MB, 1GB)
}).https.onCall(async (data, context) => {
  const videoUrls = data.videoUrls; // La lista de URLs que tu app envía
  const outputFileName = `merged-${Date.now()}.mp4`;
  const tempDir = os.tmpdir();
  const outputFilePath = path.join(tempDir, outputFileName);
  const userId = data.userId;
  const felicitupId = data.felicitupId;

  if (!videoUrls || !Array.isArray(videoUrls) || videoUrls.length === 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Debe proporcionar una lista de URLs de videos."
    );
  }

  try {
    // 1. Descargar los videos a archivos temporales
    const tempFiles = [];
    await Promise.all(
      videoUrls.map(async (url, index) => {
        const fileName = `temp-${index}.mp4`;
        const tempFilePath = path.join(tempDir, fileName);
        tempFiles.push(tempFilePath);
        await downloadFileToTemp(url, tempFilePath);
        console.log(`Video ${index} descargado a ${tempFilePath}`);
      })
    );

    // 2. Normalizar los videos (forzar aspect ratio 9/16, resolución 1080x1920, mantener rotación original y normalizar audio)
    const normalizedFiles = [];
    await Promise.all(
      tempFiles.map(async (file, index) => {
        const normalizedFileName = `normalized-${index}.mp4`;
        const normalizedFilePath = path.join(tempDir, normalizedFileName);
        await normalizeVideo(file, normalizedFilePath);
        normalizedFiles.push(normalizedFilePath);
      })
    );

    // 3. Unir los videos usando el filtro concat de ffmpeg
    await mergeVideosWithConcatFilter(normalizedFiles, outputFilePath);

    // 4. Subir el video unido a Firebase Storage
    const destinationPath = `videos/${felicitupId}/${outputFileName}`;
    await bucket.upload(outputFilePath, { destination: destinationPath });
    console.log(`Video subido a ${destinationPath}`);

    // 5. Obtener la URL firmada del video unido
    const mergedFile = bucket.file(destinationPath);
    const [url] = await mergedFile.getSignedUrl({ action: "read", expires: "03-01-2500" });
    console.log(`URL del video unido: ${url}`);

    // 6. Actualizar Firestore con la URL del video unido
    const docRef = await getFelicitupRefById(felicitupId);
    await docRef.update({ finalVideoUrl: url });
    console.log('Documento actualizado exitosamente!');

    // 7. Enviar notificación push al usuario
    const token = await getDeviceToken(userId);
    const payload = {
      token,
      notification: {
        title: 'Felicitup lista',
        body: 'Tu felicitup está lista para ser vista!',
      },
    };
    await sendPushNotification(payload);
    console.log('Notificación push enviada.');

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
      })
    );
  }
});

exports.sendManualFelicitup = functions.https.onCall(async (data, context) => { 
  try {
    const felicitupId = data.felicitupId;

    if (!felicitupId) {
      res.status(400).send('El ID de la felicitup es requerido.');
      return;
    }

    const felicitup = await getFelicitupById(felicitupId);
    const docRef = await getFelicitupRefById(felicitupId);

    const atLeastOneVideo = felicitup.invitedUserDetails.some(user => user.videoData && user.videoData.videoUrl && user.videoData.videoUrl.trim() !== "");

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
        }
        
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
            title: 'Hola, ' + ownerName,
            body: 'Tienes una nueva felicitup lista para ser vista!',
          },
        };
        await sendPushNotification(payload);
      }
    }
    

    await docRef.update({ status: "Finished" });
    deleteFelicitupTask(felicitupId);

  } catch (error) {
    console.error("Error al ejecutar la tarea:", error);
    throw new functions.https.HttpsError("internal", "Error al programar la tarea.", error);
  }
});

exports.generateThumbnail = functions.https.onCall(async (data, context) => {
  const filePath = data.filePath;
  const file = bucket.file(filePath);
  const tempDir = os.tmpdir();

  const fileName = `temp-${index}.mp4`;
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
      "-y"
    ]);
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

exports.checkBirthdays = functions.pubsub.schedule('0 0 * * *') // 00:00 todos los días, UTC.
  .timeZone('UTC')
  .onRun(async (context) => {

    const now = new Date();
    const today = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
    const db = admin.firestore();
    const usersRef = db.collection(constants.usersPath);
    const snapshot = await usersRef
        .where('birthDate.month', '==', today.getUTCMonth() + 1)
        .where('birthDate.day', '==', today.getUTCDate())
        .get();

    if (snapshot.empty) {
      console.log('No hay usuarios que cumplan años hoy.');
      return null;
    }

    for (const userDoc of snapshot.docs) {
      const userData = userDoc.data();
      const userId = userDoc.id;
      const userName = userData.name || 'Un usuario';

      console.log(`Cumpleaños de ${userName} (${userId})`);

      const friends = userData.friends;
      if (!friends || friends.length === 0) {
        console.log(`${userName} no tiene amigos.`);
        continue;
      }

      for (const friendId of friends) {
        // --- Cambios aquí: Actualizar el documento del AMIGO ---

        // Obtener la referencia al documento del amigo.
        const friendDocRef = usersRef.doc(friendId);

        //  Actualizar un campo en el documento del amigo.
        //  Usamos un campo 'birthdayAlerts' (es un array) para almacenar la información.
        try {
          await friendDocRef.update({
            birthdayAlerts: admin.firestore.FieldValue.arrayUnion({
              friendId: userId,
              friendName: userName,
              timestamp: admin.firestore.FieldValue.serverTimestamp(), // ¡Importante!
            }),
          });
          console.log(`Información de cumpleaños agregada al documento de ${friendId}`);

        } catch (error) {
          console.error("Error al actualizar el documento del amigo:", error);
          // Considera manejar el error (reintentar, registrar el error, etc.).
          //  NO uses un 'return' aquí, para que intente con los otros amigos.
        }

        // --- Fin de los cambios ---
      }
    }

    return null;
});