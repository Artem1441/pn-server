import { Op, ValidationError } from "sequelize";
import errors from "../constants/errors.js";
import { hashPassword } from "../helpers/bcrypt.helper.js";
import { generateLogin } from "../helpers/generate.helper.js";
import { User } from "../models/User.model.js";
import { VerificationCode } from "../models/VerificationCode.model.js";
import IUser from "../types/IUser.interface.js";
import IVerificationCode from "../types/IVerificationCode.interface.js";

export const getActiveVerificationCode = async (
  userId: number,
  type: "phone" | "email",
  value: string,
  code: string
): Promise<IVerificationCode> => {
  const verificationCode = await VerificationCode.findOne({
    where: {
      user_id: userId,
      type,
      value,
      code,
      expires_at: { [Op.gt]: new Date() },
      is_used: false,
    },
  });

  if (!verificationCode) throw new Error(errors.invalidOrExpiredCode);

  return verificationCode;
};

export const confirmUserPhone = async (userId: number): Promise<void> => {
  const user = await User.findByPk(userId);
  if (!user) throw new Error(errors.userNotFound);

  user.is_confirmed_phone = true;
  await user.save();
};

export const confirmUserEmail = async (userId: number): Promise<void> => {
  const user = await User.findByPk(userId);
  if (!user) throw new Error(errors.userNotFound);

  user.is_confirmed_email = true;
  await user.save();
};

export const markVerificationCodeAsUsed = async (id: number): Promise<void> => {
  const verificationCode = await VerificationCode.findByPk(id);
  if (!verificationCode) {
    throw new Error("Verification code not found");
  }

  verificationCode.is_used = true;
  await verificationCode.save();
};

export const createVerificationCode = async ({
  userId,
  type,
  value,
  code,
  expiresAt,
}: {
  userId: number;
  type: "phone" | "email";
  value: string;
  code: string;
  expiresAt: Date;
}): Promise<IVerificationCode> => {
  const verificationCode = await VerificationCode.create({
    user_id: userId,
    type,
    value,
    code,
    expires_at: expiresAt,
  });

  return verificationCode.toJSON();
};


