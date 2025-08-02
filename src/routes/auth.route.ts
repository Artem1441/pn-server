import { Router } from "express";
import AuthController from "../controllers/auth.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsAdminMiddleware from "../middlewares/checkIsAdmin.middleware.js";
import checkResetPasswordMiddleware from "../middlewares/checkResetPassword.middleware.js";
import checkResetPasswordTokenMiddleware from "../middlewares/checkResetPasswordToken.middleware.js";
import checkSignUpTokenMiddleware from "../middlewares/checkSignUpToken.middleware.js";
import checkValidateConfirmEmployeeFormMiddleware from "../middlewares/checkValidateConfirmEmployeeForm.middleware.js";
import checkValidateIdentificationDataMiddleware from "../middlewares/checkValidateIdentificationData.middleware.js";
import checkValidatePersonalDataMiddleware from "../middlewares/checkValidatePersonalData.middleware.js";
import signUpStageMiddleware from "../middlewares/signUpStage.middleware.js";
import validateUserExistsMiddleware from "../middlewares/validateUserExists.middleware.js";

const router = Router();

router.get(
  "/auth/status",
  authenticateTokenMiddleware,
  validateUserExistsMiddleware,
  AuthController.status
);

router.get("/auth/logout", AuthController.logout);

/**
 * @openapi
 * /auth/signUp/stage:
 *   get:
 *     summary: Получить текущий этап регистрации
 *     description: Возвращает этап регистрации на основе наличия токена и данных пользователя
 *     responses:
 *       200:
 *         description: Текущий этап регистрации
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: string
 *                   enum:
 *                     - accessionAgreement
 *                     - identificationData
 *                     - personalData
 *                   example: identificationData
 *       401:
 *         description: Ошибка авторизации или серверная ошибка
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: false
 *                 error:
 *                   type: string
 *                   example: "Internal server error"
 */

router.get("/auth/signUp/stage", signUpStageMiddleware);

/**
 * @openapi
 * /auth/signUp/checkIdentificationData:
 *   post:
 *     summary: Проверка данных пользователя на этапе регистрации
 *     description: Валидирует персональные данные, проверяет уникальность email/phone/inn и создаёт нового пользователя при необходимости
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: "Иван"
 *               surname:
 *                 type: string
 *                 example: "Иванов"
 *               patronymic:
 *                 type: string
 *                 nullable: true
 *                 example: "Иванович"
 *               phone:
 *                 type: string
 *                 example: "79001234567"
 *               email:
 *                 type: string
 *                 example: "ivanov@example.com"
 *               inn:
 *                 type: string
 *                 example: "123456789012"
 *     responses:
 *       200:
 *         description: Регистрация прошла успешно, установлен токен в куки
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *       400:
 *         description: Ошибка валидации входных данных
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       401:
 *         description: Пользователь с такими данными уже существует
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Внутренняя ошибка сервера
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */

router.post(
  "/auth/signUp/checkIdentificationData",
  checkValidateIdentificationDataMiddleware,
  AuthController.signUpCheckIdentificationData
);

router.post(
  "/auth/signUp/confirmCode",
  checkSignUpTokenMiddleware,
  AuthController.signUpConfirmCode
);

router.post(
  "/auth/signUp/updatePhoto",
  checkSignUpTokenMiddleware,
  AuthController.updatePhoto
);

router.post(
  "/auth/signUp/checkPersonalData",
  checkSignUpTokenMiddleware,
  checkValidatePersonalDataMiddleware,
  AuthController.signUpCheckPersonalData
);

router.post("/auth/signIn", AuthController.signIn);

router.post("/auth/forgotPassword", AuthController.forgotPassword);

router.get("/auth/resetPassword", checkResetPasswordTokenMiddleware);

router.post(
  "/auth/resetPassword",
  checkResetPasswordMiddleware,
  AuthController.resetPassword
);

router.get("/auth/getSpecialitiesAndStudios",   authenticateTokenMiddleware,
checkIsAdminMiddleware,
AuthController.getSpecialitiesAndStudios
);

router.post(
  "/auth/confirmEmployeeForm",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  checkValidateConfirmEmployeeFormMiddleware,
  AuthController.confirmEmployeeForm
);

router.post(
  "/auth/refuseEmployeeForm",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  AuthController.refuseEmployeeForm
);

export default router;
