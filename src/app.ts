import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import cookieParser from "cookie-parser"
import authRouter from "./routes/auth.route.js";

dotenv.config();

const app = express();
const PORT = Number(process.env.PORT);

app.use(
  cors({
    origin: process.env.CORS_URL,
    credentials: true,
  })
);
app.use(cookieParser());

app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

app.use(express.json());
// app.use("/api", usersRouter);
app.use("/api", authRouter);

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
