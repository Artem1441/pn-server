import errors from "../constants/errors"
import { City } from "../models/City.model"
import ICity from "../types/ICity.interface"

export const createCity = async ({
  name,
  city_code,
}: {
  name: ICity["name"]
  city_code: ICity["city_code"]
}): Promise<number> => {
  try {
    const city = await City.create({ name, city_code })
    return city.id
  } catch (err: any) {
    console.error("Ошибка при создании города:", err)
    return -1
  }
}

export const updateCity = async ({
  id,
  name,
  city_code,
}: {
  id: ICity["id"]
  name: ICity["name"]
  city_code: ICity["city_code"]
}): Promise<void> => {
  try {
    const city = await City.findByPk(id)
    if (!city) throw null
    city.name = name
    city.city_code = city_code

    await city.save()
  } catch (err) {
    console.error("Ошибка при обновлении города:", err)
    throw null
  }
}

export const deleteCity = async (id: ICity["id"]): Promise<void> => {
  try {
    const city = await City.findByPk(id)

    if (!city) throw new Error(errors.cityNotFound)

    await city.destroy()
  } catch (err: any) {
    if (err.name === "SequelizeForeignKeyConstraintError") {
      console.error(
        "Невозможно удалить город: он используется в других таблицах",
        err
      )
      throw new Error(errors.cannotDeleteEntityBecauseItIsUsed)
    }

    console.error("Ошибка при удалении города:", err)
    throw null
  }
}

export const getCities = async (): Promise<ICity[]> => {
  try {
    const cities = await City.findAll()
    if (!cities) throw null
    return cities
  } catch (err: any) {
    console.error("Ошибка при получении городов (getCities):", err)
    throw null
  }
}
