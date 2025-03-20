const {sendPushNotification, getDeviceToken} = require("./notifications");

const functions = require("firebase-functions");

exports.sendTestNotification = functions.https.onCall(
    async (data, context) => {
      try {
        const userId = data.userId;
        const token = await getDeviceToken(userId);
        const payload = {
          token,
          notification: {
            title: "Test Notification",
            body: "This is a test notification",
          },
        };
        await sendPushNotification(payload);
      } catch (error) {
        return {error: {message: error.message}};
      }
    },
);
