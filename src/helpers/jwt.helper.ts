import jwt from "jsonwebtoken";
import dotenv from "dotenv";
dotenv.config();

export const jwtSign = (payload: Record<string, any>): string => {
  return jwt.sign(payload, String(process.env.JWT_SECRET_KEY), {
    expiresIn: "1d",
  });
};

export const jwtVerify = (token: string): any => {
  return jwt.verify(token, process.env.JWT_SECRET_KEY as string);
};
