import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
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
      res.status(401).json({ status: false, error: errors.missingToken });
      return;
    }

    const decoded = jwtVerify(token);
    req.body.userId = decoded.id;

    next();
  } catch (error) {
    res.status(401).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkSignUpTokenMiddleware;
