const admin = require("firebase-admin");

const db = admin.firestore();

module.exports = {
  getUserDataById: async function(userId) {
    try {
      const user = await db.collection("Users").doc(userId).get();
      return user.data();
    } catch (error) {
      console.log("Error getting user data by id: ", error);
    }
  },
  getUserDataByPhone: async function(phone) {
    // eslint-disable-next-line max-len
    const user = await db.collection("Users").where("phone", "==", phone).get();
    return user.docs[0].data();
  },
};
