import { Router } from "express";
import StudioController from "../controllers/studio.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsAdminMiddleware from "../middlewares/checkIsAdmin.middleware.js";
import checkValidateStudioMiddleware from "../middlewares/checkValidateStudio.middleware.js";

const router = Router();

router.get(
    "/studio/getStudios",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    StudioController.getStudios
);

router.post(
    "/studio/createStudio",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    checkValidateStudioMiddleware,
    StudioController.createStudio
);

router.put(
    "/studio/updateStudio",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    checkValidateStudioMiddleware,
    StudioController.updateStudio
);

router.delete(
    "/studio/deleteStudio",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    StudioController.deleteStudio
);

export default router;
