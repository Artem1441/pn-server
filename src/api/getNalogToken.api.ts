import axios from "axios";
import dotenv from "dotenv";
dotenv.config();

const getNalogTokensApi = async (): Promise<{
  token: string;
  refreshToken: string;
}> => {
  const response = await axios.post(
    "https://lknpd.nalog.ru/api/v1/auth/token",
    {
      deviceInfo: {
        sourceType: "android",
        sourceDeviceId: "a1b2c3d4-e5f6-7890-g1h2-i3j4k5l6m7n8",
        appVersion: "6.3.0",
        deviceSource: "Xiaomi Redmi Note 9",
        metaDetails: {
          userAgent:
            "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36",
        },
      },
      refreshToken: process.env.TAX_REFRESH_TOKEN,
    }
  );

  return response.data;
};

export default getNalogTokensApi;
