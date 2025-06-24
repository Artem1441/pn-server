import IPriceClientsDataItem from "./IPriceClientsDataItem.interface";
import IPriceSelfEmployedDataItem from "./IPriceSelfEmployedDataItem.interface";

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
