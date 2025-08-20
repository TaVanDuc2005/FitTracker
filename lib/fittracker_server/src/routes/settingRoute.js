import express from "express";
import { updateSettings } from "../controllers/settingsController.js";

const router = express.Router();

// POST /settings/update
router.post("/update", updateSettings);

export default router;