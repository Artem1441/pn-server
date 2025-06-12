export default interface IInformation {
  id: number;
  full_name?: string;
  short_name?: string;
  inn?: string;
  ogrn?: string;
  kpp?: string;
  okved?: string;

  director_fio?: string;
  director_position?: string;
  director_basis?: string;

  authorized_person_fio?: string;
  authorized_person_position?: string;
  authorized_person_basis?: string;

  general_role: "director" | "authorized_person";

  legal_address?: string;
  correspondence_address?: string;
  contact_phone?: string;
  accounting_phone?: string;
  email?: string;
  website?: string;

  bank_acc?: string;
  bank_bik?: string;
  bank_cor?: string;
  bank_name?: string;

  company_card?: string;
  inn_file?: string;
  ustat?: string;
  stamp?: string;
  power_of_attorney?: string;
  director_signature?: string;
  authorized_person_signature?: string;
  updated_at: Date;
}
