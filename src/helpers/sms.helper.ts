import axios from "axios";
import dotenv from "dotenv";
dotenv.config();

export const sendSms = async (phone: string, message: string) => {
  const login = String(process.env.SMS_LOGIN);
  const password = String(process.env.SMS_PASSWORD);
  const sender = String(process.env.SMS_SENDER);

  const url = "https://smsc.ru/sys/send.php";
  const params = new URLSearchParams({
    login,
    psw: password,
    phones: `+${phone}`,
    mes: message,
    sender,
    charset: "utf-8",
    fmt: "3",
  });

  try {
    const response = await axios.post(url, params);
    const data = response.data;

    if (data.id) {
      return {
        status: true,
        data: data.id,
      };
    } else {
      return {
        status: false,
        message: `Ошибка: ${data.error_code} - ${data.error}`,
      };
    }
  } catch (error) {
    return { status: false, message: "Ошибка при отправке письма по смс" };
  }
};
