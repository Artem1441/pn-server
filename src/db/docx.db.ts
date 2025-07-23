import errors from "../constants/errors";
import { Docx } from "../models/Docx.model";
import IDocx from "../types/IDocx.interface";

export const createDocx = async ({
  file_key,
  file_type,
}: {
  file_key: IDocx["file_key"];
  file_type: IDocx["file_type"];
}): Promise<number> => {
  try {
    const docx = await Docx.create({ file_key, file_type });
    return docx.id;
  } catch (error) {
    console.error("Ошибка при создании docx:", error);
    return -1;
  }
};

export const updateDocx = async ({
  id,
  file_key,
  file_type,
}: {
  id: IDocx["id"];
  file_key: IDocx["file_key"];
  file_type: IDocx["file_type"];
}): Promise<void> => {
  try {
    const docx = await Docx.findByPk(id);
    if (!docx) throw null;
    docx.file_key = file_key;
    docx.file_type = file_type;

    await docx.save();
  } catch (err) {
    console.error("Ошибка при обновлении docx:", err);
    throw null;
  }
};

export const getDocxByFileType = async (
  file_type: IDocx["file_key"]
): Promise<IDocx | null> => {
  const docx = await Docx.findOne({
    where: { ["file_type"]: file_type },
  });
  if (!docx) return null;
  return docx.toJSON();
};

export const getDocxs = async (): Promise<IDocx[]> => {
  try {
    const docxs = await Docx.findAll();
    if (!docxs) throw null;
    return docxs;
  } catch (error) {
    console.error("Ошибка при получении docxs:", error);
    throw null;
  }
};

export const deleteDocx = async (id: IDocx["id"]): Promise<void> => {
  try {
    const docx = await Docx.findByPk(id);

    if (!docx) throw new Error(errors.docxNotFound);

    await docx.destroy();
  } catch (err: any) {
    console.error("Ошибка при удалении docx:", err);
    throw null;
  }
};