import { S3, GetObjectCommand } from "@aws-sdk/client-s3";
import { Readable } from "stream";
import dotenv from "dotenv";
dotenv.config();

const s3 = new S3({
  endpoint: String(process.env.S3_ENDPOINT),
  region: String(process.env.S3_REGION),
  credentials: {
    accessKeyId: String(process.env.S3_ACCESS_KEY),
    secretAccessKey: String(process.env.S3_SECRET_KEY),
  },
  forcePathStyle: true,
});

export const S3Upload = async (
  fileKey: string,
  compressedBuffer: Buffer,
  mimetype: string
): Promise<void> => {
  try {
    const params = {
      Bucket: String(process.env.S3_BUCKET), // Указываем имя бакета
      Key: fileKey, // Имя файла
      Body: compressedBuffer, // Тело запроса (содержимое файла)
      ContentType: mimetype, // Тип контента (например, image/jpeg)
      ContentDisposition: "inline", // Для inline-отображения (опционально)
      CacheControl: "max-age=31536000", // Контроль кеширования
    };

    await s3.putObject(params);

  } catch (error: any) {
    console.error("Ошибка загрузки в S3:", error);
  }
};

export const S3Get = async (fileKey: string) => {
  const command = new GetObjectCommand({
    Bucket: String(process.env.S3_BUCKET),
    Key: fileKey,
  });

  const response = await s3.send(command);
  return response.Body as Readable;
};
