

  import { Model, DataTypes, Sequelize } from "sequelize";
import { Optional } from "sequelize";
import IMotivation, {
    IMotivationDataItem
} from "../types/IMotivation.interface";

interface MotivationCreationAttributes
  extends Optional<
    IMotivation,
    "id" | "allowance_data" | "deduction_data" | "updated_at"
  > {}

export class Motivation
  extends Model<IMotivation, MotivationCreationAttributes>
  implements IMotivation
{
  public id!: number;
  public allowance_data!: IMotivationDataItem[];
  public deduction_data!: IMotivationDataItem[];
  public updated_at!: Date;
}

export const initMotivationModel = (sequelize: Sequelize) => {
  Motivation.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      allowance_data: {
        type: DataTypes.JSON,
        allowNull: true,
      },
      deduction_data: {
        type: DataTypes.JSON,
        allowNull: true,
      },
      updated_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      sequelize,
      tableName: "motivation",
      timestamps: true,
      createdAt: false, 
      updatedAt: "updated_at",
    }
  );
};
