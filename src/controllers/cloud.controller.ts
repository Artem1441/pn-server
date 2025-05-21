import { v4 as uuidv4 } from "uuid";
import { Request, Response } from "express";
import { S3Get, S3Upload } from "../helpers/s3.helper";
import IResp from "../types/IResp.interface";

class CloudController {
  getImage = async (req: Request, res: Response<IResp<string>>) => {
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
  uploadFile = async (req: Request, res: Response<IResp<string>>) => {
    const { file } = req;
    // console.log(file)
    // const file = files[0]

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

  //   async upload(req: Request, res: Response) {
  //     const { files } = req;
  //     const { is_active } = req.body;
  //     if (!files || !Array.isArray(files) || files.length === 0) {
  //       res.status(400).send("Нет файлов для загрузки");
  //       return;
  //     }

  //     console.log(is_active);

  //     const userId = req.user.id;
  //     const uploadedFiles = [];
  //     const unsupportedFiles = [];

  //     for (const file of req.files) {
  //       const fileKey = uuidv4();
  //       const fileType = file.mimetype.split("/")[1];
  //       const normalizedFileType =
  //         fileType === "jpeg"
  //           ? "jpg"
  //           : fileType === "quicktime" || fileType === "webm"
  //           ? "mp4"
  //           : fileType;
  //       const fileName = file.originalname;

  //       if (
  //         !["jpg", "png", "mp4", "mov", "avi", "quicktime"].includes(
  //           normalizedFileType
  //         )
  //       ) {
  //         console.warn(
  //           `Файл ${fileName} имеет неподдерживаемый формат. Пропускаем.`
  //         );
  //         unsupportedFiles.push(fileName);
  //         continue;
  //       }

  //       let compressedBuffer = file.buffer;

  //       try {
  //         if (["jpg", "png"].includes(normalizedFileType)) {
  //           compressedBuffer = await compressImage(file.buffer);
  //         } else if (["mp4", "mov", "avi"].includes(normalizedFileType)) {
  //           compressedBuffer = await compressVideo(file.buffer);
  //         }

  //         const url = await S3Upload(fileKey, compressedBuffer, file.mimetype);

  //         const id = await uploadFileQuery(
  //           userId,
  //           fileName,
  //           normalizedFileType,
  //           compressedBuffer.length,
  //           url,
  //           is_active
  //         );

  //         uploadedFiles.push({
  //           id,
  //           type: normalizedFileType,
  //           url,
  //         });
  //       } catch (error) {
  //         console.error("Ошибка загрузки файла:", error);
  //       }
  //     }

  //     let responseMessage: UploadResponse = {
  //       status: true,
  //       result: uploadedFiles,
  //     };

  //     if (unsupportedFiles.length > 0) {
  //       responseMessage = {
  //         ...responseMessage,
  //         message: `Файлы с неподдерживаемым форматом: ${unsupportedFiles.join(
  //           ", "
  //         )}`,
  //       };
  //     }

  //     res.status(200).json(responseMessage);
  //   }
}

export default new CloudController();
