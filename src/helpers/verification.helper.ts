import queryDB from "../db";
import { createVerificatioCodeQuery } from "../db/auth.db";
import IResp from "../types/IResp.interface";
import { sendEmail } from "./mail.helper";
import { sendSms } from "./sms.helper";

export const generateVerificationCode = async (
  userId: number,
  type: "phone" | "email",
  value: string
) => {
  const code = Math.floor(1000 + Math.random() * 9000).toString();
  const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

  await createVerificatioCodeQuery({
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

export const verifyCode = async (
  userId: number,
  type: "phone" | "email",
  value: string,
  code: string
): Promise<IResp<string>> => {
  console.log(userId, type, value, code);
  const result = await queryDB(
    `SELECT * FROM verification_codes
       WHERE user_id = $1 AND type = $2 AND value = $3 AND code = $4
       AND expires_at > NOW() AND is_used = false`,
    [userId, type, value, code]
  );

  if (result.rowCount === 0) {
    return { status: false, error: "Неверный или просроченный код" };
  }

  // Помечаем код как использованный
  await queryDB(`UPDATE verification_codes SET is_used = true WHERE id = $1`, [
    result.rows[0].id,
  ]);

  // Подтверждаем поле в таблице users
  if (type === "phone") {
    await queryDB(`UPDATE users SET is_confirmed_phone = true WHERE id = $1`, [
      userId,
    ]);
  } else {
    await queryDB(`UPDATE users SET is_confirmed_email = true WHERE id = $1`, [
      userId,
    ]);
  }

  return {
    status: true,
    data: `${type === "phone" ? "Телефон" : "Email"} подтверждён`,
  };
};
