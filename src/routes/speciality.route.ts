import { Router } from "express";
import SpecialityController from "../controllers/speciality.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsAdminMiddleware from "../middlewares/checkIsAdmin.middleware.js";
import checkValidateSpecialityMiddleware from "../middlewares/checkValidateSpeciality.middleware.js";

const router = Router();

router.get(
  "/speciality/getSpecialities",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  SpecialityController.getSpecialities
);

router.post(
  "/speciality/createSpeciality",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  checkValidateSpecialityMiddleware,
  SpecialityController.createSpeciality
);

router.put(
  "/speciality/updateSpeciality",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  checkValidateSpecialityMiddleware,
  SpecialityController.updateSpeciality
);

router.delete(
  "/speciality/deleteSpeciality",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  SpecialityController.deleteSpeciality
);

export default router;
