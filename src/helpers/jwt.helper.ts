import jwt from "jsonwebtoken";
import dotenv from "dotenv";
dotenv.config();

export const jwtSign = (payload: Record<string, any>, expiresIn: "1h" |"1d" | "7d"): string => {
  return jwt.sign(payload, String(process.env.JWT_SECRET_KEY), {
    expiresIn,
  });
};

export const jwtVerify = (token: string): any => {
  return jwt.verify(token, process.env.JWT_SECRET_KEY as string);
};
