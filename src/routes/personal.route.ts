import { Router } from "express";
import PersonalController from "../controllers/personal.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsSpecialistMiddleware from "../middlewares/checkIsSpecialist.middleware.js";
import checkValidateMotivationMiddleware from "../middlewares/checkValidateMotivation.middleware.js";

const router = Router();

router.get(
    "/personal/getPersonalData",
    authenticateTokenMiddleware,
    checkIsSpecialistMiddleware,
    PersonalController.getPersonalData
);

// router.put(
//     "/personal/updateMotivation",
//     // authenticateTokenMiddleware,
//     // checkIsAdminMiddleware,
//     checkValidateMotivationMiddleware,
//     MotivationController.updateMotivation
// );

export default router;
