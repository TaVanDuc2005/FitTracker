import express from "express";
import { chatWithAI } from "fittracker_server\src\controllers\aiController.js";

const router = express.Router();

router.post("/chat", chatWithAI);

export default router;