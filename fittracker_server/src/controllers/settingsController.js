import { auth, db } from "fittracker_server\src\config\firebase.js";

export const updateSettings = async (req, res) => {
  try {
    const { userId, settings } = req.body;
    await db.collection("users").doc(userId).collection("settings").doc("prefs").set(settings);
    res.json({ message: "Settings updated" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};