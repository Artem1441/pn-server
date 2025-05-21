import axios, { AxiosError } from "axios";
import errors from "../constants/errors";

const taxpayerStatusApi = async ({
  token,
  inn,
  requestDate,
}: {
  token: string;
  inn: string;
  requestDate: string;
}): Promise<{ status: boolean; error?: string }> => {
  try {
    const response = await axios.post(
      "https://statusnpd.nalog.ru/api/v1/tracker/taxpayer_status",
      { inn, requestDate },
      { headers: { Authorization: `Bearer ${token}` } }
    );

    if (response.data.status) {
      return {
        status: true,
      };
    } else {
      return {
        status: false,
          error: errors.notRegisteredAsSelfEmployed,
      };
    }
  } catch (err) {
    if (axios.isAxiosError(err)) {
      const error = err as AxiosError;
  
      if (error.response?.data && typeof error.response.data === 'object' && 'code' in error.response.data) {
        const code = (error.response.data as { code?: string }).code;
  
        if (code === "validation.failed") {
          return { status: false, error: errors.taxpayerNotFound };
        } else if (code === "taxpayer.status.service.limited.error") {
          return { status: false, error: errors.taxServiceRateLimitExceeded };
        }
      }
  
      return { status: false, error: errors.serverError };
    } else {
      console.error('Неизвестная ошибка:', err);
      return { status: false, error: errors.serverError };
    }
  }
};

export default taxpayerStatusApi;
