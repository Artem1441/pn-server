import { Request, Response } from "express";
import { jwtSign } from "../helpers/jwt.helper.js";
import dotenv from "dotenv";
import {
  createUser,
  deleteUserById,
  getUserByField,
  getUserById,
  updatePersonalDataToUser,
  updateUserFieldById,
} from "../db/auth.db.js";
import { verifyCode } from "../helpers/verification.helper.js";
import IResp from "../types/IResp.interface.js";
import errors from "../constants/errors.js";
import {
  generatePassword,
  generateVerificationCode,
} from "../helpers/generate.helper.js";
import IUser from "../types/IUser.interface.js";
import tokens from "../constants/tokens.js";
import RoleType from "../types/RoleType.type.js";
import getNalogTokensApi from "../api/getNalogToken.api.js";
import taxpayerStatusApi from "../api/taxpayerStatus.api.js";
import getBankByBikApi from "../api/getBankByBik.api.js";
import { sendEmail } from "../helpers/mail.helper.js";
import { bcryptCompare, hashPassword } from "../helpers/bcrypt.helper.js";
import { sendSms } from "../helpers/sms.helper.js";
import messages from "../constants/messages.js";
dotenv.config();

class AuthController {
  private checkInn = async (
    inn: string
  ): Promise<{ status: boolean; error?: string }> => {
    const { token } = await getNalogTokensApi();
    const now = new Date();

    const formatter = new Intl.DateTimeFormat("ru-RU", {
      timeZone: "Europe/Moscow",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    });

    const [day, month, year] = formatter.format(now).split(".");
    const requestDate = `${year}-${month}-${day}`;

    return await taxpayerStatusApi({ token, inn, requestDate });
  };

  private checkBank = async (
    bik: string,
    acc: string
  ): Promise<{
    status: boolean;
    error?: string;
  }> => {
    const bankByBik = await getBankByBikApi(bik);

    if (!bankByBik.status)
      return { status: false, error: bankByBik.error || errors.serverError };

    const bikAcc = bik.slice(-3) + acc;
    let checksum = 0;
    const coefficients = [
      7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1,
    ];
    for (let i in coefficients)
      checksum += coefficients[i] * (parseInt(bikAcc[i], 10) % 10);
    if (checksum % 10 !== 0) {
      return { status: false, error: errors.accNotFound };
    }

    return { status: true };
  };

