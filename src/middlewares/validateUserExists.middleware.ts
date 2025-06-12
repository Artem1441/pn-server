import { Request, Response, NextFunction } from "express";
import errors from "../constants/errors";
import { getUserById } from "../db/auth.db";

const validateUserExistsMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const userId = req.body.user?.id;

  if (!userId) {
    res.status(401).json({ error: errors.userNotFound });
    return;
  }

  try {
    const user = await getUserById(userId);

    if (!user) {
      res.status(401).json({ error: errors.userNotFound });
      return;
    }

    req.body.user = user;
    next();
  } catch (error) {
    res.status(500).json({ error: errors.serverError });
    return;
  }
};

export default validateUserExistsMiddleware;
