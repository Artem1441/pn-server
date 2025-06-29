export default interface IPrice {
  id: number;
  city_id: number;
  self_employed_data: IPriceSelfEmployedDataItem[];
  clients_mani_data: IPriceClientsDataItem[];
  clients_pedi_data: IPriceClientsDataItem[];
  clients_mani_pedi_four_hands_data: IPriceClientsDataItem[];
  clients_design_data: IPriceClientsDataItem[];
  clients_additional_nail_services_data: IPriceClientsDataItem[];
  clients_brow_arch_data: IPriceClientsDataItem[];
  clients_promo_data: IPriceClientsDataItem[];
  clients_model_data: IPriceClientsDataItem[];
  clients_goods_data: IPriceClientsDataItem[];
  created_at: Date;
  updated_at: Date;
}
export interface IPriceClientsDataItem {
  name: string;
  from: boolean;
  price: number | null;
  time: number | null;
}

export interface IPriceSelfEmployedDataItem {
  name: string;
  rent_price: number | null;
  agent_price: number | null;
  other: number | null;
}
