import {
  confirmUserEmail,
  confirmUserPhone,
  getActiveVerificationCode,
  markVerificationCodeAsUsed,
} from "../db/auth.db";
import IResp from "../types/IResp.interface";

export const verifyCode = async (
  userId: number,
  type: "phone" | "email",
  value: string,
  code: string
): Promise<IResp<string>> => {
  try {
    const verificationCode = await getActiveVerificationCode(
      userId,
      type,
      value,
      code
    );

    await markVerificationCodeAsUsed(verificationCode.id);

    if (type === "phone") await confirmUserPhone(userId);
    else await confirmUserEmail(userId);

    return {
      status: true,
      data: `${type === "phone" ? "Телефон" : "Email"} подтверждён`,
    };
  } catch (error: any) {
    console.error(error);
    return {
      status: false,
      error: "Неверный или просроченный код",
    };
  }
};
