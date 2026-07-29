import { onCall, HttpsError, CallableRequest } from "firebase-functions/v2/https";
import { onDocumentCreated, FirestoreEvent, QueryDocumentSnapshot } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminStorage, getDb } from "./lib/admin";
import ffmpeg from "fluent-ffmpeg";
import ffmpegPath from "@ffmpeg-installer/ffmpeg";
import ffprobePath from "ffprobe-static";
import { execFile } from "child_process";
import * as fs from "fs-extra";
import * as os from "os";
import * as path from "path";
import { v4 as uuidv4 } from "uuid";

ffmpeg.setFfmpegPath(ffmpegPath.path);
ffmpeg.setFfprobePath(ffprobePath.path);

function extractFilePathFromUrl(fullUrl: string): string {
  try {
    const url = new URL(fullUrl);
    if (url.hostname === "storage.googleapis.com") {
      const pathname = url.pathname;
      const pathSegments = pathname.split("/").filter(Boolean);
      if (pathSegments.length > 1) {
        const filePath = pathSegments.slice(1).join("/");
        return decodeURIComponent(filePath.split("?")[0]);
      }
    }
    const pathSegments = url.pathname.split("/");
    const oIndex = pathSegments.indexOf("o");
    if (oIndex !== -1 && oIndex < pathSegments.length - 1) {
      return decodeURIComponent(pathSegments.slice(oIndex + 1).join("/").split("?")[0]);
    }
    return decodeURIComponent(pathSegments.pop()?.split("?")[0] || fullUrl);
  } catch (error) {
    logger.warn("Error parsing URL, using as-is:", fullUrl);
    return fullUrl;
  }
}

async function cleanupTempFiles(files: string[]): Promise<void> {
  for (const file of files) {
    try {
      if (file && (await fs.pathExists(file))) {
        await fs.remove(file);
        logger.info(`Deleted temp file: ${file}`);
      }
    } catch (e) {
      logger.warn(`Could not delete temp file ${file}:`, e);
    }
  }
}

async function normalizeVideo(inputPath: string, outputPath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    ffmpeg(inputPath)
      .inputOptions(["-analyzeduration 500K", "-probesize 500K"])
      .videoCodec("libx264")
      .audioCodec("aac")
      .outputOptions([
        "-map", "0:v:0",
        "-map", "0:a:0?",
        "-ignore_unknown",
        "-dn",
        "-sn",
        "-profile:v", "baseline",
        "-level", "3.1",
        "-pix_fmt", "yuv420p",
        "-movflags", "+faststart",
        "-preset", "ultrafast",
        "-crf", "23",
        "-b:a", "128k",
        "-ar", "44100",
        "-max_muxing_queue_size", "512",
        "-threads", "2",
        "-x264-params", "ref=3:bframes=0:scenecut=0",
      ])
      .videoFilter("scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1")
      .audioFilter("aresample=async=1000")
      .on("start", (cmd: string) => logger.info("Optimized normalization:", cmd))
      .on("end", () => resolve())
      .on("error", (err: Error) => reject(new Error(`Error al normalizar video: ${err.message}`)))
      .save(outputPath);
  });
}

async function concatVideos(videoPaths: string[], outputFilePath: string): Promise<void> {
  const reversedVideoPaths = [...videoPaths].reverse();
  const totalVideos = reversedVideoPaths.length;

  return new Promise((resolve, reject) => {
    const command = ffmpeg();
    reversedVideoPaths.forEach((videoPath) => {
      command.input(videoPath).inputOptions(["-analyzeduration 500K", "-probesize 500K"]);
    });

    const filterComplex = reversedVideoPaths.map((_, i) => `[${i}:v] [${i}:a]`).join(" ");

    command
      .complexFilter([
        {
          filter: "concat",
          options: { n: totalVideos, v: 1, a: 1 },
          inputs: filterComplex,
          outputs: "[outv][outa]",
        },
      ])
      .outputOptions([
        "-map", "[outv]",
        "-map", "[outa]",
        "-ignore_unknown",
        "-dn",
        "-sn",
        "-c:v", "libx264",
        "-profile:v", "baseline",
        "-level", "3.1",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac",
        "-b:a", "128k",
        "-ar", "44100",
        "-preset", "ultrafast",
        "-movflags", "+faststart",
        "-shortest",
        "-threads", "2",
        "-x264-params", "ref=3:bframes=0:scenecut=0",
      ])
      .on("end", () => resolve())
      .on("error", (err: Error) => {
        reject(new Error(`Error al concatenar videos: ${err.message}`));
      })
      .save(outputFilePath);
  });
}

