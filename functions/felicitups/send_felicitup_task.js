/* eslint-disable max-len */
const {CloudTasksClient} = require("@google-cloud/tasks");
const {getFelicitupById, getFelicitupStartTime} = require("./felicitups");

const client = new CloudTasksClient();

const project = "felicitup-prod";
const location = "us-central1";
const queue = "send-felicitup";

const parent = client.queuePath(project, location, queue);

module.exports = {
  sendFelicitupTask: async function(felicitupId) {
    const felicitup = await getFelicitupById(felicitupId);

    console.log("Scheduled task to send felicitup for id: " + felicitupId);

    const startTime = (await getFelicitupStartTime(felicitup)).getTime() / 1000;

    console.log("Start time: " + startTime);

    const cloudTask = {
      scheduleTimw: {
        seconds: startTime,
      },
      httpRequest: {
        httpMethod: "POST",
        url: "https://${location}-${project}.cloudfunctions.net/sendFelicitup",
        body: Buffer.from(JSON.stringify({felicitupId: felicitupId})).toString("base64"),
        headers: {
          "Content-Type": "application/json",
        },
      },
    };

    const request = {
      parent: parent,
      task: cloudTask,
    };

    const response = await client.createTask(request);

    console.log("Task created: " + response.name);
  },
  deleteFelicitupTask: async function(felicitupId) {
    const taskName = client.taskPath(project, location, queue, felicitupId);

    const request = {
      parent: parent,
      name: taskName,
    };
    const response = await client.deleteTask(request);

    console.log("Task deleted: " + response.name);
  },
};
