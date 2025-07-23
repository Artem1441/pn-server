import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import IResp from "../types/IResp.interface";

const checkValidateDocxMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    const { file_key, file_type } = req.body;

    // if (!file_key.trim()) {
    //   res.status(400).json({ status: false, error: errors.cityShortNameRequired });
    //   return;
    // }

    next();
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkValidateDocxMiddleware;
