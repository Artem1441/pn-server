import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
// import { isValidDate } from "../helpers/date.helper";
import IResp from "../types/IResp.interface";

const checkValidatePriceMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    const { city_id } = req.body;

    if (!city_id) {
      res.status(400).json({ status: false, error: errors.priceCityRequired });
      return;
    }

    // if (!name.trim()) {
    //   res.status(400).json({ status: false, error: errors.studioShortNameRequired });
    //   return;
    // }

    // if (!isValidDate(general_contract_date)) {
    //   res.status(400).json({ status: false, error: errors.studioDateInvalid });
    //   return;
    // }

    next();
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkValidatePriceMiddleware;
