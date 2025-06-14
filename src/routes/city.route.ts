import { Router } from "express";
import CityController from "../controllers/city.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsAdminMiddleware from "../middlewares/checkIsAdmin.middleware.js";
import checkValidateCityMiddleware from "../middlewares/checkValidateCity.middleware.js";

const router = Router();

router.get(
  "/city/getCities",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  CityController.getCities
);

router.post(
  "/city/createCity",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  checkValidateCityMiddleware,
  CityController.createCity
);

router.put(
  "/city/updateCity",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  checkValidateCityMiddleware,
  CityController.updateCity
);

router.delete(
  "/city/deleteCity",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  CityController.deleteCity
);

export default router;
