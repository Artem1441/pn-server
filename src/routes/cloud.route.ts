import { Router } from "express";
import multer from "multer";
import CloudController from "../controllers/cloud.controller.js";

const upload = multer({ storage: multer.memoryStorage() });
const router = Router();

/**
 * @openapi
 * /cloud/images/{fileKey}:
 *   get:
 *     summary: Получить изображение по ключу
 *     parameters:
 *       - name: fileKey
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Изображение
 *       404:
 *         description: Файл не найден
 */
router.get("/cloud/images/:fileKey", CloudController.getImage)

router.post(
  "/cloud/uploadFile",
  upload.single("file"),
  CloudController.uploadFile
);

export default router;
