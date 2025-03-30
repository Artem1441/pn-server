import { Request, Response } from "express";
import queryDB from "../db/index.js";
import { jwtSign, jwtVerify } from "../helpers/jwt.helper.js";
import dotenv from "dotenv";
import { bcryptHash } from "../helpers/bcrypt.helper.js";
dotenv.config();

class UsersController {
  async getSignUpStage(req: Request, res: Response) {
    try {
      console.log(req.headers);
      if (!req.cookies) {
        res.status(401).json({ status: false, message: "Нет куков" });
        return;
      }
      const token = req.cookies.token;
      if (!token) {
        res.status(401).json({ status: false, message: "Нет токена" });
        return;
      }

      const { id } = jwtVerify(token);

      const query = `SELECT * FROM public.users WHERE id = $1;`;
      const values = [id];

      const result = await queryDB(query, values);
      console.log(result);

      // { id: "123", role: "specialist", login: "ivanovI2024" }

      // res.json({ status: true, user: decoded });
      res.status(200).json({ status: true, data: result });
    } catch (error) {
      console.error(error);
      res.status(401).json({ status: false, message: "Ошибка аутентификации" });
    }
  }

  async signUpFullName(req: Request, res: Response) {
    const { name, surname, patronymic } = req.body;
    const role = "specialist";
    const login = `${surname}${name[0]}${patronymic[0]}${Date.now()}`;
    const password = Date.now().toString();
    const hashedPassword = await bcryptHash(password);
    const time_zone = "UTC+5";
    const locale = "ru";

    if (name.length < 2) {
      res.status(500).json({ status: false, message: "Имя короткое" });
      return;
    }
    if (surname.length < 2) {
      res.status(500).json({ status: false, message: "Фамилия короткая" });
      return;
    }

    const query = `INSERT INTO public.users (
        role, login, password, name, surname, patronymic,time_zone, locale
      ) VALUES ($1, $2, $3, $4, $5, $6,$7, $8) RETURNING id;`;

    const values = [
      role,
      login,
      hashedPassword,
      name,
      surname,
      patronymic,
      time_zone,
      locale,
    ];

    try {
      const result = await queryDB(query, values);
      const token = jwtSign({ id: result.rows[0].id, role, login });
      // res.cookie("token", token, {
      //   httpOnly: true,
      //   secure: process.env.NODE_ENV === "prod", // secure только в продакшене, чтобы делать запросы через http
      //   sameSite: "lax", // Мягкие ограничения, чтобы работало в dev-режиме, strict - в жёстком
      //   maxAge: 24 * 60 * 60 * 1000, // 1 день
      // });
      // res.status(200).json({ status: true, data: token });

      res.cookie("token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production", // Secure только в проде
        sameSite: "lax",
        maxAge: 24 * 60 * 60 * 1000,
      });

      res.status(201).json({ status: true, token });
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, message: "Что-то пошшло не так" });
    }
  }
  // async sendIdentificationData(req: Request, res: Response) {
  //   try {
  //     const { name, surname, patronymic, inn, phone, email } = req.query;
  //     console.log(req.query, "AAAA");
  //     const role = "specialist";
  //     const login = "login" + Date.now();
  //     const password = "specialist";
  //     const time_zone = "UTC+5";
  //     const locale = "ru";
  //     // const studio_id = -1;
  //     const query = `INSERT INTO public.users (
  //       role, login, password, name, surname, patronymic, phone, email, inn,time_zone, locale
  //     ) VALUES ($1, $2, $3, $4, $5, $6,$7, $8, $9, $10, $11) RETURNING id;`;

  //     const values = [
  //       role,
  //       login,
  //       password,
  //       name,
  //       surname,
  //       patronymic,
  //       phone,
  //       email,
  //       inn,
  //       time_zone,
  //       locale,
  //     ];

  //     try {
  //       const result = await queryDB(query, values);
  //       console.log("Inserted user ID:", result.rows[0].id);
  //       res.status(200).json(result.rows[0].id);
  //     } catch (err) {
  //       res.status(500).json({ error: "Something went wrong" });
  //     }
  //   } catch (err) {
  //     res.status(500).json({ error: "Something went wrong" });
  //   }
  // }

  // async searchByKeyword(req: Request, res: Response) {
  //   try {
  //     const { keyword } = req.query;
  //     const limit = parseInt(req.query.limit as string) || 4;
  //     const offset = parseInt(req.query.offset as string) || 0;

  //     // Запрос для поиска по ключевым словам
  //     const query = `
  //       SELECT id, image_name, url
  //       FROM image
  //       WHERE search_keywords @> ARRAY[$1]
  //       ORDER BY created_at DESC
  //       LIMIT $2 OFFSET $3
  //     `;

  //     const result = await queryDB(query, [keyword, limit, offset]);
  //     res.status(200).json(result.rows);
  //   } catch (err) {
  //     console.error(err);
  //     res.status(500).json({ message: "Ошибка на сервере" });
  //   }
  // }
}

export default new UsersController();
