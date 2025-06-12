import { Request, Response } from "express";
import errors from "../constants/errors";
import {
  createStudio,
  deleteStudio,
  getStudios,
  updateStudio,
} from "../db/studio.db";
import IResp from "../types/IResp.interface";
import IStudio from "../types/IStudio.interface";

class StudioController {
  getStudios = async (
    req: Request,
    res: Response<IResp<IStudio[]>>
  ): Promise<void> => {
    try {
      const studios = await getStudios();
      res.status(200).json({
        status: true,
        data: studios,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  createStudio = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const {
      name,
      general_full_address,
      general_area,
      general_cadastral_number,
      general_contract_number,
      general_contract_date,
      general_registration,
      general_rent_price_per_sqm,
      general_owner_last_name,
      general_owner_first_name,
      general_owner_middle_name,
      general_owner_phone,
      general_owner_email,
      general_coowner_available,
      general_coowner_last_name,
      general_coowner_first_name,
      general_coowner_middle_name,
      general_coowner_phone,
      general_coowner_email,
      general_work_schedule,
      general_work_schedule_weekdays,
      general_work_schedule_weekends,
      general_wifi_password,
      general_alarm_code,
      general_lock_code,
      general_services_mani,
      general_services_pedi,
      general_services_brows,
      general_sublease_available,
      general_sublease_area,
      general_sublease_activity_type,
      general_sublease_rent_price_per_sqm,
      general_sublease_contact_last_name,
      general_sublease_contact_first_name,
      general_sublease_contact_middle_name,
      general_sublease_contact_phone,
      general_sublease_contact_email,
    } = req.body;

    try {
      await createStudio({
        name,
        general_full_address,
        general_area,
        general_cadastral_number,
        general_contract_number,
        general_contract_date,
        general_registration,
        general_rent_price_per_sqm,
        general_owner_last_name,
        general_owner_first_name,
        general_owner_middle_name,
        general_owner_phone,
        general_owner_email,
        general_coowner_available,
        general_coowner_last_name,
        general_coowner_first_name,
        general_coowner_middle_name,
        general_coowner_phone,
        general_coowner_email,
        general_work_schedule,
        general_work_schedule_weekdays,
        general_work_schedule_weekends,
        general_wifi_password,
        general_alarm_code,
        general_lock_code,
        general_services_mani,
        general_services_pedi,
        general_services_brows,
        general_sublease_available,
        general_sublease_area,
        general_sublease_activity_type,
        general_sublease_rent_price_per_sqm,
        general_sublease_contact_last_name,
        general_sublease_contact_first_name,
        general_sublease_contact_middle_name,
        general_sublease_contact_phone,
        general_sublease_contact_email,
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

  updateStudio = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const {
      id,
      name,
      general_full_address,
      general_area,
      general_cadastral_number,
      general_contract_number,
      general_contract_date,
      general_registration,
      general_rent_price_per_sqm,
      general_owner_last_name,
      general_owner_first_name,
      general_owner_middle_name,
      general_owner_phone,
      general_owner_email,
      general_coowner_available,
      general_coowner_last_name,
      general_coowner_first_name,
      general_coowner_middle_name,
      general_coowner_phone,
      general_coowner_email,
      general_work_schedule,
      general_work_schedule_weekdays,
      general_work_schedule_weekends,
      general_wifi_password,
      general_alarm_code,
      general_lock_code,
      general_services_mani,
      general_services_pedi,
      general_services_brows,
      general_sublease_available,
      general_sublease_area,
      general_sublease_activity_type,
      general_sublease_rent_price_per_sqm,
      general_sublease_contact_last_name,
      general_sublease_contact_first_name,
      general_sublease_contact_middle_name,
      general_sublease_contact_phone,
      general_sublease_contact_email,
    } = req.body;

    try {
      await updateStudio({
        id,
        name,
        general_full_address,
        general_area,
        general_cadastral_number,
        general_contract_number,
        general_contract_date,
        general_registration,
        general_rent_price_per_sqm,
        general_owner_last_name,
        general_owner_first_name,
        general_owner_middle_name,
        general_owner_phone,
        general_owner_email,
        general_coowner_available,
        general_coowner_last_name,
        general_coowner_first_name,
        general_coowner_middle_name,
        general_coowner_phone,
        general_coowner_email,
        general_work_schedule,
        general_work_schedule_weekdays,
        general_work_schedule_weekends,
        general_wifi_password,
        general_alarm_code,
        general_lock_code,
        general_services_mani,
        general_services_pedi,
        general_services_brows,
        general_sublease_available,
        general_sublease_area,
        general_sublease_activity_type,
        general_sublease_rent_price_per_sqm,
        general_sublease_contact_last_name,
        general_sublease_contact_first_name,
        general_sublease_contact_middle_name,
        general_sublease_contact_phone,
        general_sublease_contact_email,
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

  deleteStudio = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { id } = req.query;

    try {
      if (id) await deleteStudio(Number(id));

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

export default new StudioController();
