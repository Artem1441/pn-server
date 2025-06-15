import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

dotenv.config();

const sequelize = new Sequelize(
  String(process.env.DB_NAME), 
  String(process.env.DB_USER), 
  String(process.env.DB_PASSWORD),
  {
    host: String(process.env.DB_HOST),
    port: Number(process.env.DB_PORT),
    dialect: 'postgres',
    // logging: true, // Включаем логирование запросов (отключить в проде)
    logging: false,
  }
);

 const testConnection = async() => {
  try {
    await sequelize.authenticate();
    console.log('Соединение с базой данных успешно установлено.');
  } catch (error) {
    console.error('Не удалось подключиться к базе данных:', error);
  }
}

testConnection();

export default sequelize;
