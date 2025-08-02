import { Model, DataTypes, Sequelize, Optional } from "sequelize";
import IVerificationCode from "../types/IVerificationCode.interface";

interface VerificationCodeCreationAttributes
  extends Optional<IVerificationCode, "id" | "is_used" | "created_at"> {}

export class VerificationCode
  extends Model<IVerificationCode, VerificationCodeCreationAttributes>
  implements IVerificationCode
{
  public id!: number;
  public user_id!: number;
  public type!: "phone" | "email";
  public value!: string;
  public code!: string;
  public expires_at!: Date;
  public is_used!: boolean;
  public created_at!: Date;
}

export const initVerificationCodeModel = (sequelize: Sequelize) => {
  VerificationCode.init(
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
        onDelete: "CASCADE",
      },
      type: {
        type: DataTypes.ENUM("phone", "email"),
        allowNull: false,
      },
      value: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      code: {
        type: DataTypes.STRING(4),
        allowNull: false,
      },
      expires_at: {
        type: DataTypes.DATE,
        allowNull: false,
      },
      is_used: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      created_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      sequelize,
      tableName: "verification_codes",
      timestamps: true, // Включаем временные метки
      createdAt: "created_at", // Переименовываем createdAt в created_at
      updatedAt: false, // Отключаем updatedAt, так как его нет в таблице
    }
  );
};