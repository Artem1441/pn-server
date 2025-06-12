import { Router } from "express";
import InformationController from "../controllers/information.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsAdminMiddleware from "../middlewares/checkIsAdmin.middleware.js";
import checkValidateInformationMiddleware from "../middlewares/checkValidateInformation.middleware.js";

const router = Router();

router.get(
    "/information/getInformation",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    InformationController.getInformation
);

router.put(
    "/information/updateInformation",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    checkValidateInformationMiddleware,
    InformationController.updateInformation
);

router.get(
    "/information/getInformationChanges",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    InformationController.getInformationChanges
);

export default router;
