import { onCall, CallableRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";

export const testFunction = onCall(
  { region: "us-central1" },
  async (request: CallableRequest) => {
    logger.info("Data recibida en testFunction:", request.data);
    return {
      message: "Datos recibidos correctamente!",
      data: request.data,
    };
  }
);

export const logErrors = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 300,
    memory: "256MiB",
  },
  async (request: CallableRequest) => {
    logger.error("Error recibido en logErrors:", request.data?.error || request.data);
    return { success: true };
  }
);
