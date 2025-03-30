import { Router } from "express";
import AuthController from "../controllers/auth.controller.js";
import checkSignUpTokenMiddleware from "../middlewares/checkSignUpToken.middleware.js";
// import checkValidateEmailMiddleware from "../middlewares/checkValidateEmail.middleware.js";
import checkValidateIdentificationDataMiddleware from "../middlewares/checkValidateIdentificationData.middleware.js";
// import checkValidateFullNameMiddleware from "../middlewares/checkValidateFullName.middleware.js";
// import checkValidatePhoneMiddleware from "../middlewares/checkValidatePhone.middleware.js";
import signUpStageMiddleware from "../middlewares/signUpStage.middleware.js";

const router = Router();

router.get(
  "/auth/signUp/stage",
  signUpStageMiddleware,
  AuthController.signUpStage
);
router.post(
  "/auth/signUp/createUser",
  checkValidateIdentificationDataMiddleware,
  AuthController.signUpCreateUser
);

// router.post(
//   "/auth/signUp/updateFullName",
//   checkSignUpTokenMiddleware,
//   checkValidateFullNameMiddleware,
//   AuthController.signUpUpdateFullName
// );
// router.post(
//   "/auth/signUp/updatePhone",
//   checkSignUpTokenMiddleware,
//   checkValidatePhoneMiddleware,
//   AuthController.signUpUpdatePhone
// );

// router.post(
//   "/auth/signUp/updateEmail",
//   checkSignUpTokenMiddleware,
//   checkValidateEmailMiddleware,
//   AuthController.signUpUpdateEmail
// );

router.post(
  "/auth/signUp/confirmCode",
  checkSignUpTokenMiddleware,
  AuthController.signUpConfirmCode
);

export default router;
