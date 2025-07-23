import { Router } from "express";
import DocxController from "../controllers/docx.controller.js";
import authenticateTokenMiddleware from "../middlewares/authenticateToken.middleware.js";
import checkIsAdminMiddleware from "../middlewares/checkIsAdmin.middleware.js";
import checkValidateDocxMiddleware from "../middlewares/checkValidateDocx.middleware.js";

const router = Router();

router.get(
  "/docx/getDocxs",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  DocxController.getDocxs
);

router.post(
  "/docx/testDocx",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  DocxController.testDocx
);

router.put(
  "/docx/saveDocx",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  checkValidateDocxMiddleware,
  DocxController.saveDocx
);

router.delete(
  "/docx/deleteDocx",
  authenticateTokenMiddleware,
  checkIsAdminMiddleware,
  DocxController.deleteDocx
);

export default router;
