import { Router } from "express";
import { swaggerDocs, swaggerUi } from "../helpers/swagger.helper";

const router = Router();

router.use("/swagger", swaggerUi.serve, swaggerUi.setup(swaggerDocs));

export default router;