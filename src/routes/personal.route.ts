import { Router } from "express";
import PersonalController from "../controllers/personal.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsSpecialistMiddleware from "../middlewares/checkIsSpecialist.middleware.js";
import checkPasswordStrengthMiddleware from "../middlewares/checkPasswordStrength.middleware.js";

const router = Router();

router.get(
  "/personal/getPersonalData",
  authenticateTokenMiddleware,
  checkIsSpecialistMiddleware,
  PersonalController.getPersonalData
);

router.post(
  "/personal/changePassword",
  authenticateTokenMiddleware,
  checkIsSpecialistMiddleware,
  checkPasswordStrengthMiddleware,
  PersonalController.changePassword
);

export default router;
