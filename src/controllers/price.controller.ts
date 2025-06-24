import { Request, Response } from "express";
import errors from "../constants/errors";
import { createPrice, deletePrice, getPrices, updatePrice } from "../db/price.db";
import { createStudio, deleteStudio, updateStudio } from "../db/studio.db";
import IPrice from "../types/IPrice.interface";
import IResp from "../types/IResp.interface";

class PriceController {
  getPrices = async (
    req: Request,
    res: Response<IResp<IPrice[]>>
  ): Promise<void> => {
    try {
      const prices = await getPrices();
      res.status(200).json({
        status: true,
        data: prices,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  createPrice = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const {
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
    } = req.body;

    try {
      await createPrice({
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

      res.status(200).json({
        status: true,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  updatePrice = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const {
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
    } = req.body;

    try {
      await updatePrice({
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
      });

      res.status(200).json({
        status: true,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  deletePrice = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { id } = req.query;

    try {
      if (id) await deletePrice(Number(id));

      res.status(200).json({
        status: true,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };
}

export default new PriceController();
