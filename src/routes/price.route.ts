import { Router } from "express";
import PriceController from "../controllers/price.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsAdminMiddleware from "../middlewares/checkIsAdmin.middleware.js";
import checkValidatePriceMiddleware from "../middlewares/checkValidatePrice.middleware.js";

const router = Router();

router.get(
    "/price/getPrices",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    PriceController.getPrices
);

router.post(
    "/price/createPrice",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    checkValidatePriceMiddleware,
    PriceController.createPrice
);

router.put(
    "/price/updatePrice",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    checkValidatePriceMiddleware,
    PriceController.updatePrice
);

router.delete(
    "/price/deletePrice",
    authenticateTokenMiddleware,
    checkIsAdminMiddleware,
    PriceController.deletePrice
);

export default router;
