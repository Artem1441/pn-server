interface IStudio {
  id: number;
  name: string; // краткий адрес

  general_full_address?: string;
  general_area?: string;
  general_cadastral_number?: string;
  general_contract_number?: string;
  general_contract_date?: Date;
  general_registration?: string;
  general_rent_price_per_sqm?: string;

  general_owner_last_name?: string;
  general_owner_first_name?: string;
  general_owner_middle_name?: string;
  general_owner_phone?: string;
  general_owner_email?: string;

  general_coowner_available?: boolean;
  general_coowner_last_name?: string;
  general_coowner_first_name?: string;
  general_coowner_middle_name?: string;
  general_coowner_phone?: string;
  general_coowner_email?: string;

  general_work_schedule?: string;
  general_work_schedule_weekdays?: string;
  general_work_schedule_weekends?: string;
  general_wifi_password?: string;
  general_alarm_code?: string;
  general_lock_code?: string;

  general_services_mani?: number;
  general_services_pedi?: number;
  general_services_brows?: number;

  general_sublease_available?: boolean;
  general_sublease_area?: string;
  general_sublease_activity_type?: string;
  general_sublease_contact_last_name?: string;
  general_sublease_contact_first_name?: string;
  general_sublease_contact_middle_name?: string;
  general_sublease_contact_phone?: string;
  general_sublease_contact_email?: string;
  general_sublease_rent_price_per_sqm?: string;

  created_at: Date;
  updated_at: Date;
}

export default IStudio;
