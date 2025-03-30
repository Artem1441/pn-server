import bcrypt from "bcrypt";

export const bcryptHash = async (password: string) => {
  return await bcrypt.hash(password, 10); 
};

