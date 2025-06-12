export default interface IInformationChange {
  id: number;
  changed_field: string;
  old_value?: string; 
  new_value?: string; 
  changed_by_fio: string;
  changed_by_role: "director" | "authorized_person";
  created_at?: Date;
}
