import { ValidationError } from "sequelize";
import errors from "../constants/errors";
import { hashPassword } from "../helpers/bcrypt.helper";
import { generateLogin } from "../helpers/generate.helper";
import { User } from "../models/User.model";
import IUser from "../types/IUser.interface";

export const getUserById = async <T extends (keyof IUser)[]>(
  id: IUser["id"],
  fields: T = [] as unknown as T
): Promise<(T extends [] ? IUser : Pick<IUser, T[number]>) | null> => {
  const user = await User.findByPk(id, {
    attributes: fields.length > 0 ? fields : undefined,
  });

  if (!user) return null
  if (!user) throw new Error(errors.userNotFound);

  return user.toJSON() as T extends [] ? IUser : Pick<IUser, T[number]>;
};

export const getUserByField = async <T extends (keyof IUser)[]>(
  field: keyof IUser,
  value: string,
  fields: T = [] as unknown as T
): Promise<(T extends [] ? IUser : Pick<IUser, T[number]>) | null> => {
  const user = await User.findOne({
    where: { [field]: value },
    attributes: fields.length > 0 ? fields : undefined,
  });

  if (!user) return null;

  return user.toJSON() as T extends [] ? IUser : Pick<IUser, T[number]>;
};

export const getUsersByField = async <T extends (keyof IUser)[]>(
  field: keyof IUser,
  value: string | number,
  fields: T = [] as unknown as T
): Promise<((T extends [] ? IUser : Pick<IUser, T[number]>)[]) | null> => {
  const users = await User.findAll({
    where: { [field]: value },
    attributes: fields.length > 0 ? fields : undefined,
  });

  if (!users || users.length === 0) return null;

  return users.map((user) => user.toJSON()) as (T extends [] ? IUser : Pick<IUser, T[number]>)[] | null;
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
    console.error(err);
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
  field: keyof IUser;
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
