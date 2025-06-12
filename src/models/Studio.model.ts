import { Model, DataTypes, Sequelize } from "sequelize";
import IStudio from "../types/IStudio.interface";
import { Optional } from "sequelize";

interface StudioCreationAttributes
  extends Optional<
    IStudio,
    | "id"
    | "general_full_address"
    | "general_area"
    | "general_cadastral_number"
    | "general_contract_number"
    | "general_contract_date"
    | "general_registration"
    | "general_rent_price_per_sqm"
    | "general_owner_last_name"
    | "general_owner_first_name"
    | "general_owner_middle_name"
    | "general_owner_phone"
    | "general_owner_email"
    | "general_coowner_available"
    | "general_coowner_last_name"
    | "general_coowner_first_name"
    | "general_coowner_middle_name"
    | "general_coowner_phone"
    | "general_coowner_email"
    | "general_work_schedule"
    | "general_work_schedule_weekdays"
    | "general_work_schedule_weekends"
    | "general_wifi_password"
    | "general_alarm_code"
    | "general_lock_code"
    | "general_services_mani"
    | "general_services_pedi"
    | "general_services_brows"
    | "general_sublease_available"
    | "general_sublease_area"
    | "general_sublease_activity_type"
    | "general_sublease_contact_last_name"
    | "general_sublease_contact_first_name"
    | "general_sublease_contact_middle_name"
    | "general_sublease_contact_phone"
    | "general_sublease_contact_email"
    | "general_sublease_rent_price_per_sqm"
    | "created_at"
    | "updated_at"
  > {}

export class Studio extends Model<IStudio, StudioCreationAttributes> implements IStudio {
  public id!: number;
  public name!: string;

  public general_full_address?: string;
  public general_area?: string;
  public general_cadastral_number?: string;
  public general_contract_number?: string;
  public general_contract_date?: Date;
  public general_registration?: string;
  public general_rent_price_per_sqm?: string;

  public general_owner_last_name?: string;
  public general_owner_first_name?: string;
  public general_owner_middle_name?: string;
  public general_owner_phone?: string;
  public general_owner_email?: string;

  public general_coowner_available?: boolean;
  public general_coowner_last_name?: string;
  public general_coowner_first_name?: string;
  public general_coowner_middle_name?: string;
  public general_coowner_phone?: string;
  public general_coowner_email?: string;

  public general_work_schedule?: string;
  public general_work_schedule_weekdays?: string;
  public general_work_schedule_weekends?: string;
  public general_wifi_password?: string;
  public general_alarm_code?: string;
  public general_lock_code?: string;

  public general_services_mani?: number;
  public general_services_pedi?: number;
  public general_services_brows?: number;

  public general_sublease_available?: boolean;
  public general_sublease_area?: string;
  public general_sublease_activity_type?: string;
  public general_sublease_contact_last_name?: string;
  public general_sublease_contact_first_name?: string;
  public general_sublease_contact_middle_name?: string;
  public general_sublease_contact_phone?: string;
  public general_sublease_contact_email?: string;
  public general_sublease_rent_price_per_sqm?: string;

  public created_at!: Date;
  public updated_at!: Date;
}

export const initStudioModel = (sequelize: Sequelize) => {
  Studio.init(
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

      general_full_address: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      general_area: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_cadastral_number: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_contract_number: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_contract_date: {
        type: DataTypes.DATEONLY,
        allowNull: true,
      },
      general_registration: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_rent_price_per_sqm: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },

      general_owner_last_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_owner_first_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_owner_middle_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_owner_phone: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_owner_email: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },

      general_coowner_available: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        allowNull: true,
      },
      general_coowner_last_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_coowner_first_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_coowner_middle_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_coowner_phone: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_coowner_email: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },

      general_work_schedule: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_work_schedule_weekdays: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_work_schedule_weekends: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_wifi_password: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_alarm_code: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_lock_code: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },

      general_services_mani: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      general_services_pedi: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      general_services_brows: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },

      general_sublease_available: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        allowNull: true,
      },
      general_sublease_area: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_sublease_activity_type: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_sublease_contact_last_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_sublease_contact_first_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_sublease_contact_middle_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_sublease_contact_phone: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_sublease_contact_email: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      general_sublease_rent_price_per_sqm: {
        type: DataTypes.STRING(255),
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
      tableName: "studios",
      timestamps: true,
      createdAt: "created_at",
      updatedAt: "updated_at",
    }
  );
};