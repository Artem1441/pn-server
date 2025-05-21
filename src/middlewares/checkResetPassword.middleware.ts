import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import { jwtVerify } from "../helpers/jwt.helper";
import IResp from "../types/IResp.interface";

const checkResetPasswordMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      res.status(401).json({ status: false, error: errors.missingToken });
      return;
    }
    const token = authHeader.slice(7);

    if (!token) {
      res.status(401).json({ status: false, error: errors.missingToken });
      return;
    }

    try {
      const decoded = jwtVerify(token);
      if (!decoded.email) {
        res.status(401).json({ status: false, error: errors.tokenExpired });
        return;
      }
      req.body.userId = decoded.id;
      const { password } = req.body;
      if (password.length < 8) {
        res.status(401).json({ status: false, error: errors.passwordTooShort });
        return;
      }

      next();
      return;
    } catch (err) {
      res.status(401).json({ status: false, error: errors.tokenExpired });
      return;
    }
  } catch (error) {
    res.status(401).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkResetPasswordMiddleware;
