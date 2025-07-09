export default interface IPeriodicity {
  id: number;
  reporting_frequency: "1week" | "2week";
  reporting_day_of_week:
    | "monday"
    | "tuesday"
    | "wednesday"
    | "thursday"
    | "friday"
    | "saturday"
    | "sunday";
  document_send_frequency:
    | "daily"
    | "weekly"
    | "monthly"
    | "quarterly"
    | "semiannually"
    | "annually";
  document_send_email: string;
  updated_at: Date;
}
