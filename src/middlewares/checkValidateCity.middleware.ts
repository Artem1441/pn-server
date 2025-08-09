import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import ICity from "../types/ICity.interface";
import IResp from "../types/IResp.interface";

const checkValidateCityMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      name,
      city_code,
    }: {
      name: ICity["name"]
      city_code: ICity["city_code"]
    } = req.body

    if (!name.trim()) {
      res.status(400).json({ status: false, error: errors.cityNameRequired });
      return;
    }

    if (!city_code.trim()) {
      res.status(400).json({ status: false, error: errors.cityCodeRequired });
      return;
    }

    next();
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkValidateCityMiddleware;
