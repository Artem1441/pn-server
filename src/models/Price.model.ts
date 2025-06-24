import { Model, DataTypes, Sequelize } from "sequelize";
import { Optional } from "sequelize";
import IPrice from "../types/IPrice.interface";
import IPriceClientsDataItem from "../types/IPriceClientsDataItem.interface";
import IPriceSelfEmployedDataItem from "../types/IPriceSelfEmployedDataItem.interface";

interface PriceCreationAttributes
  extends Optional<
  IPrice,
    | "id"
    | "city_id"
    | "self_employed_data"
    | "clients_mani_data"
    | "clients_pedi_data"
    | "clients_mani_pedi_four_hands_data"
    | "clients_design_data"
    | "clients_additional_nail_services_data"
    | "clients_brow_arch_data"
    | "clients_promo_data"
    | "clients_model_data"
    | "clients_goods_data"
    | "created_at"
    | "updated_at"
  > {}

export class Price extends Model<IPrice, PriceCreationAttributes> implements IPrice {
  public id!: number;
  public city_id!: number;
  public self_employed_data!: IPriceSelfEmployedDataItem[];
  public clients_mani_data!: IPriceClientsDataItem[];
  public clients_pedi_data!: IPriceClientsDataItem[];
  public clients_mani_pedi_four_hands_data!: IPriceClientsDataItem[];
  public clients_design_data!: IPriceClientsDataItem[];
  public clients_additional_nail_services_data!: IPriceClientsDataItem[];
  public clients_brow_arch_data!: IPriceClientsDataItem[];
  public clients_promo_data!: IPriceClientsDataItem[];
  public clients_model_data!: IPriceClientsDataItem[];
  public clients_goods_data!: IPriceClientsDataItem[];
  public created_at!: Date;
  public updated_at!: Date;
}

export const initPriceModel = (sequelize: Sequelize) => {
    Price.init(
      {
        id: {
          type: DataTypes.INTEGER,
          autoIncrement: true,
          primaryKey: true,
        },
        city_id: {
          type: DataTypes.INTEGER,
          allowNull: true,
          references: {
            model: 'cities',
            key: 'id'
          }
        },
        self_employed_data: {
          type: DataTypes.JSON,
          allowNull: true,
        },
        clients_mani_data: {
          type: DataTypes.JSON,
          allowNull: true,
        },
        clients_pedi_data: {
          type: DataTypes.JSON,
          allowNull: true,
        },
        clients_mani_pedi_four_hands_data: {
          type: DataTypes.JSON,
          allowNull: true,
        },
        clients_design_data: {
          type: DataTypes.JSON,
          allowNull: true,
        },
        clients_additional_nail_services_data: {
          type: DataTypes.JSON,
          allowNull: true,
        },
        clients_brow_arch_data: {
          type: DataTypes.JSON,
          allowNull: true,
        },
        clients_promo_data: {
          type: DataTypes.JSON,
          allowNull: true,
        },
        clients_model_data: {
          type: DataTypes.JSON,
          allowNull: true,
        },
        clients_goods_data: {
          type: DataTypes.JSON,
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
        tableName: "prices",
        timestamps: true,
        createdAt: "created_at",
        updatedAt: "updated_at",
      }
    );
  };