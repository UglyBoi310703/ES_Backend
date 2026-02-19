import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export const typeOrmConfig: TypeOrmModuleOptions = {
  type: 'mysql',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  username: process.env.DB_USER || 'laptopuser',
  password: process.env.DB_PASSWORD || 'laptoppassword',
  database: process.env.DB_NAME || 'laptop_store',
  entities: [__dirname + '/../entities/*.entity{.ts,.js}'],
  synchronize: false, // Set to false in production, use migrations instead
  logging: process.env.NODE_ENV === 'development',
  charset: 'utf8mb4',
  timezone: '+07:00',
};
