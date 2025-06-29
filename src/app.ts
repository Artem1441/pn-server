import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import cookieParser from "cookie-parser";
import authRouter from "./routes/auth.route.js";
import cloudRouter from "./routes/cloud.route.js";
import priceRouter from "./routes/price.route.js";
import motivationRouter from "./routes/motivation.route.js";
import notificationRouter from "./routes/notification.route.js";
import informationRouter from "./routes/information.route.js";
import cityRouter from "./routes/city.route.js";
import studioRouter from "./routes/studio.route.js";
import swaggerRoute from "./routes/swagger.route.js";
import specialityRouter from "./routes/speciality.route.js";
import sequelize from "./db/index.js";
import { initUserModel } from "./models/User.model.js";
import { initVerificationCodeModel } from "./models/VerificationCode.model.js";
import { initInformationModel } from "./models/Information.model.js";
import { initInformationChangeModel } from "./models/InformationChange.model.js";
import { initStudioModel, Studio } from "./models/Studio.model.js";
import { City, initCityModel } from "./models/City.model.js";
import { initPriceModel, Price } from "./models/Price.model.js";
import { initMotivationModel } from "./models/Motivation.model.js";
import { initSpecialityModel } from "./models/Speciality.model.js";
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
app.use("/api", cityRouter);
app.use("/api", priceRouter);
app.use("/api", motivationRouter);
app.use("/api", specialityRouter);
app.use("/api", swaggerRoute);

(async () => {
  await sequelize.authenticate();
  initUserModel(sequelize);
  initVerificationCodeModel(sequelize);
  initInformationModel(sequelize);
  initInformationChangeModel(sequelize);
  initStudioModel(sequelize);
  initCityModel(sequelize);
  initPriceModel(sequelize);
  initMotivationModel(sequelize);
  initSpecialityModel(sequelize);

  // Studio
  Studio.belongsTo(City, {
    foreignKey: "city_id",
    as: "city",
  });

  City.hasMany(Studio, {
    foreignKey: "city_id",
    as: "studios",
  });

  // Price
  Price.belongsTo(City, {
    foreignKey: "city_id",
    as: "city",
  });

  City.hasMany(Price, {
    foreignKey: "city_id",
    as: "prices",
  });

  app.listen(PORT, () => console.log(`http://localhost:${PORT}`));
})();
