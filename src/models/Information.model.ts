import { Model, DataTypes, Sequelize } from "sequelize";
import IInformation from "../types/IInformation.interface";

interface InformationCreationAttributes extends Partial<IInformation> {
  general_role: "director" | "authorized_person";
}

export class Information
  extends Model<IInformation, InformationCreationAttributes>
  implements IInformation
{
  public id!: number;
  public full_name!: string | undefined;
  public short_name!: string | undefined;
  public inn!: string | undefined;
  public ogrn!: string | undefined;
  public kpp!: string | undefined;
  public okved!: string | undefined;

  public director_fio!: string | undefined;
  public director_position!: string | undefined;
  public director_basis!: string | undefined;

  public authorized_person_fio!: string | undefined;
  public authorized_person_position!: string | undefined;
  public authorized_person_basis!: string | undefined;

  public general_role!: "director" | "authorized_person";

  public legal_address!: string | undefined;
  public correspondence_address!: string | undefined;
  public contact_phone!: string | undefined;
  public accounting_phone!: string | undefined;
  public email!: string | undefined;
  public website!: string | undefined;

  public bank_acc!: string | undefined;
  public bank_bik!: string | undefined;
  public bank_cor!: string | undefined;
  public bank_name!: string | undefined;

  public company_card!: string | undefined;
  public inn_file!: string | undefined;
  public ustat!: string | undefined;
  public stamp!: string | undefined;
  public power_of_attorney!: string | undefined;
  public director_signature!: string | undefined;
  public authorized_person_signature!: string | undefined;

  public updated_at!: Date;
}

export const initInformationModel = (sequelize: Sequelize) => {
  Information.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      full_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      short_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      inn: {
        type: DataTypes.STRING(12),
        allowNull: true,
      },
      ogrn: {
        type: DataTypes.STRING(13),
        allowNull: true,
      },
      kpp: {
        type: DataTypes.STRING(9),
        allowNull: true,
      },
      okved: {
        type: DataTypes.STRING(10),
        allowNull: true,
      },

      director_fio: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      director_position: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      director_basis: {
        type: DataTypes.TEXT,
        allowNull: true,
      },

      authorized_person_fio: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      authorized_person_position: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      authorized_person_basis: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      general_role: {
        type: DataTypes.ENUM("director", "authorized_person"),
        allowNull: false,
        defaultValue: "director",
      },
      legal_address: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      correspondence_address: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      contact_phone: {
        type: DataTypes.STRING(20),
        allowNull: true,
      },
      accounting_phone: {
        type: DataTypes.STRING(20),
        allowNull: true,
      },
      email: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      website: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },

      bank_acc: {
        type: DataTypes.STRING(20),
        allowNull: true,
      },
      bank_bik: {
        type: DataTypes.STRING(9),
        allowNull: true,
      },
      bank_cor: {
        type: DataTypes.STRING(20),
        allowNull: true,
      },
      bank_name: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },

      company_card: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      inn_file: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      ustat: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      stamp: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      power_of_attorney: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      director_signature: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      authorized_person_signature: {
        type: DataTypes.TEXT,
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
      tableName: "information",
      timestamps: true, 
      createdAt: false, 
      updatedAt: "updated_at",
    }
  );
};
