import { Model, DataTypes, Optional, Sequelize } from "sequelize";
import DocumentType, { DocumentTypes } from "../types/DocumentType.type.js";
import IDocx from "../types/IDocx.interface.js";

interface DocxCreationAttributes
  extends Optional<
    IDocx,
    "id" | "file_key" | "file_type" | "created_at" | "updated_at"
  > {}

export class Docx
  extends Model<IDocx, DocxCreationAttributes>
  implements IDocx
{
  public id!: number;
  public file_key!: string;
  public file_type!: DocumentType;
  public created_at!: Date;
  public updated_at!: Date;
}

export const initDocxModel = (sequelize: Sequelize) => {
  Docx.init(
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      file_key: {
        type: DataTypes.TEXT,
        allowNull: false,
      },
      file_type: {
        type: DataTypes.ENUM(...Object.values(DocumentTypes)),
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
      tableName: "docxs",
      timestamps: true,
      createdAt: "created_at",
      updatedAt: "updated_at",
    }
  );
};
