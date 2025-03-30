import queryDB from ".";

export const createVerificatioCodeQuery = async ({
  userId,
  type,
  value,
  code,
  expiresAt,
}: {
  userId: any;
  type: any;
  value: any;
  code: any;
  expiresAt: any;
}) => {
  await queryDB(
    `INSERT INTO public.verification_codes (user_id, type, value, code, expires_at)
     VALUES ($1, $2, $3, $4, $5)`,
    [userId, type, value, code, expiresAt]
  );
};

export const getUserQuery = async (id: any) => {
  const query = `SELECT * FROM public.users WHERE id = $1`;
  const result = await queryDB(query, [id]);
  return result.rows[0];
};

export const getUserByQuery = async (key: string, value: string) => {
  const query = `SELECT * FROM public.users WHERE ${key} = $1`;
  const result = await queryDB(query, [value]);
  return result.rows[0];
};

// export const createUserQuery = async ({phone}) => {
//   const query = `INSERT INTO public.users DEFAULT VALUES RETURNING id;`;
//   const result = await queryDB(query, []);
//   return result.rows[0].id;
// };

export const createUserQuery = async ({
  name,
  surname,
  patronymic,
  phone,
  email,
  inn,
}: {
  name: string;
  surname: string;
  patronymic: string;
  phone: any;
  email: string;
  inn: any;
}) => {
  const query = `INSERT INTO public.users (name, surname, patronymic, phone, email, inn) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id;`;
  const result = await queryDB(query, [
    name,
    surname,
    patronymic,
    phone,
    email,
    inn,
  ]);

  return result.rows[0].id;
};

// export const updateUserFullnameByIdQuery = async ({
//   name,
//   surname,
//   patronymic,
//   id,
// }: {
//   name: string;
//   surname: string;
//   patronymic: string;
//   id: any;
// }) => {
//   const query = `UPDATE public.users
//   SET name = $1, surname = $2, patronymic = $3 WHERE id = $4;`;
//   await queryDB(query, [name, surname, patronymic, id]);
// };

export const updateUserPhoneByIdQuery = async ({
  phone,
  id,
}: {
  phone: string;
  id: any;
}) => {
  const query = `UPDATE public.users
  SET phone = $1 WHERE id = $2;`;
  await queryDB(query, [phone, id]);
};

export const updateUserEmailByIdQuery = async ({
  email,
  id,
}: {
  email: string;
  id: any;
}) => {
  const query = `UPDATE public.users
  SET email = $1 WHERE id = $2;`;
  await queryDB(query, [email, id]);
};
