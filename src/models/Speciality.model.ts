import { Model, DataTypes, Sequelize } from "sequelize";
import { Optional } from "sequelize";
import ISpeciality from "../types/ISpeciality.interface";

interface SpecialityCreationAttributes
  extends Optional<
  ISpeciality,
    | "id"
    | "name"
    | "created_at"
    | "updated_at"
  > {}

export class Speciality extends Model<ISpeciality, SpecialityCreationAttributes> implements ISpeciality {
  public id!: number;
  public name!: string;
  public created_at!: Date;
  public updated_at!: Date;
}

export const initSpecialityModel = (sequelize: Sequelize) => {
  Speciality.init(
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
      tableName: "specialities",
      timestamps: true,
      createdAt: "created_at",
      updatedAt: "updated_at",
    }
  );
};