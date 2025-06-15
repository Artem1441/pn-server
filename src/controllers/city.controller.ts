import { Request, Response } from "express";
import errors from "../constants/errors";
import { createCity, deleteCity, getCities, updateCity } from "../db/city.db";
// import {
//   createStudio,
//   deleteStudio,
//   getStudios,
//   updateStudio,
// } from "../db/studio.db";
import ICity from "../types/ICity.interface";
import IResp from "../types/IResp.interface";

class CityController {
  getCities = async (
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
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  createCity = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { name } = req.body;

    console.log(name);

    try {
      await createCity({
        name,
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

  updateCity = async (
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
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  deleteCity = async (
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
      console.log(err.message);
      res.status(500).json({ status: false, error: err.message || errors.serverError });
      return;
    }
  };
}

export default new CityController();
