import crypto from "crypto";
import { createVerificationCode } from "../db/auth.db";
import { sendEmail } from "./mail.helper";
import { sendSms } from "./sms.helper.js";

export const generateLogin = (name: string, surname: string): string => {
  const randomSuffix = Math.floor(Math.random() * 1000);
  return `${name.toLowerCase()}_${surname.toLowerCase()}${randomSuffix}`;
};

export const generatePassword = (): string => {
  return crypto.randomBytes(4).toString("hex");
};

export const generateVerificationCode = async (
    userId: number,
    type: "phone" | "email",
    value: string
  ) => {
    const code = Math.floor(1000 + Math.random() * 9000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);
  
    await createVerificationCode({
      userId,
      type,
      value,
      code,
      expiresAt,
    });
  
    if (type === "phone") {
      await sendSms(value, `Ваш код подтверждения: ${code}`);
    } else {
      await sendEmail(value, "Код подтверждения", `Ваш код: ${code}`);
    }
  };