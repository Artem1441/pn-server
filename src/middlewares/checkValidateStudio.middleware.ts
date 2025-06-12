import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import IResp from "../types/IResp.interface";

const checkValidateStudioMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    const { name } = req.body;

    if (!name.trim()) {
      res.status(400).json({ status: false, error: errors.studioShortNameRequired });
      return;
    }

    next();
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkValidateStudioMiddleware;