async function generateThumbnail(videoPath: string, outputPath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const args = [
      "-i", videoPath,
      "-ss", "00:00:01",
      "-vframes", "1",
      "-q:v", "3",
      "-vf", "scale=540:960",
      "-threads", "1",
      "-y",
      outputPath,
    ];

    execFile("ffmpeg", args, { timeout: 15000 }, (error, _stdout, stderr) => {
      if (error) {
        const altArgs = [
          "-i", videoPath,
          "-ss", "00:00:03",
          "-vframes", "1",
          "-q:v", "5",
          "-vf", "scale=270:480",
          "-threads", "1",
          "-y",
          outputPath,
        ];
        execFile("ffmpeg", altArgs, { timeout: 10000 }, (altErr, _altOut, altStderr) => {
          if (altErr) {
            reject(new Error(`Both thumbnail methods failed: ${stderr} | ${altStderr}`));
            return;
          }
          resolve();
        });
        return;
      }
      resolve();
    });
  });
}

async function applyWatermark(inputPath: string, outputPath: string, watermarkPath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const args = [
      "-i", inputPath,
      "-i", watermarkPath,
      "-filter_complex", "[1]format=rgba,colorchannelmixer=aa=0.7,scale=iw*0.2:-1[wm];[0][wm]overlay=W-w-10:H-h-10:format=auto,format=yuv420p",
      "-c:v", "libx264",
      "-preset", "ultrafast",
      "-crf", "24",
      "-c:a", "copy",
      "-movflags", "+faststart",
      "-threads", "2",
      "-x264-params", "ref=3:bframes=0:scenecut=0",
      "-y",
      outputPath,
    ];

    execFile("ffmpeg", args, { timeout: 300000 }, (error, _stdout, stderr) => {
      if (error) {
        const altArgs = [
          "-i", inputPath,
          "-i", watermarkPath,
          "-filter_complex", "[1]format=rgb24,scale=iw*0.2:-1[wm];[0][wm]overlay=W-w-10:H-h-10:format=auto",
          "-c:v", "libx264",
          "-preset", "ultrafast",
          "-crf", "24",
          "-pix_fmt", "yuv420p",
          "-c:a", "copy",
          "-movflags", "+faststart",
          "-threads", "2",
          "-x264-params", "ref=3:bframes=0:scenecut=0",
          "-y",
          outputPath,
        ];
        execFile("ffmpeg", altArgs, { timeout: 300000 }, (altErr, _altOut, altStderr) => {
          if (altErr) {
            reject(new Error(`Both watermark methods failed: ${stderr} | ${altStderr}`));
            return;
          }
          resolve();
        });
        return;
      }
      resolve();
    });
  });
}

