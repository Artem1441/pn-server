import { NextFunction, Request, Response } from "express";
import errors from "../constants/errors";
import IResp from "../types/IResp.interface";

const isValidDate = (dateString: string): boolean => {
  const date = dateString.includes(".")
    ? new Date(dateString.split(".").reverse().join("-"))
    : new Date(dateString);
  return date.toString() !== "Invalid Date" && !isNaN(date.getTime());
};

const isAdult = (dateString: string): boolean => {
  const today = new Date();
  const birthDate = new Date(
    dateString.includes(".")
      ? dateString.split(".").reverse().join("-")
      : dateString
  );
  let age = today.getFullYear() - birthDate.getFullYear();
  const m = today.getMonth() - birthDate.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;
  return age >= 14;
};

const checkValidatePersonalDataMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      passport,
      bank_bik,
      bank_acc,
      passport_main,
      passport_registration,
      photo_front,
    } = req.body;

    if (!/^\d{4}$/.test(passport.passport_series)) {
      res
        .status(400)
        .json({ status: false, error: errors.passportSeriesInvalid });
      return;
    }

    if (!/^\d{6}$/.test(passport.passport_number)) {
      res
        .status(400)
        .json({ status: false, error: errors.passportNumberInvalid });
      return;
    }

    if (!isValidDate(passport.issue_date)) {
      res.status(400).json({ status: false, error: errors.issueDateInvalid });
      return;
    }

    if (!passport.issued_by.trim()) {
      res.status(400).json({ status: false, error: errors.issuedByInvalid });
      return;
    }

    if (!isValidDate(passport.birthdate) || !isAdult(passport.birthdate)) {
      res.status(400).json({ status: false, error: errors.birthdayInvalid });
      return;
    }

    if (!["РФ", "Российская Федерация"].includes(passport.nationality.trim())) {
      res.status(400).json({ status: false, error: errors.nationalityInvalid });
      return;
    }

    if (!passport.registration_address.trim()) {
      res
        .status(400)
        .json({ status: false, error: errors.registrationAddressInvalid });
      return;
    }

    if (!passport.residential_address.trim()) {
      res
        .status(400)
        .json({ status: false, error: errors.residentialAddressInvalid });
      return;
    }

    if (!passport_main) {
      res
        .status(400)
        .json({ status: false, error: errors.passportMainRequired });
      return;
    }

    if (!passport_registration) {
      res
        .status(400)
        .json({ status: false, error: errors.passportRegistrationRequired });
      return;
    }

    if (!photo_front) {
      res
        .status(400)
        .json({ status: false, error: errors.passportRegistrationRequired });
      return;
    }

    if (!/^\d{9}$/.test(bank_bik)) {
      res.status(400).json({ status: false, error: errors.bankBikRequired });
      return;
    }

    if (!/^\d{20}$/.test(bank_acc)) {
      res.status(400).json({ status: false, error: errors.bankAccRequired });
      return;
    }
    next();
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkValidatePersonalDataMiddleware;
