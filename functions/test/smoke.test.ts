import { sendPushNotification } from "../src/notifications";
import { normalizeSingleVideo } from "../src/video";
import { sendManualFelicitup } from "../src/felicitups";
import { HttpsError } from "firebase-functions/v2/https";

// Mock para firebase-admin
jest.mock("../src/lib/admin", () => {
  return {
    getAdminApp: jest.fn(),
    getAdminStorage: jest.fn(() => ({
      bucket: jest.fn(),
    })),
    getDb: jest.fn(),
  };
});

jest.mock("firebase-admin/messaging", () => {
  return {
    getMessaging: jest.fn(() => ({
      send: jest.fn().mockImplementation((payload) => {
        if (!payload.token || payload.token === "invalid") {
          const err: any = new Error("Invalid token");
          err.code = "messaging/invalid-registration-token";
          throw err;
        }
        return Promise.resolve("projects/test/messages/123");
      }),
    })),
  };
});

// @ts-ignore
const { getDb } = require("../src/lib/admin");

describe("Smoke Tests Integrales (Idempotencia y Self-Healing)", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("notifications.ts", () => {
    it("Debería detectar tokens FCM inválidos y activar flag isInvalidToken (Self-Healing)", async () => {
      const result = await sendPushNotification({
        token: "invalid",
        notification: { title: "Test", body: "Smoke Test" },
      });
      
      expect(result.success).toBe(false);
      expect(result.isInvalidToken).toBe(true);
    });

    it("Debería retornar error temprano si no hay token", async () => {
      const result = await sendPushNotification({
        token: "",
        notification: { title: "Test", body: "Smoke Test" },
      });
      
      expect(result.success).toBe(false);
      expect(result.isInvalidToken).toBe(true);
    });
  });

  describe("felicitups.ts", () => {
    it("Debería abortar tempranamente si la felicitup ya está en estado Finished (Idempotencia)", async () => {
      // Mock de base de datos para regresar status: "Finished"
      const mockGet = jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({ status: "Finished" }),
      });
      
      getDb.mockReturnValue({
        collection: jest.fn().mockReturnValue({
          doc: jest.fn().mockReturnValue({
            get: mockGet,
          }),
        }),
      });

      // Firebase Functions v2 'onCall' expone el método .run() para pruebas unitarias
      const result = await sendManualFelicitup.run({
        data: { data: { felicitupId: "123" } },
        auth: { uid: "user-123", token: {} as any },
        rawRequest: {} as any,
      } as any);

      expect(result).toEqual({ success: true, message: "La felicitup ya había sido enviada." });
    });
  });

  describe("video.ts", () => {
    it("Debería arrojar HttpsError si el video ya está procesado (Idempotencia)", async () => {
      // Mock db para que la transacción lea un usuario con processingStatus: "completed"
      const mockGet = jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({
          invitedUserDetails: [{
            id: "user-123",
            videoData: { processingStatus: "completed" }
          }]
        }),
      });

      const mockTransaction = jest.fn().mockImplementation(async (callback) => {
        const t = {
          get: mockGet,
          update: jest.fn(),
        };
        await callback(t);
      });

      getDb.mockReturnValue({
        runTransaction: mockTransaction,
        collection: jest.fn().mockReturnValue({
          doc: jest.fn(),
        }),
      });

      try {
        await normalizeSingleVideo.run({
          data: { data: { videoUrl: "url", userId: "user-123", felicitupId: "123" } },
          auth: { uid: "user-123", token: {} as any },
          rawRequest: {} as any,
        } as any);
        // Forzamos fallo si no arroja error
        expect(true).toBe(false); 
      } catch (err: any) {
        expect(err).toBeInstanceOf(HttpsError);
        expect(err.message).toBe("El video ya ha sido procesado.");
      }
    });
  });
});
