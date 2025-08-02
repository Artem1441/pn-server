import { Request, Response } from "express";
import path, { join, resolve } from "path";
import fs from "fs";
import errors from "../constants/errors";
import {
  createDocx,
  deleteDocx,
  getDocxByFileType,
  getDocxs,
  updateDocx,
} from "../db/docx.db";
import DocumentType from "../types/DocumentType.type";
import IDocx from "../types/IDocx.interface";
import IResp from "../types/IResp.interface";
import { S3Get, S3Upload } from "../helpers/s3.helper";
import {
  createFolder,
  removeFolder,
  writeFile,
  readFile,
} from "../helpers/file.helper";
import AdmZip from "adm-zip";
import { parseStringPromise, Builder } from "xml2js";
import libre from "libreoffice-convert";
import { PDFDocument } from "pdf-lib";
import { v4 as uuidv4 } from "uuid";
import extensionsToMime from "../constants/extensionsToMime";
import docxFields from "../constants/docxFields";
import { Model } from "sequelize";

class DocxController {
  private createFolderWithMaterials = ({
    zip,
    zipFolderPath,
  }: {
    zip: AdmZip;
    zipFolderPath: string;
  }) => {
    zip.extractAllTo(zipFolderPath, true);
    // console.log(`Файл распакован в ${zipFolderPath}`);
  };

  private changeText = ({
    zipFolderPath,
    placeholder,
    value,
    symb = "t",
  }: {
    zipFolderPath: string;
    placeholder: string;
    value: string;
    symb?: string;
  }) => {
    const documentXmlPath = path.join(zipFolderPath, "word", "document.xml");
    let content = fs.readFileSync(documentXmlPath, "utf8");

    const escapedPlaceholder = `${symb}${placeholder}${symb}`.replace(
      /[-/\\^$*+?.()|[\]{}]/g,
      "\\$&"
    );
    const regex = new RegExp(escapedPlaceholder, "g");

    content = content.replace(regex, value);

    fs.writeFileSync(documentXmlPath, content, "utf8");
    // console.log(`Заменено ${placeholder} → ${value} в document.xml`);
  };

  private createDocxFromMaterials = ({
    zip,
    zipFolderPath,
    outputDocxPath,
    zipPath = "",
  }: {
    zip: AdmZip;
    zipFolderPath: string;
    outputDocxPath: string;
    zipPath?: string;
  }) => {
    const files = fs.readdirSync(zipFolderPath);
    for (const file of files) {
      const fullPath = path.join(zipFolderPath, file);
      const relPath = path.join(zipPath, file);
      const stat = fs.statSync(fullPath);

      if (stat.isDirectory()) {
        this.createDocxFromMaterials({
          zip,
          zipFolderPath: fullPath,
          outputDocxPath,
          zipPath: relPath,
        });
      } else {
        const fileData = fs.readFileSync(fullPath);
        zip.addFile(relPath.replace(/\\/g, "/"), fileData);
      }
    }
    zip.writeZip(outputDocxPath);
    // console.log(
    //   `Из материала ${zipFolderPath} создан .docx файл ${outputDocxPath}`
    // );
  };

