import { Studio } from "../models/Studio.model";
import { UserStudio } from "../models/UserStudio.model";
import IStudio from "../types/IStudio.interface";
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

export const getUserStudiosByUserId = async <
  T extends (keyof IUserStudio)[],
  S extends (keyof IStudio)[]
>(
  user_id: IUserStudio["user_id"],
  userFields?: T,
  studioFields?: S
): Promise<
  Array<
    (T extends [] ? IUserStudio : (T[number] extends never ? {} : Pick<IUserStudio, T[number]>)) &
    (S extends undefined | []
      ? { studio?: IStudio }
      : { studio: S[number] extends never ? {} : Pick<IStudio, S[number]> | null })
  >
> => {
  try {
    const userStudios = await UserStudio.findAll({
      where: { user_id },
      attributes: userFields !== undefined ? userFields : [],
      include: [
        {
          model: Studio,
          as: "studio",
          required: false,
          attributes: studioFields !== undefined ? studioFields : [],
        },
      ],
    });

    return userStudios.map((us) => us.toJSON());
  } catch (error) {
    console.error("Ошибка при получении getUserStudiosByUserId:", error);
    throw new Error("Не удалось получить студии пользователя");
  }
};