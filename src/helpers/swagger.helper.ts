import swaggerJsDoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";
import dotenv from "dotenv";
dotenv.config();

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "My API",
      version: "1.0.0",
      description: "Документация API для моего приложения",
    },
    components: {
      schemas: {
        //   ErrorResponse: {
        //     type: 'object',
        //     properties: {
        //       status: {
        //         type: 'boolean',
        //         example: false,
        //       },
        //       error: {
        //         type: 'string',
        //         example: 'Ошибка: Email уже используется',
        //       },
        //     },
        //   },
        //   SuccessResponse: {
        //     type: 'object',
        //     properties: {
        //       status: {
        //         type: 'boolean',
        //         example: true,
        //       },
        //     },
        //   },
      },
    },
    servers: [
      {
        url: `http://localhost:${Number(process.env.PORT)}`,
      },
    ],
  },
  apis: ["./src/routes/*.route.ts"],
};

const swaggerDocs = swaggerJsDoc(options);

export { swaggerUi, swaggerDocs };
