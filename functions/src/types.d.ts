declare module 'ffprobe-static' {
  const ffprobe: { path: string };
  export default ffprobe;
}

declare module '@ffmpeg-installer/ffmpeg' {
  const ffmpeg: { path: string };
  export default ffmpeg;
}
