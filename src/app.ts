import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import cookieParser from "cookie-parser";
import authRouter from "./routes/auth.route.js";
import cloudRouter from "./routes/cloud.route.js";
import notificationRouter from "./routes/notification.route.js";
import informationRouter from "./routes/information.route.js";
import studioRouter from "./routes/studio.route.js";
import swaggerRoute from "./routes/swagger.route.js";
import sequelize from "./db/index.js";
import { initUserModel } from "./models/User.model.js";
import { initVerificationCodeModel } from "./models/VerificationCode.model.js";
import { initInformationModel } from "./models/Information.model.js";
import { initInformationChangeModel } from "./models/InformationChange.model.js";
import { initStudioModel } from "./models/Studio.model.js";
dotenv.config();

const app = express();
const PORT = Number(process.env.PORT);

app.use(
  cors({
    origin: process.env.CORS_URL,
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);
app.use(cookieParser());

app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

app.use(express.json());
app.use("/api", authRouter);
app.use("/api", cloudRouter);
app.use("/api", notificationRouter);
app.use("/api", informationRouter);
app.use("/api", studioRouter);
app.use("/api", swaggerRoute);


(async () => {
  await sequelize.authenticate();
  initUserModel(sequelize);
  initVerificationCodeModel(sequelize);
  initInformationModel(sequelize);
  initInformationChangeModel(sequelize);
  initStudioModel(sequelize);

  app.listen(PORT, () => console.log(`http://localhost:${PORT}`));
})();
