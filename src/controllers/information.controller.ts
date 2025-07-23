import { Request, Response } from "express";
import errors from "../constants/errors";
import informationFields from "../constants/informationFields";
import {
  createInformationChange,
  getInformation,
  getInformationChanges,
  updateInformation,
} from "../db/information.db";
import IInformation from "../types/IInformation.interface";
import IInformationChange from "../types/IInformationChange.interface";
import IResp from "../types/IResp.interface";

class InformationController {
  public getInformation = async (
    req: Request,
    res: Response<IResp<IInformation>>
  ): Promise<void> => {
    try {
      const information = await getInformation();
      res.status(200).json({
        status: true,
        data: information,
      });
      return;
    } catch (err) {
      console.error(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public updateInformation = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    try {
      const information: IInformation = req.body.information;
      const oldInformation = await getInformation();
      const changed_by_fio =
        oldInformation.general_role === "director"
          ? oldInformation.director_fio ?? ""
          : oldInformation.authorized_person_fio ?? "";

      for (const key of Object.keys(information) as (keyof IInformation)[]) {
        if (
          key !== "id" &&
          key !== "updated_at" &&
          information[key] !== oldInformation[key] &&
          oldInformation[key] !== ""
        ) {
          await createInformationChange({
            changed_field: informationFields[key],
            old_value: oldInformation[key],
            new_value: information[key],
            changed_by_fio,
            changed_by_role: information.general_role,
          });
        }
      }

      await updateInformation(information);

      res.status(200).json({
        status: true,
      });
      return;
    } catch (err) {
      console.error(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public getInformationChanges = async (
    req: Request,
    res: Response<IResp<IInformationChange[]>>
  ): Promise<void> => {
    try {
      const informationChanges = await getInformationChanges();
      res.status(200).json({
        status: true,
        data: informationChanges,
      });
      return;
    } catch (err) {
      console.error(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };
}

export default new InformationController();
