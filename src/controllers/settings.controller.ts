import { Request, Response } from "express";
import errors from "../constants/errors";
import {
  createSettingsTerminationReason,
  deleteSettingsTerminationReason,
  getSettingsPeriodicity,
  getSettingsTerminationReasons,
  getSettingsTerminationReasonsBySpecialityId,
  updateSettingsPeriodicity,
  updateSettingsTerminationReason,
} from "../db/settings.db";
import { getSpecialities } from "../db/speciality.db";
import IPeriodicity from "../types/IPeriodicity.interface";
import IResp from "../types/IResp.interface";
import ISpeciality from "../types/ISpeciality.interface";
import ITerminationReason from "../types/ITerminationReason.interface";

class SettingsController {
  public getSettingsPeriodicity = async (
    req: Request,
    res: Response<IResp<IPeriodicity>>
  ): Promise<void> => {
    try {
      const settingsPeriodicity = await getSettingsPeriodicity();
      res.status(200).json({
        status: true,
        data: settingsPeriodicity,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public updateSettingsPeriodicity = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    try {
      const {
        id,
        reporting_frequency,
        reporting_day_of_week,
        document_send_frequency,
        document_send_email,
      } = req.body;

      await updateSettingsPeriodicity({
        id,
        reporting_frequency,
        reporting_day_of_week,
        document_send_frequency,
        document_send_email,
      });

      res.status(200).json({
        status: true,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public getSettingsTerminationReasons = async (
    req: Request,
    res: Response<
      IResp<
        { speciality: ISpeciality; terminationReasons: ITerminationReason[] }[]
      >
    >
  ): Promise<void> => {
    try {
      const specialities = await getSpecialities();

      const terminationReasons = await Promise.all(
        specialities.map(async (speciality) => {
          const terminationReasonsBySpecialityId =
            await getSettingsTerminationReasonsBySpecialityId(speciality.id);
          return {
            speciality,
            terminationReasons: terminationReasonsBySpecialityId,
          };
        })
      );

      res.status(200).json({
        status: true,
        data: terminationReasons,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public updateSettingsTerminationReason = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    try {
      const {
        terminationReasons,
      }: {
        terminationReasons: {
          speciality: ISpeciality;
          terminationReasons: ITerminationReason[];
        }[];
      } = req.body;

      const existIdxs: number[] = [];

      for (const item of terminationReasons) {
        for (const terminationReason of item.terminationReasons) {
          if (terminationReason.id) {
            await updateSettingsTerminationReason({
              id: terminationReason.id,
              speciality_id: terminationReason.speciality_id,
              reason: terminationReason.reason,
              description: terminationReason.description,
            });
            existIdxs.push(terminationReason.id);
          } else {
            const new_idx = await createSettingsTerminationReason({
              speciality_id: terminationReason.speciality_id,
              reason: terminationReason.reason,
              description: terminationReason.description,
            });
            existIdxs.push(new_idx);
          }
        }
      }

      const exludedIdxs: number[] = [];
      const allTerminationReasons = await getSettingsTerminationReasons();

      allTerminationReasons.map((terminationReason) => {
        if (!existIdxs.includes(terminationReason.id))
          exludedIdxs.push(terminationReason.id);
      });

      await Promise.all(
        exludedIdxs.map(
          async (idx) => await deleteSettingsTerminationReason(idx)
        )
      );

      res.status(200).json({
        status: true,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };
}

export default new SettingsController();
