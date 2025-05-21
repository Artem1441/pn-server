const tokens = {
  clearToken: {
    httpOnly: true,
    secure: true,
    sameSite: "strict" as const,
  },
  token: {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production", // Secure только в проде
    sameSite: "lax" as const, // явно указываем тип как литерал "lax"
    maxAge: 7 * 24 * 60 * 60 * 1000,
  },

  signUpToken: {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production", // Secure только в проде
    sameSite: "lax" as const,
    maxAge: 24 * 60 * 60 * 1000,
  },
};

export default tokens;
