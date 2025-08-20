import { auth, db } from "fittracker_server\src\config\firebase.js";

export const logWater = async (req, res) => {
  try {
    const { userId, amount } = req.body;
    const ref = await db.collection("users").doc(userId).collection("waterLogs").add({
      amount, timestamp: Date.now()
    });
    res.status(201).json({ waterLogId: ref.id, amount });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};