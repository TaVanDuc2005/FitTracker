import express from "express";
import { addMeal } from "fittracker_server\src\controllers\mealController.js";

const router = express.Router();
router.post("/add", addMeal);

export default router;