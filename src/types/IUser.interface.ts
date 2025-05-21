import RoleType from "./RoleType.type";

interface IUser {
  id: number;
  role: RoleType;
  login: string;
  password: string;
  name: string;
  surname: string;
  patronymic?: string;
  phone: string;
  is_confirmed_phone: boolean;
  email: string;
  is_confirmed_email: boolean;
  inn: string;
  is_banned: boolean;
  time_zone:
    | "UTC+2"
    | "UTC+3"
    | "UTC+4"
    | "UTC+5"
    | "UTC+6"
    | "UTC+7"
    | "UTC+8"
    | "UTC+9"
    | "UTC+10"
    | "UTC+11"
    | "UTC+12";
  locale: "ru" | "en";
  bank_bik?: string;
  bank_acc?: string;
  birthdate?: Date;
  address_reg?: string;
  passport?: {
    passport_series: string;
    passport_number: string;
    issue_date: string;
    issued_by: string;
    nationality: string;
    registration_address: string;
    residential_address: string;
    birthdate: string;
  };
  equipments?: any; // JSONB, can be typed more strictly if structure is known
  ycl_staff_id?: number;
  agent_percent?: number;
  speciality_id?: number;
  studio_id?: number;
  passport_main?: string;
  passport_registration?: string;
  photo_front?: string;
  registration_status:
    | "in the process of filling"
    | "under review"
    | "confirmed";
  created_at: Date;
  updated_at: Date;
}

export default IUser;
