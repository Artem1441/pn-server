import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import IResp from "../types/IResp.interface";

const checkValidateSettingsPeriodicityMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    
    next();
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkValidateSettingsPeriodicityMiddleware;
