import { Model, DataTypes, Sequelize, Optional } from "sequelize";
import IInformationChange from "../types/IInformationChange.interface.js";

interface InformationChangeCreationAttributes
  extends Optional<IInformationChange, "id" | "created_at"> {}

export class InformationChange
  extends Model<IInformationChange, InformationChangeCreationAttributes>
  implements IInformationChange
{
  public id!: number;
  public changed_field!: string;
  public old_value!: string | undefined;
  public new_value!: string | undefined;
  public changed_by_fio!: string;
  public changed_by_role!: "director" | "authorized_person";
  public created_at!: Date;
}

export const initInformationChangeModel = (sequelize: Sequelize) => {
  InformationChange.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      changed_field: {
        type: DataTypes.TEXT,
        allowNull: false,
      },
      old_value: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      new_value: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      changed_by_fio: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      changed_by_role: {
        type: DataTypes.ENUM("director", "authorized_person"),
        allowNull: false,
      },
      created_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      sequelize,
      tableName: "information_changes",
      timestamps: false,
    }
  );
};