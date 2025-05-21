import nodemailer from "nodemailer";
import dotenv from "dotenv";
dotenv.config();

export const sendEmail = async (
  email: string,
  topic: string,
  message: string,
  html?: string
) => {
  const transporter = nodemailer.createTransport({
    host: "smtp.yandex.ru",
    port: 465,
    secure: true,
    auth: {
      user: String(process.env.MAIL_USER),
      pass: String(process.env.MAIL_PASSWORD),
    },
  });

  const mailOptions = {
    from: String(process.env.MAIL_USER),
    to: email,
    subject: topic,
    text: message,
    html: html,
  };

  try {
    return transporter.sendMail(mailOptions, (error, info) => {
      if (error) return `Ошибка: ${error}`;
      else return `Письмо отправлено: ${info.response}`;
    });
  } catch (error) {
    return { status: false, message: "Ошибка при отправке письма на почту" };
  }
};