import {
  readdir,
  unlink,
  rmdir,
  stat,
  mkdir,
  writeFile as writeFileFS,
  readFile as readFileFS,
} from "fs/promises";
import { join } from "path";

export const removeFolder = async (folderPath: string): Promise<void> => {
  try {
    await stat(folderPath);
  } catch {
    return;
  }

  const files = await readdir(folderPath);
  for (const file of files) {
    const filePath = join(folderPath, file);
    const fileStat = await stat(filePath);
    if (fileStat.isDirectory()) await removeFolder(filePath);
    else await unlink(filePath);
  }

  await rmdir(folderPath);
};

export const createFolder = async (folderPath: string): Promise<void> => {
  await mkdir(folderPath, { recursive: true });
};

export const writeFile = async (
  filePath: string,
  buffer: Buffer
): Promise<void> => {
  await writeFileFS(filePath, buffer);
};

export const readFile = async (filePath: string): Promise<Buffer> => {
  return await readFileFS(filePath);
};
