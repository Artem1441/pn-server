import errors from "../constants/errors";
import { Speciality } from "../models/Speciality.model";
import ISpeciality from "../types/ISpeciality.interface";

export const createSpeciality = async ({
  name,
}: {
  name: ISpeciality["name"];
}): Promise<number> => {
  try {
    const speciality = await Speciality.create({ name });
    return speciality.id;
  } catch (error) {
    console.error("Ошибка при получении создании специальности:", error);
    return -1;
  }
};

export const updateSpeciality = async ({
  id,
  name,
}: {
  id: ISpeciality["id"];
  name: ISpeciality["name"];
}): Promise<void> => {
  try {
    const speciality = await Speciality.findByPk(id);
    if (!speciality) throw null;
    speciality.name = name;

    await speciality.save();
  } catch (err) {
    console.error("Ошибка при обновлении специальности:", err);
    throw null;
  }
};

export const deleteSpeciality = async (id: ISpeciality["id"]): Promise<void> => {
  try {
    const speciality = await Speciality.findByPk(id);

    if (!speciality) throw new Error(errors.specialityNotFound);

    await speciality.destroy();
  } catch (err: any) {
    if (err.name === "SequelizeForeignKeyConstraintError") {
      console.error(
        "Невозможно удалить специальнсть: она используется в других таблицах",
        err
      );
      throw new Error(errors.cannotDeleteEntityBecauseItIsUsed);
    }

    console.error("Ошибка при удалении специальности:", err);
    throw null;
  }
};

export const getSpecialityById = async <T extends (keyof ISpeciality)[]>(
  id: ISpeciality["id"],
  fields: T = [] as unknown as T
): Promise<(T extends [] ? ISpeciality : Pick<ISpeciality, T[number]>) | null> => {
  const user = await Speciality.findByPk(id, {
    attributes: fields.length > 0 ? fields : undefined,
  });

  if (!user) return null

  return user.toJSON() as T extends [] ? ISpeciality : Pick<ISpeciality, T[number]>;
};

export const getSpecialities = async (): Promise<ISpeciality[]> => {
  try {
    const specialities = await Speciality.findAll();
    if (!specialities) throw null;
    return specialities;
  } catch (error) {
    console.error("Ошибка при получении специальностей:", error);
    throw null;
  }
};
