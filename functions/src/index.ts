import { setGlobalOptions } from "firebase-functions/v2";

setGlobalOptions({ maxInstances: 10, region: "us-central1" });

export { testFunction, logErrors } from "./system";
export { sendNotification, sendNotificationToMultiple } from "./notifications";
export { sendFelicitup, executeFelicitupCompletion, sendManualFelicitup } from "./felicitups";
export { normalizeSingleVideo, processVideoMerge, processWatermark } from "./video";
export { checkBirthdaysAndCreateAlerts, getTemporaryImageUrl, disableCurrentUser, validateEmailDomain } from "./users";
