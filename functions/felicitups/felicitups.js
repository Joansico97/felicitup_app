/* eslint-disable max-len */
const admin = require("firebase-admin");
const constants = require("../constants/constants");

const db = admin.firestore();

module.exports = {
  getFelicitupById: async function(felicitupId) {
    const felicitup = await db.collection(constants.felicitupsPath).doc(felicitupId).get();
    return felicitup.data();
  },
  getFelicitupRefById: async function(felicitupId) {
    const docRef = db.collection(constants.felicitupsPath).doc(felicitupId);
    return docRef;
  },
  getFelicitupStartTime: async function(felicitup) {
    const scheduleStartTime = felicitup.date.toDate();
    const year = scheduleStartTime.getFullYear();
    const month = scheduleStartTime.getMonth();
    const day = scheduleStartTime.getDate();
    const hours = scheduleStartTime.getHours();
    const minutes = scheduleStartTime.getMinutes();

    const startTime = new Date();
    startTime.setUTCFullYear(year, month, day);
    startTime.setUTCHours(hours);
    startTime.setUTCMinutes(minutes);

    return startTime;
  },
};
