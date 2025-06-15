import errors from "../constants/errors";
import { City } from "../models/City.model";
import ICity from "../types/ICity.interface";

export const createCity = async ({
  name,
}: {
  name: ICity["name"];
}): Promise<number> => {
  try {
    const city = await City.create({ name });
    return city.id;
  } catch (error) {
    console.error("Ошибка при получении создании города:", error);
    return -1;
  }
};

export const updateCity = async ({
  id,
  name,
}: {
  id: ICity["id"];
  name: ICity["name"];
}): Promise<void> => {
  try {
    const city = await City.findByPk(id);
    if (!city) throw null;
    city.name = name;

    await city.save();
  } catch (err) {
    console.error("Ошибка при обновлении города:", err);
    throw null;
  }
};

export const deleteCity = async (id: ICity["id"]): Promise<void> => {
  try {
    const city = await City.findByPk(id);

    if (!city) throw new Error(errors.cityNotFound);

    await city.destroy();
  } catch (err: any) {
    if (err.name === "SequelizeForeignKeyConstraintError") {
      console.error(
        "Невозможно удалить город: он используется в других таблицах",
        err
      );
      throw new Error(errors.cannotDeleteEntityBecauseItIsUsed);
    }

    console.error("Ошибка при удалении города:", err);
    throw null;
  }
};

export const getCities = async (): Promise<ICity[]> => {
  try {
    const cities = await City.findAll();
    if (!cities) throw null;
    return cities;
  } catch (error) {
    console.error("Ошибка при получении городов:", error);
    throw null;
  }
};
