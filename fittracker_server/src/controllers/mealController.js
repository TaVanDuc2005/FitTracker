import { auth, db } from "fittracker_server\src\config\firebase.js";

export const addMeal = async (req, res) => {
  try {
    const { userId, meal } = req.body;
    const ref = await db.collection("users").doc(userId).collection("meals").add({
      ...meal,
      timestamp: Date.now()
    });
    res.status(201).json({ mealId: ref.id, ...meal });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};