  private addImageDependency = async ({
    zipFolderPath,
    imagePath,
    imageNumber,
    relsTarget = "document",
  }: {
    zipFolderPath: string;
    imagePath: string;
    imageNumber: number;
    relsTarget?: string;
  }) => {
    // 1. Копируем картинку в word/media
    const imageFileName = `image${imageNumber}.png`;
    const mediaDir = path.join(zipFolderPath, "word/media");
    if (!fs.existsSync(mediaDir)) fs.mkdirSync(mediaDir, { recursive: true });
    fs.copyFileSync(imagePath, path.join(mediaDir, imageFileName));
    const rId = `rId${Date.now() + Math.floor(Math.random() * 1000)}`;

    // 2. Путь к нужному .rels-файлу
    const relsPath = path.join(
      zipFolderPath,
      "word/_rels",
      `${relsTarget}.xml.rels`
    );
    let relsJson;

    // 3. Читаем или создаём структуру
    if (fs.existsSync(relsPath)) {
      const relsXml = fs.readFileSync(relsPath, "utf8");
      relsJson = await parseStringPromise(relsXml);
    } else {
      relsJson = {
        Relationships: {
          $: {
            xmlns:
              "http://schemas.openxmlformats.org/package/2006/relationships",
          },
          Relationship: [],
        },
      };
    }

    // 4. Добавляем новую зависимость
    if (!relsJson.Relationships.Relationship)
      relsJson.Relationships.Relationship = [];

    relsJson.Relationships.Relationship.push({
      $: {
        Id: rId,
        Type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
        Target: `media/${imageFileName}`,
      },
    });

    // 5. Сохраняем .rels
    const builder = new Builder({
      headless: true,
      xmldec: { version: "1.0", encoding: "UTF-8", standalone: true },
      renderOpts: { pretty: true, indent: "  ", newline: "\n" },
    });

    const xmlBody = builder.buildObject(relsJson);
    const fullXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n${xmlBody}`;
    fs.writeFileSync(relsPath, fullXml, "utf8");

    return rId;
  };

  private generateDrawingXml = ({
    widthSm,
    heightSm,
    rId,
  }: {
    widthSm: number;
    heightSm: number;
    rId: string;
  }) => {
    const cx = Math.round(widthSm * 360000);
    const cy = Math.round(heightSm * 360000);
    const id = Math.floor(Math.random() * 100000);
    return `<w:drawing><wp:inline><wp:extent cx="${cx}" cy="${cy}"/><wp:docPr id="${id}" name="Рисунок"/><wp:cNvGraphicFramePr><a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/></wp:cNvGraphicFramePr><a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:nvPicPr><pic:cNvPr id="${id}" name="Рисунок ${id}"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip r:embed="${rId}" cstate="print"><a:extLst><a:ext uri="{28A0092B-C50C-407E-A947-70E740481C1C}"><a14:useLocalDpi xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" val="0"/></a:ext></a:extLst></a:blip><a:stretch><a:fillRect/></a:stretch></pic:blipFill><pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="${cx}" cy="${cy}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing>`.trim();
  };

  private changeImage = async ({
    zipFolderPath,
    imagePath,
    imageNumber,
    placeholder,
    widthSm,
    heightSm,
    symb = "i",
  }: {
    zipFolderPath: string;
    imagePath: string;
    imageNumber: number;
    placeholder: string;
    widthSm: number;
    heightSm: number;
    symb?: string;
  }) => {
    const filesToProcess = [
      path.join(zipFolderPath, "word", "document.xml"),
      path.join(zipFolderPath, "word", "header1.xml"),
      path.join(zipFolderPath, "word", "header2.xml"),
      path.join(zipFolderPath, "word", "header3.xml"),
      path.join(zipFolderPath, "word", "footer1.xml"),
      path.join(zipFolderPath, "word", "footer2.xml"),
      path.join(zipFolderPath, "word", "footer3.xml"),
    ];

    const escapedSymb = symb.replace(/[-\/\\^$*+?.()|[\]{}]/g, "\\$&");
    const regex = new RegExp(
      `<w:t>${escapedSymb}${placeholder}${escapedSymb}<\\/w:t>`,
      "g"
    );

    for (const filePath of filesToProcess) {
      // console.log(filePath);
      try {
        if (!fs.existsSync(filePath)) {
          console.warn(`Файл не найден: ${filePath}`);
          continue;
        }

        const relsTarget = path.parse(filePath).name;
        let content = fs.readFileSync(filePath, "utf8");
        const rId = await this.addImageDependency({
          zipFolderPath,
          imagePath,
          imageNumber,
          relsTarget: relsTarget,
        });
        const xml = this.generateDrawingXml({ widthSm, heightSm, rId });
        content = content.replace(regex, xml);
        fs.writeFileSync(filePath, content, "utf8");

        // console.log(`Изменения успешно применены к файлу: ${filePath}`);
      } catch (err: any) {
        console.error(`Ошибка при обработке файла ${filePath}: ${err.message}`);
      }
    }
  };

  private docxToPdf = async ({
    inputDocxPath,
    outputPdfPath,
  }: {
    inputDocxPath: string;
    outputPdfPath: string;
  }): Promise<void> => {
    const docxBuf = fs.readFileSync(inputDocxPath);

    return new Promise((resolve, reject) => {
      libre.convert(docxBuf, ".pdf", undefined, (err, done) => {
        if (err) {
          console.error(`Ошибка при конвертации: ${err}`);
          reject(err);
          return;
        }
        fs.writeFileSync(outputPdfPath, done);
        // console.log("PDF создан:", outputPdfPath);
        resolve();
      });
    });
  };

  private addStampToPdf = async ({
    inputPdfPath,
    outputPdfPath,
    stampImagePath,
  }: any) => {
    const pdfBytes = fs.readFileSync(inputPdfPath);
    const pdfDoc = await PDFDocument.load(pdfBytes);

    const stampImageBytes = fs.readFileSync(stampImagePath);
    const stampImage = await pdfDoc.embedPng(stampImageBytes);
    const stampDims = stampImage.scale(0.3); // масштабируем, если нужно

    const pages = pdfDoc.getPages();
    // const lastPage = pages[pages.length - 1]; // if last page
    // lastPage.drawImage(...);
    for (const page of pages) {
      const { width, height } = page.getSize();

      // Координаты слева снизу
      const x = 40; // отступ слева
      const y = 40; // отступ снизу

      page.drawImage(stampImage, {
        x,
        y,
        width: stampDims.width,
        height: stampDims.height,
      });
    }

    const modifiedPdfBytes = await pdfDoc.save();
    fs.writeFileSync(outputPdfPath, modifiedPdfBytes);
    // console.log("Печать добавлена к PDF:", outputPdfPath);
  };

  public getDocxs = async (
    req: Request,
    res: Response<IResp<Partial<Record<DocumentType, IDocx>>>>
  ): Promise<void> => {
    try {
      const docxs = await getDocxs();
      const docxs_obj: Partial<Record<DocumentType, IDocx>> = {};
      docxs.forEach(
        (docx) =>
          (docxs_obj[docx.file_type] = {
            ...(docx as unknown as Model).get({ plain: true }),
            fields: docxFields[docx.file_type].fields,
          })
      );
      res.status(200).json({ status: true, data: docxs_obj });
      return;
    } catch (err: any) {
      console.error("getDocxs error: ", err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public saveDocx = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const {
      file_key,
      file_type,
    }: { file_key: IDocx["file_key"]; file_type: IDocx["file_type"] } =
      req.body;

    try {
      const isDocxExists = await getDocxByFileType(file_type);
      if (isDocxExists) {
        await updateDocx({
          id: isDocxExists.id,
          file_key,
          file_type,
        });
      } else {
        await createDocx({
          file_key,
          file_type,
        });
      }
      res.status(200).json({
        status: true,
      });
      return;
    } catch (err: any) {
      console.error("saveDocx error: ", err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public testDocx = async (
    req: Request,
    res: Response<IResp<string>>
  ): Promise<void> => {
    const { file_type }: { file_type: IDocx["file_type"] } = req.body;
    if (!file_type) throw null;
    let folderPath: string | undefined;

    try {
      const docx = await getDocxByFileType(file_type);
      if (!docx) throw null;
      const { file_key } = docx;

      folderPath = resolve(__dirname, `folder_${file_key}`);
      const zipFolderPath = join(folderPath, "zip");
      const inputDocxPath = join(folderPath, "document.docx");
      const outputDocxPath = join(folderPath, "temp.docx");
      const outputPdfTempPath = join(folderPath, "temp.pdf");
      const outputPdfPath = join(folderPath, "result.pdf");
      const chunks: Buffer[] = [];
      const fileStream = await S3Get(file_key);

      await createFolder(folderPath);
      for await (const chunk of fileStream) chunks.push(chunk);
      await writeFile(inputDocxPath, Buffer.concat(chunks));
      const zip = new AdmZip(inputDocxPath);

      this.createFolderWithMaterials({ zip, zipFolderPath });

      docxFields[file_type].texts.forEach((el) => {
        this.changeText({
          zipFolderPath,
          placeholder: el.placeholder,
          value: el.value,
        });
      });

      for (const item of docxFields[file_type].images) {
        await this.changeImage({
          zipFolderPath,
          placeholder: item.placeholder,
          imagePath: join(__dirname, "..", "assets", "images", item.filename),
          imageNumber: item.imageNumber,
          widthSm: item.widthSm,
          heightSm: item.heightSm,
        });
      }

      this.createDocxFromMaterials({ zip, zipFolderPath, outputDocxPath });

      await this.docxToPdf({
        inputDocxPath: outputDocxPath,
        outputPdfPath: outputPdfTempPath,
      });

      await this.addStampToPdf({
        inputPdfPath: outputPdfTempPath,
        outputPdfPath: outputPdfPath,
        stampImagePath: join(__dirname, "..", "assets", "images", "stamp.png"),
      });

      const pdfFileBuffer = await readFile(outputPdfPath);
      const fileKey = uuidv4();
      await S3Upload(fileKey, pdfFileBuffer, extensionsToMime.pdf);

      res.status(200).json({ status: true, data: fileKey });
      return;
    } catch (err: any) {
      console.error("testDocx error: ", err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    } finally {
      if (folderPath) await removeFolder(folderPath);
    }
  };

  public deleteDocx = async (
    req: Request,
    res: Response<IResp<null>>
  ): Promise<void> => {
    const { id } = req.query;
    try {
      if (id) await deleteDocx(Number(id));
      res.status(200).json({
        status: true,
      });
      return;
    } catch (err: any) {
      console.error("deleteDocx error: ", err);
      res
        .status(500)
        .json({ status: false, error: err.message || errors.serverError });
      return;
    }
  };
}

export default new DocxController();
