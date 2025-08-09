import { Model, DataTypes, Sequelize } from "sequelize"
import { Optional } from "sequelize"
import ICity from "../types/ICity.interface"

interface CityCreationAttributes
  extends Optional<
    ICity,
    "id" | "name" | "city_code" | "created_at" | "updated_at"
  > {}

export class City
  extends Model<ICity, CityCreationAttributes>
  implements ICity
{
  public id!: number
  public name!: string
  public city_code!: string
  public created_at!: Date
  public updated_at!: Date
}

export const initCityModel = (sequelize: Sequelize) => {
  City.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      name: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      city_code: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      created_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
      updated_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      sequelize,
      tableName: "cities",
      timestamps: true,
      createdAt: "created_at",
      updatedAt: "updated_at",
    }
  )
}
