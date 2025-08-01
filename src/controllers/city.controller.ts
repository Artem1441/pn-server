import { Request, Response } from "express";
import errors from "../constants/errors";
import { createCity, deleteCity, getCities, updateCity } from "../db/city.db";
import ICity from "../types/ICity.interface";
import IResp from "../types/IResp.interface";

class CityController {
  public getCities = async (
    req: Request,
    res: Response<IResp<ICity[]>>
  ): Promise<void> => {
    try {
      const cities = await getCities();
      res.status(200).json({
        status: true,
        data: cities,
      });
      return;
    } catch (err: any) {
      console.error("getCities error: ", err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public createCity = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { name } = req.body;

    try {
      await createCity({
        name,
      });

      res.status(200).json({
        status: true,
      });
      return;
    } catch (err: any) {
      console.error("createCity error: ", err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public updateCity = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { id, name } = req.body;
    try {
      await updateCity({
        id,
        name,
      });
      res.status(200).json({
        status: true,
      });
      return;
    } catch (err: any) {
      console.error("updateCity error: ", err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public deleteCity = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { id } = req.query;
    try {
      if (id) await deleteCity(Number(id));
      res.status(200).json({
        status: true,
      });
      return;
    } catch (err: any) {
      console.error("deleteCity error: ", err);
      res.status(500).json({ status: false, error: err.message || errors.serverError });
      return;
    }
  };
}

export default new CityController();
