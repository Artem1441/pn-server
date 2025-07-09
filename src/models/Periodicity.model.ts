import { Model, DataTypes, Sequelize, Optional } from "sequelize";
import IPeriodicity from "../types/IPeriodicity.interface";

interface PeriodicityCreationAttributes
  extends Optional<
    IPeriodicity,
    | "id"
    | "reporting_frequency"
    | "reporting_day_of_week"
    | "document_send_frequency"
    | "document_send_email"
    | "updated_at"
  > {}

export class Periodicity
  extends Model<IPeriodicity, PeriodicityCreationAttributes>
  implements IPeriodicity
{
  public id!: number;
  public reporting_frequency!: IPeriodicity["reporting_frequency"];
  public reporting_day_of_week!: IPeriodicity["reporting_day_of_week"];
  public document_send_frequency!: IPeriodicity["document_send_frequency"];
  public document_send_email!: string;
  public updated_at!: Date;
}

export const initPeriodicityModel = (sequelize: Sequelize) => {
  Periodicity.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      reporting_frequency: {
        type: DataTypes.ENUM("1week", "2week"),
        allowNull: false,
        defaultValue: "2week",
      },
      reporting_day_of_week: {
        type: DataTypes.ENUM(
          "monday",
          "tuesday",
          "wednesday",
          "thursday",
          "friday",
          "saturday",
          "sunday"
        ),
        allowNull: false,
        defaultValue: "sunday",
      },
      document_send_frequency: {
        type: DataTypes.ENUM(
          "daily",
          "weekly",
          "monthly",
          "quarterly",
          "semiannually",
          "annually"
        ),
        allowNull: false,
        defaultValue: "monthly",
      },
      document_send_email: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      updated_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      sequelize,
      tableName: "periodicity",
      timestamps: true,
      createdAt: false,
      updatedAt: "updated_at",
    }
  );
};
