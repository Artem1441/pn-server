import errors from "../constants/errors";
import { City } from "../models/City.model";
import { Studio } from "../models/Studio.model";
import IStudio from "../types/IStudio.interface";

export const createStudio = async ({
  city_id,
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
}: {
  city_id: IStudio["city_id"];
  name: IStudio["name"];
  general_full_address: IStudio["general_full_address"];
  general_area: IStudio["general_area"];
  general_cadastral_number: IStudio["general_cadastral_number"];
  general_contract_number: IStudio["general_contract_number"];
  general_contract_date: IStudio["general_contract_date"];
  general_registration: IStudio["general_registration"];
  general_rent_price_per_sqm: IStudio["general_rent_price_per_sqm"];
  general_owner_last_name: IStudio["general_owner_last_name"];
  general_owner_first_name: IStudio["general_owner_first_name"];
  general_owner_middle_name: IStudio["general_owner_middle_name"];
  general_owner_phone: IStudio["general_owner_phone"];
  general_owner_email: IStudio["general_owner_email"];
  general_coowner_available: IStudio["general_coowner_available"];
  general_coowner_last_name: IStudio["general_coowner_last_name"];
  general_coowner_first_name: IStudio["general_coowner_first_name"];
  general_coowner_middle_name: IStudio["general_coowner_middle_name"];
  general_coowner_phone: IStudio["general_coowner_phone"];
  general_coowner_email: IStudio["general_coowner_email"];
  general_work_schedule: IStudio["general_work_schedule"];
  general_work_schedule_weekdays: IStudio["general_work_schedule_weekdays"];
  general_work_schedule_weekends: IStudio["general_work_schedule_weekends"];
  general_wifi_password: IStudio["general_wifi_password"];
  general_alarm_code: IStudio["general_alarm_code"];
  general_lock_code: IStudio["general_lock_code"];
  general_services_mani: IStudio["general_services_mani"];
  general_services_pedi: IStudio["general_services_pedi"];
  general_services_brows: IStudio["general_services_brows"];
  general_sublease_available: IStudio["general_sublease_available"];
  general_sublease_area: IStudio["general_sublease_area"];
  general_sublease_activity_type: IStudio["general_sublease_activity_type"];
  general_sublease_rent_price_per_sqm: IStudio["general_sublease_rent_price_per_sqm"];
  general_sublease_contact_last_name: IStudio["general_sublease_contact_last_name"];
  general_sublease_contact_first_name: IStudio["general_sublease_contact_first_name"];
  general_sublease_contact_middle_name: IStudio["general_sublease_contact_middle_name"];
  general_sublease_contact_phone: IStudio["general_sublease_contact_phone"];
  general_sublease_contact_email: IStudio["general_sublease_contact_email"];
}): Promise<number> => {
  try {
    const studio = await Studio.create({
      city_id,
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

      general_services_mani: Number(general_services_mani),
      general_services_pedi: Number(general_services_pedi),
      general_services_brows: Number(general_services_brows),

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
    return studio.id;
  } catch (error) {
    console.error("Ошибка при получении создании студии:", error);
    return -1;
  }
};

export const updateStudio = async ({
  id,
  city_id,
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
}: {
  id: IStudio["id"];
  city_id: IStudio["city_id"];
  name: IStudio["name"];
  general_full_address: IStudio["general_full_address"];
  general_area: IStudio["general_area"];
  general_cadastral_number: IStudio["general_cadastral_number"];
  general_contract_number: IStudio["general_contract_number"];
  general_contract_date: IStudio["general_contract_date"];
  general_registration: IStudio["general_registration"];
  general_rent_price_per_sqm: IStudio["general_rent_price_per_sqm"];
  general_owner_last_name: IStudio["general_owner_last_name"];
  general_owner_first_name: IStudio["general_owner_first_name"];
  general_owner_middle_name: IStudio["general_owner_middle_name"];
  general_owner_phone: IStudio["general_owner_phone"];
  general_owner_email: IStudio["general_owner_email"];
  general_coowner_available: IStudio["general_coowner_available"];
  general_coowner_last_name: IStudio["general_coowner_last_name"];
  general_coowner_first_name: IStudio["general_coowner_first_name"];
  general_coowner_middle_name: IStudio["general_coowner_middle_name"];
  general_coowner_phone: IStudio["general_coowner_phone"];
  general_coowner_email: IStudio["general_coowner_email"];
  general_work_schedule: IStudio["general_work_schedule"];
  general_work_schedule_weekdays: IStudio["general_work_schedule_weekdays"];
  general_work_schedule_weekends: IStudio["general_work_schedule_weekends"];
  general_wifi_password: IStudio["general_wifi_password"];
  general_alarm_code: IStudio["general_alarm_code"];
  general_lock_code: IStudio["general_lock_code"];
  general_services_mani: IStudio["general_services_mani"];
  general_services_pedi: IStudio["general_services_pedi"];
  general_services_brows: IStudio["general_services_brows"];
  general_sublease_available: IStudio["general_sublease_available"];
  general_sublease_area: IStudio["general_sublease_area"];
  general_sublease_activity_type: IStudio["general_sublease_activity_type"];
  general_sublease_rent_price_per_sqm: IStudio["general_sublease_rent_price_per_sqm"];
  general_sublease_contact_last_name: IStudio["general_sublease_contact_last_name"];
  general_sublease_contact_first_name: IStudio["general_sublease_contact_first_name"];
  general_sublease_contact_middle_name: IStudio["general_sublease_contact_middle_name"];
  general_sublease_contact_phone: IStudio["general_sublease_contact_phone"];
  general_sublease_contact_email: IStudio["general_sublease_contact_email"];
}): Promise<void> => {
  try {
    const studio = await Studio.findByPk(id);
    if (!studio) throw null;
    studio.city_id = city_id;
    studio.name = name;
    studio.general_full_address = general_full_address;
    studio.general_area = general_area;
    studio.general_cadastral_number = general_cadastral_number;
    studio.general_contract_number = general_contract_number;
    studio.general_contract_date = general_contract_date;
    studio.general_registration = general_registration;
    studio.general_rent_price_per_sqm = general_rent_price_per_sqm;
    studio.general_owner_last_name = general_owner_last_name;
    studio.general_owner_first_name = general_owner_first_name;
    studio.general_owner_middle_name = general_owner_middle_name;
    studio.general_owner_phone = general_owner_phone;
    studio.general_owner_email = general_owner_email;
    studio.general_coowner_available = general_coowner_available;
    studio.general_coowner_last_name = general_coowner_last_name;
    studio.general_coowner_first_name = general_coowner_first_name;
    studio.general_coowner_middle_name = general_coowner_middle_name;
    studio.general_coowner_phone = general_coowner_phone;
    studio.general_coowner_email = general_coowner_email;
    studio.general_work_schedule = general_work_schedule;
    studio.general_work_schedule_weekdays = general_work_schedule_weekdays;
    studio.general_work_schedule_weekends = general_work_schedule_weekends;
    studio.general_wifi_password = general_wifi_password;
    studio.general_alarm_code = general_alarm_code;
    studio.general_lock_code = general_lock_code;
    studio.general_services_mani = Number(general_services_mani);
    studio.general_services_pedi = Number(general_services_pedi);
    studio.general_services_brows = Number(general_services_brows);
    studio.general_sublease_available = general_sublease_available;
    studio.general_sublease_area = general_sublease_area;
    studio.general_sublease_activity_type = general_sublease_activity_type;
    studio.general_sublease_rent_price_per_sqm =
      general_sublease_rent_price_per_sqm;
    studio.general_sublease_contact_last_name =
      general_sublease_contact_last_name;
    studio.general_sublease_contact_first_name =
      general_sublease_contact_first_name;
    studio.general_sublease_contact_middle_name =
      general_sublease_contact_middle_name;
    studio.general_sublease_contact_phone = general_sublease_contact_phone;
    studio.general_sublease_contact_email = general_sublease_contact_email;

    await studio.save();
  } catch (err) {
    console.error("Ошибка при обновлении информации о студии:", err);
    throw null;
  }
};

export const deleteStudio = async (id: IStudio["id"]): Promise<void> => {
  try {
    const studio = await Studio.findByPk(id);

    if (!studio) throw new Error(errors.studioNotFound);

    await studio.destroy();
  } catch (err: any) {
    if (err.name === "SequelizeForeignKeyConstraintError") {
      console.error(
        "Невозможно удалить студию: она используется в других таблицах",
        err
      );
      throw new Error(errors.cannotDeleteEntityBecauseItIsUsed);
    }

    console.error("Ошибка при удалении студии:", err);
    throw null;
  }
};

export const getStudios = async (): Promise<IStudio[]> => {
  try {
    const studios = await Studio.findAll({
      include: [
        {
          model: City,
          as: "city",
          required: false,
        },
      ],
    });

    if (!studios) throw null;

    return studios;
  } catch (error) {
    console.error("Ошибка при получении информации студий:", error);
    throw null;
  }
};
