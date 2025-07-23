import { Request, Response } from "express";
import errors from "../constants/errors";
import { getMotivation, updateMotivation } from "../db/motivation.db";
import IMotivation from "../types/IMotivation.interface";
import IResp from "../types/IResp.interface";

class MotivationController {
  public getMotivation = async (
    req: Request,
    res: Response<IResp<IMotivation>>
  ): Promise<void> => {
    try {
      const motivation = await getMotivation();
      res.status(200).json({
        status: true,
        data: motivation,
      });
      return;
    } catch (err) {
      console.error(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public updateMotivation = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    try {
      const { id, allowance_data, deduction_data } = req.body;
      await updateMotivation({ id, allowance_data, deduction_data });

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
}

export default new MotivationController();
