import { Router } from "express";
import SettingsController from "../controllers/settings.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsAdminMiddleware from "../middlewares/checkIsAdmin.middleware.js";
import checkSettingsTerminationReasonsMiddleware from "../middlewares/checkSettingsTerminationReasons.middleware.js";
import checkValidateSettingsPeriodicityMiddleware from "../middlewares/checkValidateSettingsPeriodicity.middleware.js";

const router = Router();

router.get(
    "/settings/getSettingsPeriodicity",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    SettingsController.getSettingsPeriodicity
);

router.put(
    "/settings/updateSettingsPeriodicity",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    checkValidateSettingsPeriodicityMiddleware,
    SettingsController.updateSettingsPeriodicity
);

router.get(
    "/settings/getSettingsTerminationReasons",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    SettingsController.getSettingsTerminationReasons
);

router.put(
    "/settings/updateSettingsTerminationReason",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    checkSettingsTerminationReasonsMiddleware,
    SettingsController.updateSettingsTerminationReason
);

export default router;
