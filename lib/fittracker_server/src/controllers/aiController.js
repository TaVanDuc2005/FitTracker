import { askGemini } from "fittracker_server\src\service\aiService.js";

export const chatWithAI = async (req, res) => {
  try {
    const { message } = req.body;
    if (!message) {
      return res.status(400).json({ error: "Message is required" });
    }

    const reply = await askGemini(message);
    res.json({ reply });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};