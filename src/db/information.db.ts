import { Information } from "../models/Information.model.js";
import { InformationChange } from "../models/InformationChange.model.js";
import IInformation from "../types/IInformation.interface.js";
import IInformationChange from "../types/IInformationChange.interface.js";

export const getInformation = async (): Promise<IInformation> => {
  try {
    const info = await Information.findOne();
    if (!info) return await Information.create(getDefaultInformation());
    return info;
  } catch (error) {
    console.error("Ошибка при получении информации:", error);
    throw null;
  }
};

export const updateInformation = async (
  information: IInformation
): Promise<void> => {
  try {
    const info = await Information.findByPk(information.id);
    if (!info) throw null;
    info.full_name = information.full_name;
    info.short_name = information.short_name;
    info.inn = information.inn;
    info.ogrn = information.ogrn;
    info.kpp = information.kpp;
    info.okved = information.okved;

    info.director_fio = information.director_fio;
    info.director_position = information.director_position;
    info.director_basis = information.director_basis;

    info.authorized_person_fio = information.authorized_person_fio;
    info.authorized_person_position = information.authorized_person_position;
    info.authorized_person_basis = information.authorized_person_basis;

    info.general_role = information.general_role;

    info.legal_address = information.legal_address;
    info.correspondence_address = information.correspondence_address;
    info.contact_phone = information.contact_phone;
    info.accounting_phone = information.accounting_phone;
    info.email = information.email;
    info.website = information.website;
    info.bank_acc = information.bank_acc;
    info.bank_bik = information.bank_bik;
    info.bank_cor = information.bank_cor;
    info.bank_name = information.bank_name;
    info.company_card = information.company_card;
    info.inn_file = information.inn_file;
    info.ustat = information.ustat;
    info.stamp = information.stamp;
    info.power_of_attorney = information.power_of_attorney;
    info.director_signature = information.director_signature;
    info.authorized_person_signature = information.authorized_person_signature;

    await info.save();
  } catch (error) {
    console.error("Ошибка при обновлении информации:", error);
    throw null;
  }
};

export const createInformationChange = async ({
  changed_field,
  old_value,
  new_value,
  changed_by_fio,
  changed_by_role,
}: {
  changed_field: IInformationChange["changed_field"];
  old_value: IInformationChange["old_value"];
  new_value: IInformationChange["new_value"];
  changed_by_fio: IInformationChange["changed_by_fio"];
  changed_by_role: IInformationChange["changed_by_role"];
}): Promise<void> => {
  try {
    await InformationChange.create({
      changed_field,
      old_value,
      new_value,
      changed_by_fio,
      changed_by_role,
    });
  } catch (error) {
    console.error("Ошибка при создании изменения информации:", error);
    throw null;
  }
};

export const getInformationChanges = async (): Promise<IInformationChange[]> => {
  try {
    const informationChanges = await InformationChange.findAll();
    if (!informationChanges) throw null
    return informationChanges;
  } catch (error) {
    console.error("Ошибка при получении информации изменений:", error);
    throw null;
  }
};

const getDefaultInformation = (): Omit<
  Partial<IInformation>,
  "general_role"
> & {
  general_role: "director" | "authorized_person";
} => ({
  general_role: "director",
  full_name: "",
  short_name: "",
  inn: "",
  ogrn: "",
  kpp: "",
  okved: "",
  director_fio: "",
  director_position: "",
  director_basis: "",
  authorized_person_fio: "",
  authorized_person_position: "",
  authorized_person_basis: "",
  legal_address: "",
  correspondence_address: "",
  contact_phone: "",
  accounting_phone: "",
  email: "",
  website: "",
  bank_acc: "",
  bank_bik: "",
  bank_cor: "",
  bank_name: "",
  company_card: "",
  inn_file: "",
  ustat: "",
  stamp: "",
  power_of_attorney: "",
  director_signature: "",
  authorized_person_signature: "",
});
