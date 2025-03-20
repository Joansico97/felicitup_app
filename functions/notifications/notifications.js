/* eslint-disable max-len */
const admin = require("firebase-admin");
const constants = require("../constants/constants");

const db = admin.firestore();

module.exports = {
  sendPushNotification: async function(payload) {
    console.log("Token: " + payload.token);
    if (payload.token == "" || payload.token == null) {
      console.log("Error: User has no push notification token!");
      return;
    }

    admin
        .messaging()
        .send(payload)
        .then((response) => {
          console.log("Successfully sent message:", response);
          return {success: true};
        })
        .catch((error) => {
          console.log("Error :", error);
          return {error: error.code};
        });
  },

  sendPushNotificationToListContacts: async function(payload) {
    if (!payload.tokens || !Array.isArray(payload.tokens) || payload.tokens.length === 0) {
      console.log("Error: No push notification tokens provided or tokens list is empty!");
      return;
    }

    admin
        .messaging()
        .sendEachForMulticast(payload)
        .then((response) => {
          console.log("Successfully sent message:", response);
          return {success: true};
        })
        .catch((error) => {
          console.log("Error :", error);
          return {error: error.code};
        });
  },

  getDeviceToken: async function(userId) {
    const user = await db.collection(constants.usersPath).doc(userId).get();
    return user.data().fcmToken;
  },

  getUserDataById: async function(userId) {
    const user = await db.collection(constants.usersPath).doc(userId).get();
    return user.data();
  },

};
