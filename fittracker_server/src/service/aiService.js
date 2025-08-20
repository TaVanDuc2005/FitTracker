import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Gemini Pro model (good for text/chat)
const model = genAI.getGenerativeModel({ model: "gemini-pro" });

export const askGemini = async (prompt) => {
  try {
    const result = await model.generateContent(prompt);
    return result.response.text();
  } catch (err) {
    console.error("Gemini API Error:", err);
    throw new Error("Failed to fetch AI response");
  }
};