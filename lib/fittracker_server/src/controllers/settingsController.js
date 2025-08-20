import { db } from "../config/firebasfittracker_server\src\config\firebase.jse.js";

// POST /settings/update
export const updateSettings = async (req, res) => {
  try {
    const { userId, dailyWaterGoal, dailyCaloriesGoal, theme } = req.body;

    const userRef = db.collection("users").doc(userId);
    await userRef.set(
      {
        settings: {
          dailyWaterGoal,
          dailyCaloriesGoal,
          theme
        }
      },
      { merge: true } // merge so profile & other data remain safe
    );

    res.status(200).json({ message: "Settings updated ✅" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};