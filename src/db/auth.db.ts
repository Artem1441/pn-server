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

export const getUserById = async (id: number): Promise<IUser> => {
  const user = await User.findByPk(id);
  if (!user) throw new Error(errors.userNotFound);
  return user.toJSON();
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

export const getUserByField = async (
  field: string,
  value: string
): Promise<IUser | null> => {
  const user = await User.findOne({
    where: { [field]: value },
  });
  if (!user) return null;
  return user.toJSON();
};

export const getUsersByField = async (
  field: string,
  value: string
): Promise<IUser[] | null> => {
  const users = await User.findAll({
    where: { [field]: value },
  });

  if (!users || users.length === 0) return null;

  return users.map((user) => user.toJSON());
};

export const createUser = async ({
  name,
  surname,
  patronymic,
  phone,
  email,
  inn,
}: {
  name: IUser["name"];
  surname: IUser["surname"];
  patronymic?: IUser["patronymic"];
  phone: IUser["phone"];
  email: IUser["email"];
  inn: IUser["inn"];
}): Promise<number> => {
  try {
    const login = generateLogin(name, surname);
    const temporaryPassword = "";
    const hashedPassword = await hashPassword(temporaryPassword);

    const user = await User.create({
      name,
      surname,
      patronymic,
      phone,
      email,
      inn,
      login,
      password: hashedPassword,
    });

    return user.id;
  } catch (err) {
    console.log(err);
    return -1;
  }
};

export const updatePersonalDataToUser = async ({
  id,
  passport,
  bank_bik,
  bank_acc,
  passport_main,
  passport_registration,
  photo_front,
}: {
  id: number;
  passport: IUser["passport"];
  bank_bik: IUser["bank_bik"];
  bank_acc: IUser["bank_acc"];
  passport_main: IUser["passport_main"];
  passport_registration: IUser["passport_registration"];
  photo_front: IUser["photo_front"];
}): Promise<void> => {
  const user = await User.findByPk(id);
  if (!user) throw new Error(errors.userNotFound);

  user.passport = passport;
  user.bank_bik = bank_bik;
  user.bank_acc = bank_acc;
  user.passport_main = passport_main;
  user.passport_registration = passport_registration;
  user.photo_front = photo_front;
  user.registration_status = "under review";
  await user.save();
};

export const updateUserFieldById = async ({
  id,
  field,
  value,
}: {
  id: number;
  field: string;
  value: any;
}) => {
  const user = await User.findByPk(id);

  if (!user) throw new Error(errors.userNotFound);

  if (!(field in user)) {
    throw new Error(`Field "${field}" does not exist in User model`);
  }

  (user as any)[field] = value;

  try {
    await user.save();
    return user;
  } catch (error) {
    if (error instanceof ValidationError) {
      throw new Error(
        `Validation error while updating field "${field}": ${error.message}`
      );
    }
    throw error;
  }
};

export const deleteUserById = async (id: number): Promise<void> => {
  const user = await User.findByPk(id);

  if (!user) throw new Error(errors.userNotFound);

  try {
    await user.destroy();
  } catch (error) {
    if (error instanceof ValidationError) {
      throw new Error(`Failed to delete user with ID ${error.message}`);
    }
    throw error;
  }
};