export const normalizeSingleVideo = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 540,
    memory: "2GiB",
  },
  async (request: CallableRequest) => {
    const { videoUrl, userId, felicitupId } = request.data?.data || request.data || {};

    if (!videoUrl || !userId || !felicitupId) {
      throw new HttpsError("invalid-argument", "videoUrl, userId and felicitupId are required");
    }

    const db = getDb();
    const bucket = getAdminStorage().bucket();
    const felicitupRef = db.collection("Felicitups").doc(felicitupId);
    const uniqueId = uuidv4();

    try {
      await db.runTransaction(async (t) => {
        const doc = await t.get(felicitupRef);
        if (!doc.exists) throw new HttpsError("not-found", "Felicitup document not found");

        const data = doc.data();
        const invitedUserDetails = data?.invitedUserDetails || [];
        const userIndex = invitedUserDetails.findIndex((u: any) => u.id === userId);
        if (userIndex === -1) throw new HttpsError("not-found", "User not found in invitedUserDetails");

        const userToUpdate = invitedUserDetails[userIndex];
        invitedUserDetails[userIndex] = {
          ...userToUpdate,
          videoData: {
            ...(userToUpdate.videoData || {}),
            processingStatus: "processing",
          },
        };

        t.update(felicitupRef, {
          invitedUserDetails,
          updatedAt: FieldValue.serverTimestamp(),
        });
      });

      const tempDir = os.tmpdir();
      const tempFilePath = path.join(tempDir, `source-${uniqueId}.mp4`);
      const processedPath = path.join(tempDir, `processed-${uniqueId}.mp4`);
      const normalizedFileName = `normalized-${uniqueId}-${path.basename(videoUrl)}`;
      const destinationPath = `normalized-videos/${userId}/${normalizedFileName}`;

      const file = bucket.file(videoUrl);
      await file.download({ destination: tempFilePath });

      await normalizeVideo(tempFilePath, processedPath);
      await bucket.upload(processedPath, { destination: destinationPath });

      const [normalizedVideoUrl] = await bucket.file(destinationPath).getSignedUrl({
        action: "read",
        expires: "03-01-2500",
      });

      let thumbnailUrl: string | null = null;
      try {
        const thumbnailFileName = `thumbnail-${uniqueId}.jpg`;
        const thumbnailTempPath = path.join(tempDir, thumbnailFileName);
        const thumbnailDestinationPath = `thumbnails/${userId}/${thumbnailFileName}`;

        await generateThumbnail(processedPath, thumbnailTempPath);
        await bucket.upload(thumbnailTempPath, { destination: thumbnailDestinationPath });

        const [url] = await bucket.file(thumbnailDestinationPath).getSignedUrl({
          action: "read",
          expires: "03-01-2500",
        });
        thumbnailUrl = url;

        if (await fs.pathExists(thumbnailTempPath)) await fs.remove(thumbnailTempPath);
      } catch (thumbErr) {
        logger.warn("Thumbnail generation failed:", thumbErr);
      }

      await db.runTransaction(async (t) => {
        const doc = await t.get(felicitupRef);
        if (!doc.exists) return;

        const data = doc.data();
        const invitedUserDetails = data?.invitedUserDetails || [];
        const userIndex = invitedUserDetails.findIndex((u: any) => u.id === userId);
        if (userIndex === -1) return;

        const userToUpdate = invitedUserDetails[userIndex];
        invitedUserDetails[userIndex] = {
          ...userToUpdate,
          videoData: {
            ...userToUpdate.videoData,
            videoUrl: normalizedVideoUrl,
            ...(thumbnailUrl && { videoThumbnail: thumbnailUrl }),
            processingStatus: "completed",
          },
        };

        t.update(felicitupRef, {
          invitedUserDetails,
          updatedAt: FieldValue.serverTimestamp(),
        });
      });

      await cleanupTempFiles([tempFilePath, processedPath]);

      return {
        success: true,
        normalizedVideoUrl,
        thumbnailUrl,
        message: "Video normalized successfully",
      };
    } catch (error: unknown) {
      logger.error("Error in normalizeSingleVideo:", error);
      await db.runTransaction(async (t) => {
        const doc = await t.get(felicitupRef);
        if (!doc.exists) return;

        const data = doc.data();
        const invitedUserDetails = data?.invitedUserDetails || [];
        const userIndex = invitedUserDetails.findIndex((u: any) => u.id === userId);
        if (userIndex === -1) return;

        const userToUpdate = invitedUserDetails[userIndex];
        invitedUserDetails[userIndex] = {
          ...userToUpdate,
          videoData: {
            ...userToUpdate.videoData,
            processingStatus: "failed",
            error: (error as Error).message,
          },
        };

        t.update(felicitupRef, {
          invitedUserDetails,
          updatedAt: FieldValue.serverTimestamp(),
        });
      });

      throw new HttpsError("internal", "Video normalization failed", (error as Error).message);
    }
  }
);

