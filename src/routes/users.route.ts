import { Router } from "express";
import userController from "../controllers/users.controller.js";

const router = Router();

router.get("/users/getSignUpStage", userController.getSignUpStage)
router.post("/users/signUpFullName", userController.signUpFullName);
// router.post(
//   "/users/sendIdentificationData",
//   userController.sendIdentificationData
// );

export default router;
