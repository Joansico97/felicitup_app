const admin = require("firebase-admin");
const constants = require("../constants/constants");

const db = admin.firestore();

module.exports = {
    getUserDataById: async function (userId) {
        const user = await db.collection(constants.usersPath).doc(userId).get();
        return user.data();
    },
    getUserDataByPhone: async function (phone) { 
        const user = await db.collection(constants.usersPath).where('phone', '==', phone).get();
        return user.docs[0].data();
    }
}