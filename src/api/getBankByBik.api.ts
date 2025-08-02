import axios from "axios";
import errors from "../constants/errors";

const getBankByBikApi = async (
  bik: string
): Promise<{ status: boolean; data?: any; error?: string }> => {
  try {
    const response = await axios.get(
      `https://bik-info.ru/api.html?type=json&bik=${bik}`
    );

    if (!response.data.error) {
      return {
        status: true,
        data: response.data,
      };
    } else {
      return {
        status: false,
        error: errors.bikNotFound,
      };
    }
  } catch (err: any) {
    console.error("getBankByBikApi error: ", err)
    if (axios.isAxiosError(err)) return { status: false, error: errors.serverError };
    else return { status: false, error: errors.unexpectedError };
  }
};

export default getBankByBikApi;
