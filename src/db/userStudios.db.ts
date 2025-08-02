import { UserStudio } from "../models/UserStudio.model";
import IUserStudio from "../types/IUserStudio.interface";

export const createUserStudio = async ({
  user_id,
  studio_id,
}: {
  user_id: IUserStudio["user_id"];
  studio_id: IUserStudio["studio_id"];
}): Promise<number> => {
  try {
    const userStudio = await UserStudio.create({ user_id, studio_id });
    return userStudio.id;
  } catch (error) {
    console.error("Ошибка при создании userStudio:", error);
    return -1;
  }
};
