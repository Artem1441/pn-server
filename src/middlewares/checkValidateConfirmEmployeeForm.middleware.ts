import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import IResp from "../types/IResp.interface";
import ISpeciality from "../types/ISpeciality.interface";
import IStudio from "../types/IStudio.interface";

const checkValidateConfirmEmployeeFormMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      speciality_id,
      studio_ids,
    }: {
      id: number;
      speciality_id: ISpeciality["id"];
      studio_ids: IStudio["id"][];
    } = req.body;

    if (!speciality_id) {
      res
        .status(400)
        .json({ status: false, error: errors.specialityIdRequired });
      return;
    }
    if (!studio_ids.length) {
      res.status(400).json({ status: false, error: errors.studioIdsRequired });
      return;
    }

    next();
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkValidateConfirmEmployeeFormMiddleware;
