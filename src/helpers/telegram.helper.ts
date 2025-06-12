import axios from "axios";

export const sendErrorToTelegram = (message: string): void => {
  axios.get(
    `https://api.telegram.org/bot6919311657:AAGbKn5C070z_yoSEuf7VMZqCsL_4xgzz9c/sendMessage?chat_id=1427167013&text=PRONOGTI - ошибка: ${message}`
  );
};

