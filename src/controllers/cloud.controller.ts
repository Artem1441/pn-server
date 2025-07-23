import { v4 as uuidv4 } from "uuid";
import { Request, Response } from "express";
import { S3Get, S3Upload } from "../helpers/s3.helper";
import IResp from "../types/IResp.interface";
import extensionsToMime from "../constants/extensionsToMime";

class CloudController {
  public getImage = async (
    req: Request,
    res: Response<IResp<string>>
  ): Promise<void> => {
    const { fileKey } = req.params;

    try {
      const fileStream = await S3Get(fileKey);

      res.header("Content-Type", "image/jpeg");
      fileStream.pipe(res);
    } catch (err) {
      res.status(500).send({
        status: false,
        error: "Не удалось прочитать файл",
      });
    }
  };

  public getFile = async (
    req: Request,
    res: Response<IResp<string>>
  ): Promise<void> => {
    const { fileKey } = req.params;
    const { type } = req.query; // "docx", "pdf" и т.д.

    try {
      const fileStream = await S3Get(fileKey);
      const mimeType =
        extensionsToMime[type as string] || "application/octet-stream";
      res.header("Content-Type", mimeType);

      // Для скачивания (опционально) можно добавить заголовок:
      // res.header("Content-Disposition", `attachment; filename="${fileKey}.${type}"`);

      fileStream.pipe(res);
    } catch (err) {
      res.status(500).send({
        status: false,
        error: "Не удалось прочитать файл",
      });
    }
  };

  public uploadFile = async (
    req: Request,
    res: Response<IResp<string>>
  ): Promise<void> => {
    const { file } = req;

    if (!file) {
      res.status(400).send({
        status: false,
        error: "Нет файла для загрузки",
      });
      return;
    }

    const fileKey = uuidv4();
    await S3Upload(fileKey, file.buffer, file.mimetype);

    res.status(200).json({ status: true, data: fileKey });
  };
}

export default new CloudController();
