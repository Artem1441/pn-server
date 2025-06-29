export default interface IMotivation {
  id: number;
  allowance_data: IMotivationDataItem[];
  deduction_data: IMotivationDataItem[];
  updated_at: Date;
}

export interface IMotivationDataItem {
  name: string;
  condition: string;
  price: number | null;
}
