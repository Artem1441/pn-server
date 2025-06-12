import { Request, Response, NextFunction } from "express";
import { jwtVerify } from "../helpers/jwt.helper";
import IResp from "../types/IResp.interface";

const authenticateTokenMiddleware = (
    req: Request,
    res: Response<IResp<null>>,
    next: NextFunction
) => {
  const token = req.cookies.token;

  if (!token) {
    res.status(401).json({ status: false, error: "Требуется токен" });
    return;
  }

  try {
    const decoded = jwtVerify(token);
    req.body.user = decoded; 
    
    next();
  } catch (error) {
    res.status(403).json({ status: false, error: "Недействительный токен" });
    return;
  }
};

export default authenticateTokenMiddleware;
