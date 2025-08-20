import { auth, db } from "fittracker_server\src\config\firebase.js";

export const registerUser = async (req, res) => {
  try {
    const { email, password, name } = req.body;
    const user = await auth.createUser({ email, password, displayName: name });

    await db.collection("users").doc(user.uid).set({
      email, name, createdAt: Date.now()
    });

    res.status(201).json({ uid: user.uid, email, name });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};