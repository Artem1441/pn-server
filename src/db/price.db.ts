import errors from "../constants/errors";
import { City } from "../models/City.model";
import { Price } from "../models/Price.model";
import IPrice from "../types/IPrice.interface";

export const createPrice = async ({
  city_id,
  self_employed_data,
  clients_mani_data,
  clients_pedi_data,
  clients_mani_pedi_four_hands_data,
  clients_design_data,
  clients_additional_nail_services_data,
  clients_brow_arch_data,
  clients_promo_data,
  clients_model_data,
  clients_goods_data,
}: {
  city_id: IPrice["city_id"];
  self_employed_data: IPrice["self_employed_data"];
  clients_mani_data: IPrice["clients_mani_data"];
  clients_pedi_data: IPrice["clients_pedi_data"];
  clients_mani_pedi_four_hands_data: IPrice["clients_mani_pedi_four_hands_data"];
  clients_design_data: IPrice["clients_design_data"];
  clients_additional_nail_services_data: IPrice["clients_additional_nail_services_data"];
  clients_brow_arch_data: IPrice["clients_brow_arch_data"];
  clients_promo_data: IPrice["clients_promo_data"];
  clients_model_data: IPrice["clients_model_data"];
  clients_goods_data: IPrice["clients_goods_data"];
}): Promise<number> => {
  try {
    const price = await Price.create({
      city_id,
      self_employed_data,
      clients_mani_data,
      clients_pedi_data,
      clients_mani_pedi_four_hands_data,
      clients_design_data,
      clients_additional_nail_services_data,
      clients_brow_arch_data,
      clients_promo_data,
      clients_model_data,
      clients_goods_data,
    });
    return price.id;
  } catch (error) {
    console.error("Ошибка при создании цены:", error);
    return -1;
  }
};

export const updatePrice = async ({
  id,
  city_id,
  self_employed_data,
  clients_mani_data,
  clients_pedi_data,
  clients_mani_pedi_four_hands_data,
  clients_design_data,
  clients_additional_nail_services_data,
  clients_brow_arch_data,
  clients_promo_data,
  clients_model_data,
  clients_goods_data,
}: {
  id: IPrice["id"];
  city_id: IPrice["city_id"];
  self_employed_data: IPrice["self_employed_data"];
  clients_mani_data: IPrice["clients_mani_data"];
  clients_pedi_data: IPrice["clients_pedi_data"];
  clients_mani_pedi_four_hands_data: IPrice["clients_mani_pedi_four_hands_data"];
  clients_design_data: IPrice["clients_design_data"];
  clients_additional_nail_services_data: IPrice["clients_additional_nail_services_data"];
  clients_brow_arch_data: IPrice["clients_brow_arch_data"];
  clients_promo_data: IPrice["clients_promo_data"];
  clients_model_data: IPrice["clients_model_data"];
  clients_goods_data: IPrice["clients_goods_data"];
}): Promise<void> => {
  try {
    const price = await Price.findByPk(id);
    if (!price) throw null;
    price.city_id = city_id;
    price.self_employed_data = self_employed_data;
    price.clients_mani_data = clients_mani_data;
    price.clients_pedi_data = clients_pedi_data;
    price.clients_mani_pedi_four_hands_data = clients_mani_pedi_four_hands_data;
    price.clients_design_data = clients_design_data;
    price.clients_additional_nail_services_data =
      clients_additional_nail_services_data;
    price.clients_brow_arch_data = clients_brow_arch_data;
    price.clients_promo_data = clients_promo_data;
    price.clients_model_data = clients_model_data;
    price.clients_goods_data = clients_goods_data;

    await price.save();
  } catch (err) {
    console.error("Ошибка при обновлении информации о ценах:", err);
    throw null;
  }
};

export const deletePrice = async (id: IPrice["id"]): Promise<void> => {
  try {
    const price = await Price.findByPk(id);

    if (!price) throw new Error(errors.priceNotFound);

    await price.destroy();
  } catch (err) {
    console.error("Ошибка при удалении цены:", err);
    throw null;
  }
};

export const getPrices = async (): Promise<IPrice[]> => {
  try {
    const prices = await Price.findAll({
      include: [
        {
          model: City,
          as: "city",
          required: false,
        },
      ],
    });

    if (!prices) throw null;

    return prices;
  } catch (error) {
    console.error("Ошибка при получении цен:", error);
    throw null;
  }
};
