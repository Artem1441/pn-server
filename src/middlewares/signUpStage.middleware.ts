import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import registrationStages from "../constants/registrationStages";
import { getUserById } from "../db/auth.db";
import { jwtVerify } from "../helpers/jwt.helper";
import IResp from "../types/IResp.interface";
import StageType from "../types/StageType.type";

const signUpStageMiddleware = async (
  req: Request,
  res: Response<IResp<StageType>>,
  next: NextFunction
) => {
  try {
    const token = req.cookies.signUpToken;
    if (!token) {
      res.status(200).json({
        status: true,
        data: registrationStages.accessionAgreement,
      });
      return;
    }

    const decoded = jwtVerify(token);
    const userId = decoded.id;

    const user = await getUserById(userId);

    const {registration_status} = user

    if (registration_status === "under review") {
      res.status(200).json({
        status: true,
        data:registrationStages.waitingRoom,
      });
      return;
    }

    const { is_confirmed_phone, is_confirmed_email } = user;

    if (!is_confirmed_phone || !is_confirmed_email) {
      res.status(200).json({
        status: true,
        data:registrationStages.identificationData,
      });
      return;
    }

    res.status(200).json({
      status: true,
      data: registrationStages.personalData,
    });
    next();
    return;
  } catch (error) {
    console.log(error);
    res.status(401).json({
      status: false,
      error: errors.serverError,
    });
    return;
  }
};

export default signUpStageMiddleware;
