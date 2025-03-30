import { Request, Response } from "express";
import { jwtSign } from "../helpers/jwt.helper.js";
import dotenv from "dotenv";
import {
  createUserQuery,
  getUserByQuery,
} from "../db/auth.db.js";
import {
  generateVerificationCode,
  verifyCode,
} from "../helpers/verification.helper.js";
import IResp from "../types/IResp.interface.js";
dotenv.config();

class AuthController {
  codeTimeout = 60 * 1000;
  async signUpStage() {}

  async signUpCreateUser(req: Request, res: Response<IResp<null>>) {
    try {
      const { name, surname, patronymic, phone, email, inn } = req.body;

      const userByPhone = await getUserByQuery("phone", phone);
      const userByEmail = await getUserByQuery("email", email);
      let id;

      if (userByPhone) {
        if (userByEmail) {
          if (userByPhone.id !== userByEmail.id) {
            res.status(401).json({
              status: false,
              error: "Пользователь с такой почтой уже есть в системе",
            });
            return;
          } else {
            id = userByPhone.id;
          }
        } else {
          res.status(401).json({
            status: false,
            error: "Пользователь с таким телефоном уже есть в системе",
          });
          return;
        }
      } else {
        id = await createUserQuery({
          name,
          surname,
          patronymic,
          phone,
          email,
          inn,
        });
      }

      const token = jwtSign({ id });

      await generateVerificationCode(id, "phone", phone);
      await generateVerificationCode(id, "email", email);

      res
        .cookie("signUpToken", token, {
          httpOnly: true,
          secure: process.env.NODE_ENV === "production", // Secure только в проде
          sameSite: "lax",
          maxAge: 24 * 60 * 60 * 1000,
        })
        .status(200)
        .json({ status: true });
    } catch (err) {
      console.log(err);
      res.status(401).json({ status: false, error: "Ошибка 2" });
      return;
    }
  }

  //   async signUpUpdatePhone(req: any, res: Response) {
  //     try {
  //       const { phone } = req.body;
  //       const id = req.userId;

  //       if (phone.length !== 11) {
  //         return res.status(400).json({ error: "Неверный номер телефона" });
  //       }

  //       // Получаем время последней отправки кода для телефона
  //       const lastSentTime = await getLastCodeSentTime(phone);

  //       if (lastSentTime && Date.now() - lastSentTime < this.codeTimeout) {
  //         return res.status(400).json({ error: "Попробуйте через минуту" });
  //       }

  //       // Сохраняем номер в базе данных, но ещё не подтверждаем
  //       await updateUserPhoneByIdQuery({ phone, id });

  //       // Генерируем и отправляем код подтверждения
  //       const verificationCode = generateVerificationCode(); // Реализуйте генерацию кода
  //       await sendSms(phone, `Ваш код подтверждения: ${verificationCode}`);

  //       // Сохраняем код и время отправки в базе данных
  //       await saveVerificationCodeForPhone({
  //         phone,
  //         verificationCode,
  //         sentAt: Date.now(),
  //       });

  //       res.status(200).json({ message: "Код подтверждения отправлен" });
  //     } catch (err) {
  //       console.log(err);
  //       res.status(500).json({ error: "Ошибка сервера" });
  //     }
  //   }

  // async signUpUpdateEmail(req: any, res: Response) {
  //   try {
  //     const { email } = req.body;
  //     const id = req.userId;

  //     await updateUserEmailByIdQuery({ email, id });

  //     await generateVerificationCode(id, "email", email);

  //     res.status(200).json({ message: "Код отправлен на почту" });
  //   } catch (err) {
  //     console.log(err);
  //     res.status(500).json({ error: "Ошибка сервера" });
  //   }
  // }

  async signUpConfirmCode(req: Request, res: Response<IResp<string>>) {
    try {
      const { type, value, code, userId } = req.body;

      if (!["phone", "email"].includes(type)) {
        res.status(400).json({ status: false, error: "Неверный тип" });
        return;
      }

      const response = await verifyCode(
        userId,
        type as "phone" | "email",
        value,
        code
      );

      res.status(response.status ? 200 : 400).json(response);
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: "Ошибка сервера" });
      return;
    }
  }
}

export default new AuthController();
