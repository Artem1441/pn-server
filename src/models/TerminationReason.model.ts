import { Model, DataTypes, Sequelize } from "sequelize";
import { Optional } from "sequelize";
import ITerminationReason from "../types/ITerminationReason.interface";

interface TerminationReasonCreationAttributes
  extends Optional<
    ITerminationReason,
    | "id"
    | "speciality_id"
    | "reason"
    | "description"
    | "created_at"
    | "updated_at"
  > {}

export class TerminationReason
  extends Model<ITerminationReason, TerminationReasonCreationAttributes>
  implements ITerminationReason
{
  public id!: number;
  public speciality_id!: number;
  public reason!: string;
  public description!: string;

  public created_at!: Date;
  public updated_at!: Date;
}

export const initTerminationReasonModel = (sequelize: Sequelize) => {
  TerminationReason.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      speciality_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: { model: "specialities", key: "id" },
      },
      reason: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      description: {
        type: DataTypes.TEXT,
        allowNull: true,
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
      tableName: "termination_reasons",
      timestamps: true,
      createdAt: "created_at",
      updatedAt: "updated_at",
    }
  );
};