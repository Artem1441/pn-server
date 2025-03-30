import { Request, Response, NextFunction } from "express";
import { getUserQuery } from "../db/auth.db";
import { jwtVerify } from "../helpers/jwt.helper";
import IResp from "../types/IResp.interface";
import StageType from "../types/StageType.type";

const signUpStageMiddleware = async (
  req: Request,
  res: Response<IResp<StageType>>,
  next: NextFunction
) => {
  try {
    const token = req.cookies.signUpToken;
    if (!token) {
      res.status(200).json({
        status: true,
        data: "accession agreement",
      });
      return;
    }

    const decoded = jwtVerify(token);
    const userId = decoded.id;

    const user = await getUserQuery(userId);
    const { is_confirmed_phone, is_confirmed_email } = user;

    if (!is_confirmed_phone || !is_confirmed_email) {
      res.status(200).json({
        status: true,
        data: "identification data",
      });
      return;
    }

    res.status(200).json({
      status: true,
      data: "personal data",
    });
    next();
    return;
  } catch (error) {
    console.log(error);
    res.status(401).json({
      status: false,
      error: "Что-то пошло не так 453",
    });
    return;
  }
};

export default signUpStageMiddleware;
