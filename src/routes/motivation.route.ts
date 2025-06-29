import { Router } from "express";
import MotivationController from "../controllers/motivation.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsAdminMiddleware from "../middlewares/checkIsAdmin.middleware.js";
import checkValidateMotivationMiddleware from "../middlewares/checkValidateMotivation.middleware.js";

const router = Router();

router.get(
    "/motivation/getMotivation",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    MotivationController.getMotivation
);

router.put(
    "/motivation/updateMotivation",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    checkValidateMotivationMiddleware,
    MotivationController.updateMotivation
);

export default router;
