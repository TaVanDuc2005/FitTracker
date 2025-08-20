import express from "express";
import cors from "cors";
import bodyParser from "body-parser";

import mealRoutes from "./routes/mealRoutes.js";
import profileRoutes from "./routes/profileRoutes.js";
import aiRoutes from "./routes/aiRoutes.js";
import waterRoutes from "./routes/waterRoutes.js";
import settingsRoutes from "./routes/settingsRoutes.js";

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Health check
app.get("/", (req, res) => res.json({ message: "FitTracker backend running 🚀" }));

// Routes
app.use("/meals", mealRoutes);
app.use("/profile", profileRoutes);
app.use("/ai", aiRoutes);
app.use("/water", waterRoutes);
app.use("/settings", settingsRoutes);

export default app;