  public logout = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    try {
      res
        .clearCookie("token", tokens.clearToken)
        .status(200)
        .json({ status: true });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public status = async (
    req: Request,
    res: Response<IResp<{ role: RoleType }>>
  ): Promise<void> => {
    const { id, role } = req.body.user;

    try {
      res
        .cookie("token", jwtSign({ id }, "7d"), tokens.token)
        .clearCookie("signUpToken", tokens.clearToken)
        .status(200)
        .json({ status: true, data: { role } });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public signUpCheckIdentificationData = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { name, surname, patronymic, phone, email, inn } = req.body;
    let id;
    try {
      const userByPhone: IUser | null = await getUserByField("phone", phone);
      const userByEmail: IUser | null = await getUserByField("email", email);
      const userByInn: IUser | null = await getUserByField("inn", inn);

      if (
        userByPhone &&
        userByEmail &&
        userByInn &&
        userByPhone.id === userByEmail.id &&
        userByInn.id === userByEmail.id
      ) {
        id = userByPhone.id;
      } else if (userByPhone) {
        res.status(401).json({
          status: false,
          error: errors.userWithPhoneAlreadyExists,
        });
        return;
      } else if (userByEmail) {
        res.status(401).json({
          status: false,
          error: errors.userWithEmailAlreadyExists,
        });
        return;
      } else if (userByInn) {
        res.status(401).json({
          status: false,
          error: errors.userWithInnAlreadyExists,
        });
        return;
      } else {
        const checkInn = await this.checkInn(inn);

        if (!checkInn.status) {
          res.status(401).json({
            status: false,
            error: checkInn.error,
          });
          return;
        }
        id = await createUser({
          name,
          surname,
          patronymic,
          phone,
          email,
          inn,
        });
      }

      await generateVerificationCode(id, "phone", phone);
      await generateVerificationCode(id, "email", email);

      res
        .cookie("signUpToken", jwtSign({ id }, "1d"), tokens.signUpToken)
        .status(200)
        .json({ status: true });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public signUpCheckPersonalData = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const {
      userId,
      passport,
      bank_bik,
      bank_acc,
      passport_main,
      passport_registration,
      photo_front,
    } = req.body;
    try {
      const checkBank = await this.checkBank(bank_bik, bank_acc);

      if (!checkBank.status) {
        res.status(401).json({
          status: false,
          error: checkBank.error,
        });
        return;
      }

      await updatePersonalDataToUser({
        id: userId,
        passport,
        bank_bik,
        bank_acc,
        passport_main,
        passport_registration,
        photo_front,
      });

      res.status(200).json({ status: true });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public signUpConfirmCode = async (
    req: Request,
    res: Response<IResp<string>>
  ): Promise<void> => {
    const { type, value, code, userId } = req.body;

    try {
      if (!["phone", "email"].includes(type)) {
        res.status(400).json({ status: false, error: errors.incorrectType });
        return;
      }

      const response = await verifyCode(
        userId,
        type as "phone" | "email",
        value,
        code
      );

      res.status(response.status ? 200 : 400).json(response);
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public updatePhoto = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { userId, fileKey, field } = req.body;

    try {
      await updateUserFieldById({
        id: userId,
        field: field,
        value: fileKey,
      });

      res.status(200).json({ status: true });
      return;
    } catch (err) {
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public signIn = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { login, password } = req.body;
    try {
      const user: IUser | null = await getUserByField("login", login);

      if (!user) {
        res.status(401).json({
          status: false,
          error: errors.incorrectLogin,
        });
        return;
      }

      const isPassword = await bcryptCompare(password, user.password);

      if (!isPassword) {
        res.status(401).json({
          status: false,
          error: errors.incorrectPassword,
        });
        return;
      }

      const { registration_status, is_banned } = user;

      if (is_banned) {
        res.status(401).json({
          status: false,
          error: errors.accountBlocked,
        });
        return;
      }

      if (registration_status !== "confirmed") {
        res.status(401).json({
          status: false,
          error: errors.registrationIncomplete,
        });
        return;
      }

      res
        .cookie("token", jwtSign({ id: user.id }, "7d"), tokens.token)
        .clearCookie("signUpToken", tokens.clearToken)
        .status(200)
        .json({ status: true });
      return;
    } catch (err: unknown) {
      let message = errors.serverError;
      if (err instanceof Error) message = err.message;
      else if (typeof err === "string") message = err;

      res.status(500).json({ status: false, error: message });
      return;
    }
  };

  public forgotPassword = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { emailOrLogin } = req.body;

    const userByLogin: IUser | null = await getUserByField(
      "login",
      emailOrLogin
    );
    const userByEmail: IUser | null = await getUserByField(
      "email",
      emailOrLogin
    );
    const user = userByLogin ? userByLogin : userByEmail;

    if (!user) {
      res.status(500).json({ status: false, error: errors.userNotFound });
      return;
    }

    const token = jwtSign({ id: user.id, email: user.email }, "1h");
    const resetLink = `${process.env.CORS_URL}/auth/reset-password?token=${token}`;

    await sendEmail(user.email, "Восстановление пароля", resetLink);

    res.status(200).json({ status: true });
    return;
  };

  public resetPassword = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { userId, password } = req.body;
    const hashedPassword = await hashPassword(password);

    try {
      await updateUserFieldById({
        id: userId,
        field: "password",
        value: hashedPassword,
      });

      res.status(200).json({ status: true });
      return;
    } catch (err) {
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public confirmEmployeeForm = async (
    req: Request,
    res: Response<IResp<null>>
  ) => {
    const { id } = req.body;
    try {
      const user = await getUserById(id);
      await updateUserFieldById({
        id,
        field: "registration_status",
        value: "confirmed",
      });

      const password = generatePassword();
      const hashedPassword = await hashPassword(password);

      await updateUserFieldById({
        id,
        field: "password",
        value: hashedPassword,
      });
      const login = user.login;

      await sendEmail(user.email, messages.emailRequestProcessedSent, messages.emailAcceptRequestProcessedSent(login, password));
      await sendSms(user.phone, messages.smsRequestProcessedSent);

      res.status(200).json({ status: true });
      return;
    } catch (err) {
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public refuseEmployeeForm = async (
    req: Request,
    res: Response<IResp<null>>
  ) => {
    const { id, rejectionReason } = req.body;
    try {
      const user = await getUserById(id);

      await deleteUserById(id);
      await sendEmail(user.email, messages.emailRequestProcessedSent, messages.emailRejectRequestProcessedSent(rejectionReason));
      await sendSms(user.phone, messages.smsRequestProcessedSent);

      res.status(200).json({ status: true });
      return;
    } catch (err) {
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };
}

export default new AuthController();