export const processVideoMerge = onDocumentCreated(
  {
    document: "VideoMergeJobs/{felicitupId}",
    timeoutSeconds: 540,
    memory: "2GiB",
    maxInstances: 3,
  },
  async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>) => {
    const snap = event.data;
    if (!snap) return;

    const jobData = snap.data();
    const { videoUrls } = jobData || {};
    const { felicitupId } = event.params;
    const db = getDb();
    const bucket = getAdminStorage().bucket();

    if (!videoUrls || !Array.isArray(videoUrls) || videoUrls.length === 0) {
      await snap.ref.update({
        status: "failed",
        error: "Invalid video URLs",
        updatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    const filePaths = videoUrls
      .filter((url: any) => url && typeof url === "string" && url.trim() !== "")
      .map(extractFilePathFromUrl)
      .filter((p: string) => p && p.trim() !== "");

    if (filePaths.length === 0) {
      await snap.ref.update({
        status: "failed",
        error: "No valid file paths found",
        updatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    await snap.ref.update({
      status: "processing",
      startedAt: FieldValue.serverTimestamp(),
      totalVideos: filePaths.length,
      processedVideos: 0,
    });

    const tempDir = os.tmpdir();
    const uniqueId = uuidv4();
    const outputFileName = `merged-${uniqueId}.mp4`;
    const outputFilePath = path.join(tempDir, outputFileName);
    const tempFiles: string[] = [];

    try {
      const concurrencyLimit = 6;
      for (let i = 0; i < filePaths.length; i += concurrencyLimit) {
        const chunk = filePaths.slice(i, i + concurrencyLimit);
        await Promise.all(
          chunk.map(async (filePath: string, idx: number) => {
            const index = i + idx;
            const tempFilePath = path.join(tempDir, `source-${index}-${uniqueId}.mp4`);
            const file = bucket.file(filePath);
            await file.download({ destination: tempFilePath });
            tempFiles.push(tempFilePath);
          })
        );
      }

      await concatVideos(tempFiles, outputFilePath);

      const destinationPath = `videos/${felicitupId}/${outputFileName}`;
      await bucket.upload(outputFilePath, { destination: destinationPath });

      const [finalVideoUrl] = await bucket.file(destinationPath).getSignedUrl({
        action: "read",
        expires: "03-01-2500",
      });

      let thumbnailUrl: string | null = null;
      try {
        const thumbnailFileName = `thumbnail-${uniqueId}.jpg`;
        const thumbnailTempPath = path.join(tempDir, thumbnailFileName);
        const thumbnailDestinationPath = `thumbnails/${felicitupId}/${thumbnailFileName}`;

        await generateThumbnail(outputFilePath, thumbnailTempPath);
        await bucket.upload(thumbnailTempPath, { destination: thumbnailDestinationPath });

        const [url] = await bucket.file(thumbnailDestinationPath).getSignedUrl({
          action: "read",
          expires: "03-01-2500",
        });
        thumbnailUrl = url;
        if (await fs.pathExists(thumbnailTempPath)) await fs.remove(thumbnailTempPath);
      } catch (err) {
        logger.warn("Thumbnail generation failed:", err);
      }

      await db.collection("Felicitups").doc(felicitupId).update({
        finalVideoUrl,
        thumbnailUrl,
        exportVideoUrl: finalVideoUrl,
        updatedAt: FieldValue.serverTimestamp(),
        processingStatus: "merged",
        needsWatermark: true,
      });

      await snap.ref.update({
        status: "completed",
        finishedAt: FieldValue.serverTimestamp(),
        result: {
          finalVideoUrl,
          thumbnailUrl,
          exportVideoUrl: finalVideoUrl,
        },
      });
    } catch (error: unknown) {
      logger.error("Error in processVideoMerge:", error);
      const err = error as Error;
      await snap.ref.update({
        status: "failed",
        error: err.message,
        failedAt: FieldValue.serverTimestamp(),
      });
      await db.collection("Felicitups").doc(felicitupId).update({
        processingStatus: "failed",
        error: err.message,
        updatedAt: FieldValue.serverTimestamp(),
      });
    } finally {
      await cleanupTempFiles([...tempFiles, outputFilePath]);
    }
  }
);

export const processWatermark = onCall(async (request: CallableRequest) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  const { videoUrl, felicitupId, userId } = request.data?.data || request.data || {};
  if (!videoUrl || !felicitupId || !userId) {
    throw new HttpsError("invalid-argument", "Missing required parameters: videoUrl, felicitupId, userId");
  }

  const db = getDb();
  const bucket = getAdminStorage().bucket();
  const tempDir = os.tmpdir();
  const tempVideoPath = path.join(tempDir, `source-${Date.now()}.mp4`);
  const watermarkTempPath = path.join(tempDir, `watermark-${Date.now()}.png`);
  const watermarkedFileName = `export-${path.basename(tempVideoPath)}`;
  const watermarkedFilePath = path.join(tempDir, watermarkedFileName);
  const watermarkDestinationPath = `videos/${felicitupId}/${watermarkedFileName}`;

  try {
    const filePath = extractFilePathFromUrl(videoUrl);
    const file = bucket.file(filePath);
    await file.download({ destination: tempVideoPath });

    const watermarkFile = bucket.file("watermark.png");
    await watermarkFile.download({ destination: watermarkTempPath });

    await applyWatermark(tempVideoPath, watermarkedFilePath, watermarkTempPath);
    await bucket.upload(watermarkedFilePath, { destination: watermarkDestinationPath });

    const [exportVideoUrl] = await bucket.file(watermarkDestinationPath).getSignedUrl({
      action: "read",
      expires: "03-01-2500",
    });

    await db.collection("Felicitups").doc(felicitupId).update({
      exportVideoUrl,
      updatedAt: FieldValue.serverTimestamp(),
      processingStatus: "completed",
      needsWatermark: false,
    });

    return {
      success: true,
      exportVideoUrl,
      message: "Watermark processing completed successfully",
    };
  } catch (error: unknown) {
    const err = error as Error;
    logger.error("Error in watermark processing:", err);
    await db.collection("Felicitups").doc(felicitupId).update({
      processingStatus: "watermark_failed",
      error: err.message,
      updatedAt: FieldValue.serverTimestamp(),
      warning: "Watermark processing failed, using original video",
    });
    throw new HttpsError("internal", "Watermark processing failed", err.message);
  } finally {
    await cleanupTempFiles([tempVideoPath, watermarkTempPath, watermarkedFilePath]);
  }
});
