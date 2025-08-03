import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import { getUserById } from "../db/personal.db";
import IResp from "../types/IResp.interface";

const checkIsSpecialistMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
) => {
  try {
    const userId = req.body.user?.id;

    if (!userId) {
      res.status(401).json({
        status: false,
        error: errors.userNotFound,
      });
      return;
    }

    const user = await getUserById(userId, ["role"]);
    if (!user) throw new Error(errors.userNotFound)
    const { role } = user;

    if (role !== "specialist") {
      res.status(401).json({
        status: false,
        error: errors.userNotSpecialist,
      });
      return;
    }

    next();
  } catch (error) {
    res.status(401).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkIsSpecialistMiddleware;
