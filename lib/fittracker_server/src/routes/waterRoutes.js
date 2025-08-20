import express from "express";
import { logWater } from "../controllers/waterController.js";

const router = express.Router();

// POST /water/log
router.post("/log", logWater);

export default router;