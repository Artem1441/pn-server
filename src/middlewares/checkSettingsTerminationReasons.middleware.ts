import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import IResp from "../types/IResp.interface";

const checkSettingsTerminationReasonsMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    const { terminationReasons } = req.body;

    for (const item of terminationReasons) {
      for (const terminationReason of item.terminationReasons) {
        if (
          !terminationReason.reason.trim() ||
          !terminationReason.description.trim()
        ) {
          res.status(400).json({
            status: false,
            error: errors.terminationReasonsFieldsRequired,
          });
          return;
        }
      }
    }

    next();
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkSettingsTerminationReasonsMiddleware;
