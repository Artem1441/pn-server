import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import IInformation from "../types/IInformation.interface";
import IResp from "../types/IResp.interface";

const hasEmptyFields = (information: IInformation): boolean => {
  return Object.entries(information).some(([key, value]) => {
    if (key === "id" || key === "updated_at" || key === "general_role")
      return false;
    return value.trim() === "";
  });
};

const checkValidateInformationMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    const information: IInformation = req.body.information;

    if (hasEmptyFields(information)) {
      res
        .status(400)
        .json({ status: false, error: errors.allFieldsRequired });
      return;
    }
    // const { name, surname, email, phone, inn } = req.body;

    // if (!name.trim() || !surname.trim()) {
    //   res
    //     .status(400)
    //     .json({ status: false, error: errors.nameAndSurnameInvalid });
    //   return;
    // }

    // if (!/^\d{11}$/.test(phone) || !/^7\d{10}$/.test(phone)) {
    //   res
    //     .status(400)
    //     .json({ status: false, error: errors.phoneInvalid });
    //   return;
    // }

    // if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    //   res
    //     .status(400)
    //     .json({ status: false, error: errors.emailInvalid });
    //   return;
    // }

    // if (!/^\d{12}$/.test(inn)) {
    //   res
    //     .status(400)
    //     .json({ status: false, error: errors.innInvalid });
    //   return;
    // }

    next();
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkValidateInformationMiddleware;
