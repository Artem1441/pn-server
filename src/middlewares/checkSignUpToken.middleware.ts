import { Request, Response, NextFunction } from "express";
import { jwtVerify } from "../helpers/jwt.helper";
import IResp from "../types/IResp.interface";

const checkSignUpTokenMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
) => {
  try {
    const token = req.cookies.signUpToken;
    if (!token) {
      res.status(401).json({ status: false, error: "Что-то пошло не так 3" });
      return;
    }

    const decoded = jwtVerify(token);
    req.body.userId = decoded.id;

    next();
  } catch (error) {
    res.status(401).json({ status: false, error: "Что-то пошло не так 3" });
    return;
  }
};

export default checkSignUpTokenMiddleware;
