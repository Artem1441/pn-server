import { Request, Response } from "express";
import errors from "../constants/errors";
import { createSpeciality, deleteSpeciality, getSpecialities, updateSpeciality } from "../db/speciality.db";
import IResp from "../types/IResp.interface";
import ISpeciality from "../types/ISpeciality.interface";

class SpecialityController {
  public getSpecialities = async (
    req: Request,
    res: Response<IResp<ISpeciality[]>>
  ): Promise<void> => {
    try {
      const specialities = await getSpecialities();
      res.status(200).json({
        status: true,
        data: specialities,
      });
      return;
    } catch (err) {
      console.error(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public createSpeciality = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { name } = req.body;

    try {
      await createSpeciality({
        name,
      });

      res.status(200).json({
        status: true,
      });
      return;
    } catch (err) {
      console.error(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public updateSpeciality = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { id, name } = req.body;
    try {
      await updateSpeciality({
        id,
        name,
      });
      res.status(200).json({
        status: true,
      });
      return;
    } catch (err) {
      console.error(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public deleteSpeciality = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { id } = req.query;
    try {
      if (id) await deleteSpeciality(Number(id));
      res.status(200).json({
        status: true,
      });
      return;
    } catch (err: any) {
      console.error(err.message);
      res.status(500).json({ status: false, error: err.message || errors.serverError });
      return;
    }
  };
}

export default new SpecialityController();
