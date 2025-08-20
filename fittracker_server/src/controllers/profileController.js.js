import { auth, db } from "fittracker_server\src\config\firebase.js";

export const updateProfile = async (req, res) => {
  try {
    const { userId, profile } = req.body;
    await db.collection("users").doc(userId).update(profile);
    res.json({ message: "Profile updated" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};