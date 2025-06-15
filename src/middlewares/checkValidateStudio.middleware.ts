import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import { isValidDate } from "../helpers/date.helper";
import IResp from "../types/IResp.interface";

const checkValidateStudioMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    const { city_id, name, general_contract_date } = req.body;

    if (!city_id) {
      res.status(400).json({ status: false, error: errors.studioCityRequired });
      return;
    }

    if (!name.trim()) {
      res.status(400).json({ status: false, error: errors.studioShortNameRequired });
      return;
    }

    if (!isValidDate(general_contract_date)) {
      res.status(400).json({ status: false, error: errors.studioDateInvalid });
      return;
    }

    next();
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkValidateStudioMiddleware;
