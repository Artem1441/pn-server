import bcrypt from "bcrypt";

export const hashPassword = async (password: string): Promise<string> => {
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
};

export const bcryptCompare = async (
  password: string,
  hashPass: string
): Promise<boolean> => {
  return await bcrypt.compare(password, hashPass);
};
