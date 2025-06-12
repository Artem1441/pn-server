import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import { getUserById } from "../db/auth.db";
import IResp from "../types/IResp.interface";

const checkIsAdminMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
) => {
  try {
    const userId = req.body.user?.id;

    console.log(userId)

    if (!userId) {
      res
        .status(401)
        .json({
          status: false,
          error: errors.userNotFound
        });
      return;
    }

    const user = await getUserById(userId);

    if (user.role !== "admin") {
      res
        .status(401)
        .json({
          status: false,
          error:  errors.userNotAdmin
        });
      return;
    }

    next();
  } catch (error) {
    res.status(401).json({ status: false, error: errors.serverError });
    return;
  }
};

export default checkIsAdminMiddleware;
