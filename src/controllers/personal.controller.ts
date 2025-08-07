import { Request, Response } from "express";
import errors from "../constants/errors";
import { getUserById, updateUserFieldById } from "../db/personal.db";
import { getSpecialityById } from "../db/speciality.db";
import { getUserStudiosByUserId } from "../db/userStudios.db";
import { bcryptCompare, hashPassword } from "../helpers/bcrypt.helper";
import IResp from "../types/IResp.interface";
import ISpeciality from "../types/ISpeciality.interface";
import IStudio from "../types/IStudio.interface";
import IUser from "../types/IUser.interface";

interface IPersonalData {
  surname: IUser["surname"];
  name: IUser["name"];
  patronymic: IUser["patronymic"];
  inn: IUser["inn"];
  phone: IUser["phone"];
  email: IUser["email"];
  passport: IUser["passport"];
  bank_acc: IUser["bank_acc"];
  bank_bik: IUser["bank_bik"];
  passport_main: IUser["passport_main"];
  passport_registration: IUser["passport_registration"];
  photo_front: IUser["photo_front"];
  login: IUser["login"];
  speciality_name: ISpeciality["name"];
  studios: {
    name: IStudio["name"];
    general_wifi_password?: IStudio["general_wifi_password"];
  }[];
}

class PersonalController {
  public getPersonalData = async (
    req: Request,
    res: Response<IResp<IPersonalData>>
  ): Promise<void> => {
    const {
      user: { id },
    }: { user: { id: IUser["id"] } } = req.body;
    try {
      const user = await getUserById(id, [
        "speciality_id",
        "surname",
        "name",
        "patronymic",
        "inn",
        "phone",
        "email",
        "passport",
        "bank_acc",
        "bank_bik",
        "passport_main",
        "passport_registration",
        "photo_front",
        "login",
      ]);
      if (!user) throw new Error(errors.userNotFound);
      const { speciality_id } = user;

      if (!speciality_id) throw new Error(errors.specialityNotFound);
      const speciality = await getSpecialityById(speciality_id, ["name"]);
      if (!speciality) throw new Error(errors.specialityNotFound);
      const studios = await getUserStudiosByUserId(
        id,
        [],
        ["name", "general_wifi_password"]
      );
      if (!studios) throw new Error(errors.studiosNotFound);

      res.status(200).json({
        status: true,
        data: {
          surname: user.surname,
          name: user.name,
          patronymic: user.patronymic,
          inn: user.inn,
          phone: user.phone,
          email: user.email,
          passport: user.passport,
          bank_acc: user.bank_acc,
          bank_bik: user.bank_bik,
          passport_main: user.passport_main,
          passport_registration: user.passport_registration,
          photo_front: user.photo_front,
          login: user.login,
          speciality_name: speciality.name,
          studios: studios
            .map((item) => item.studio)
            .filter((studio): studio is IStudio => studio !== null),
        },
      });
      return;
    } catch (err: any) {
      console.error("getPersonalData error: ", err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public changePassword = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const {
      user: { id },
      currentPassword,
      newPassword,
    }: {
      user: {
        id: IUser["id"];
      };
      currentPassword: IUser["password"];
      newPassword: IUser["password"];
    } = req.body;

    try {
      const user = await getUserById(id, ["password"]);
      if (!user) throw new Error(errors.userNotFound);

      const isPassword = await bcryptCompare(currentPassword, user.password);

      if (!isPassword) {
        res.status(401).json({
          status: false,
          error: errors.incorrectPassword,
        });
        return;
      }

      const hashedPassword = await hashPassword(newPassword);

      await updateUserFieldById({
        id,
        field: "password",
        value: hashedPassword,
      });

      res.status(200).json({ status: true });
    } catch (err: any) {
      console.error("changePassword error: ", err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };
}

export default new PersonalController();
