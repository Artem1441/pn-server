import { Request, Response, NextFunction } from "express";
import IResp from "../types/IResp.interface";

const checkValidateIdentificationDataMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
) => {
  try {
    const { name, surname, email, phone, inn } = req.body;

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const phoneRegex = /^7\d{10}$/;

    if (name.length < 2 || surname.length < 2) {
      res.status(400).json({ status: false, error: "Введите имя и фамилию" });
      return;
    }

    if (!phone || phone.length !== 11 || !phoneRegex.test(phone)) {
      res.status(400).json({ status: false, error: "Введите телефон" });
      return;
    }

    if (!email || !emailRegex.test(email)) {
      res
        .status(400)
        .json({ status: false, error: "Некорректный формат email" });
      return;
    }

    if (!inn) {
      res.status(400).json({ status: false, error: "Введите ИНН" });
      return;
    }

    next();
  } catch (error) {
    res.status(500).json({ status: false, error: "Ошибка сервера" });
    return;
  }
};

export default checkValidateIdentificationDataMiddleware;
