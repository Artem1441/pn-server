import { Router } from "express";
import NotificationController from "../controllers/notification.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";

const router = Router();

router.get(
    "/notification/getAllCounts",
    authenticateTokenMiddleware,
    NotificationController.getAllCounts
);

router.get(
    "/notification/admin/getAll",
    authenticateTokenMiddleware,
    NotificationController.adminGetAll
);

router.get(
    "/notification/archive/getAll",
    authenticateTokenMiddleware,
    NotificationController.archiveGetAll
);

router.get(
    "/notification/settings/getAll",
    authenticateTokenMiddleware,
    NotificationController.settingsGetAll
);

router.get(
    "/notification/admin/getAllCount",
    authenticateTokenMiddleware,
    NotificationController.adminGetAllCount
);

router.get(
    "/notification/archive/getAllCount",
    authenticateTokenMiddleware,
    NotificationController.archiveGetAllCount
);

router.get(
    "/notification/settings/getAllCount",
    authenticateTokenMiddleware,
    NotificationController.settingsGetAllCount
);


export default router;
