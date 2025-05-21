import { Model, DataTypes, Optional, Sequelize } from "sequelize";
import IUser from "../types/IUser.interface.js";

interface UserCreationAttributes
  extends Optional<
    IUser,
    | "id"
    | "role"
    | "time_zone"
    | "locale"
    | "patronymic"
    | "is_confirmed_phone"
    | "is_confirmed_email"
    | "is_banned"
    | "bank_bik"
    | "bank_acc"
    | "birthdate"
    | "address_reg"
    | "passport"
    | "equipments"
    | "ycl_staff_id"
    | "agent_percent"
    | "speciality_id"
    | "studio_id"
    | "passport_main"
    | "passport_registration"
    | "photo_front"
    | "registration_status"
    | "created_at"
    | "updated_at"
  > {}

export class User
  extends Model<IUser, UserCreationAttributes>
  implements IUser
{
  public id!: number;
  public role!: IUser["role"];
  public login!: string;
  public password!: string;
  public name!: string;
  public surname!: string;
  public patronymic?: string;
  public phone!: string;
  public is_confirmed_phone!: boolean;
  public email!: string;
  public is_confirmed_email!: boolean;
  public inn!: string;
  public is_banned!: boolean;
  public time_zone!: IUser["time_zone"];
  public locale!: IUser["locale"];
  public bank_bik?: string;
  public bank_acc?: string;
  public birthdate?: Date;
  public address_reg?: string;
  public passport?: any; // JSONB
  public equipments?: any; // JSONB
  public ycl_staff_id?: number;
  public agent_percent?: number;
  public speciality_id?: number;
  public studio_id?: number;
  public passport_main?: string;
  public passport_registration?: string;
  public photo_front?: string;
  public registration_status!: IUser["registration_status"];
  public created_at!: Date;
  public updated_at!: Date;
}

export const initUserModel = (sequelize: Sequelize) => {
  User.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      role: {
        type: DataTypes.ENUM("admin", "specialist", "accountant"),
        allowNull: false,
        defaultValue: "specialist",
      },
      login: {
        type: DataTypes.STRING(100),
        allowNull: false,
        unique: true,
      },
      password: {
        type: DataTypes.TEXT,
        allowNull: false,
      },
      name: {
        type: DataTypes.STRING(63),
        allowNull: false,
      },
      surname: {
        type: DataTypes.STRING(63),
        allowNull: false,
      },
      patronymic: {
        type: DataTypes.STRING(63),
        allowNull: true,
      },
      phone: {
        type: DataTypes.STRING(15),
        allowNull: false,
        unique: true,
      },
      is_confirmed_phone: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      email: {
        type: DataTypes.STRING(100),
        allowNull: false,
        unique: true,
      },
      is_confirmed_email: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      inn: {
        type: DataTypes.STRING(12),
        allowNull: false,
        unique: true,
      },
      is_banned: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      time_zone: {
        type: DataTypes.ENUM(
          "UTC+2",
          "UTC+3",
          "UTC+4",
          "UTC+5",
          "UTC+6",
          "UTC+7",
          "UTC+8",
          "UTC+9",
          "UTC+10",
          "UTC+11",
          "UTC+12"
        ),
        allowNull: false,
        defaultValue: "UTC+3",
      },
      locale: {
        type: DataTypes.ENUM("ru", "en"),
        allowNull: false,
        defaultValue: "ru",
      },
      bank_bik: {
        type: DataTypes.STRING(9),
        allowNull: true,
      },
      bank_acc: {
        type: DataTypes.STRING(25),
        allowNull: true,
      },
      birthdate: {
        type: DataTypes.DATE,
        allowNull: true,
        validate: {
          isBeforeCurrentDate(value: Date) {
            if (value >= new Date()) {
              throw new Error("Birthdate must be before the current date.");
            }
          },
        },
      },
      address_reg: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      passport: {
        type: DataTypes.JSONB,
        allowNull: true,
      },
      equipments: {
        type: DataTypes.JSONB,
        allowNull: true,
      },
      ycl_staff_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      agent_percent: {
        type: DataTypes.DECIMAL(15, 2),
        allowNull: true,
        validate: {
          min: 0,
          max: 100,
        },
      },
      speciality_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      studio_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      passport_main: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      passport_registration: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      photo_front: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      registration_status: {
        type: DataTypes.ENUM(
          "in the process of filling",
          "under review",
          "confirmed"
        ),
        allowNull: false,
        defaultValue: "in the process of filling",
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
      tableName: "users",
      timestamps: true, // включаем обработку времени создания и обновления
      createdAt: "created_at", // название поля для created_at
      updatedAt: "updated_at", // название поля для updated_at
    }
  );
};
