import { Model, DataTypes, Sequelize } from "sequelize";
import { Optional } from "sequelize";
import IUserStudio from "../types/IUserStudio.interface";
import { Studio } from "./Studio.model";

interface UserStudioCreationAttributes
  extends Optional<IUserStudio, "id" | "created_at"> {}

export class UserStudio
  extends Model<IUserStudio, UserStudioCreationAttributes>
  implements IUserStudio
{
  public id!: number;
  public readonly studio?: Studio;
  public user_id!: number;
  public studio_id!: number;
  public created_at!: Date;
  public updated_at!: Date;
  public static associate(models: { Studio: typeof Studio }): void {
    UserStudio.belongsTo(models.Studio, {
      foreignKey: "studio_id",
      as: "studio",
    });
  }
}

export const initUserStudioModel = (sequelize: Sequelize) => {
  UserStudio.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      user_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: { model: "users", key: "id" },
      },
      studio_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: { model: "studios", key: "id" },
      },
      created_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      sequelize,
      tableName: "user_studios",
      timestamps: true,
      createdAt: "created_at",
      updatedAt: false,
    }
  );
};
