import errors from "../constants/errors";
import { Periodicity } from "../models/Periodicity.model";
import { Speciality } from "../models/Speciality.model";
import { TerminationReason } from "../models/TerminationReason.model";
import IPeriodicity from "../types/IPeriodicity.interface";
import ISpeciality from "../types/ISpeciality.interface";
import ITerminationReason from "../types/ITerminationReason.interface";

export const getSettingsPeriodicity = async (): Promise<IPeriodicity> => {
  try {
    const settingsPeriodicity = await Periodicity.findOne();
    if (!settingsPeriodicity)
      return await Periodicity.create(getDefaultSettingsPeriodicity());
    return settingsPeriodicity;
  } catch (error) {
    console.error("Ошибка при получении переодичности в настройках:", error);
    throw null;
  }
};

export const updateSettingsPeriodicity = async ({
  id,
  reporting_frequency,
  reporting_day_of_week,
  document_send_frequency,
  document_send_email,
}: {
  id: IPeriodicity["id"];
  reporting_frequency: IPeriodicity["reporting_frequency"];
  reporting_day_of_week: IPeriodicity["reporting_day_of_week"];
  document_send_frequency: IPeriodicity["document_send_frequency"];
  document_send_email: IPeriodicity["document_send_email"];
}): Promise<void> => {
  try {
    const settingsPeriodicity = await Periodicity.findByPk(id);
    if (!settingsPeriodicity) throw null;
    settingsPeriodicity.reporting_frequency = reporting_frequency;
    settingsPeriodicity.reporting_day_of_week = reporting_day_of_week;
    settingsPeriodicity.document_send_frequency = document_send_frequency;
    settingsPeriodicity.document_send_email = document_send_email;

    await settingsPeriodicity.save();
  } catch (error) {
    console.error("Ошибка при обновлении переодичности в настройках:", error);
    throw null;
  }
};

const getDefaultSettingsPeriodicity = (): Partial<IPeriodicity> => ({
  reporting_frequency: "2week",
  reporting_day_of_week: "sunday",
  document_send_frequency: "monthly",
  document_send_email: "mail@pronogti.studio",
});

export const createSettingsTerminationReason = async ({
  speciality_id,
  reason,
  description,
}: {
  speciality_id: ITerminationReason["speciality_id"];
  reason: ITerminationReason["reason"];
  description: ITerminationReason["description"];
}): Promise<number> => {
  try {
    const settingsTerminationReason = await TerminationReason.create({
      speciality_id,
      reason,
      description,
    });
    return settingsTerminationReason.id;
  } catch (error) {
    console.error(
      "Ошибка при создании причины для увольнения в настройках:",
      error
    );
    return -1;
  }
};

export const updateSettingsTerminationReason = async ({
  id,
  speciality_id,
  reason,
  description,
}: {
  id: ITerminationReason["id"];
  speciality_id: ITerminationReason["speciality_id"];
  reason: ITerminationReason["reason"];
  description: ITerminationReason["description"];
}): Promise<void> => {
  try {
    const settingsTerminationReason = await TerminationReason.findByPk(id);
    if (!settingsTerminationReason) throw null;
    settingsTerminationReason.speciality_id = speciality_id;
    settingsTerminationReason.reason = reason;
    settingsTerminationReason.description = description;

    await settingsTerminationReason.save();
  } catch (err) {
    console.error(
      "Ошибка при обновлении причины для увольнения в настройках:",
      err
    );
    throw null;
  }
};

export const deleteSettingsTerminationReason = async (
  id: ITerminationReason["id"]
): Promise<void> => {
  try {
    const settingsTerminationReason = await TerminationReason.findByPk(id);

    if (!settingsTerminationReason)
      throw new Error(errors.settingsTerminationReasonNotFound);

    await settingsTerminationReason.destroy();
  } catch (err) {
    console.error(
      "Ошибка при удалении причины для увольнения в настройках:",
      err
    );
    throw null;
  }
};

export const getSettingsTerminationReasons = async (): Promise<
  ITerminationReason[]
> => {
  try {
    const settingsTerminationReason = await TerminationReason.findAll({
      include: [
        {
          model: Speciality,
          as: "speciality",
          required: false,
        },
      ],
    });

    return settingsTerminationReason;
  } catch (error) {
    console.error(
      "Ошибка при получении причин для увольнения в настройках:",
      error
    );
    throw null;
  }
};

export const getSettingsTerminationReasonsBySpecialityId = async (
  specialityId: ISpeciality["id"]
): Promise<ITerminationReason[]> => {
  try {
    const settingsTerminationReasons = await TerminationReason.findAll({
      include: [
        {
          model: Speciality,
          as: "speciality",
          where: {
            id: specialityId,
          },
          required: true,
        },
      ],
    });

    return settingsTerminationReasons;
  } catch (error) {
    console.error(
      `Ошибка при получении причин увольнения для специальности с ID ${specialityId}:`,
      error
    );
    throw error;
  }
};
