import { Request, Response, NextFunction } from "express"
import errors from "../constants/errors"
import IResp from "../types/IResp.interface"
import IUser from "../types/IUser.interface"

type PasswordCheckResult = { status: true } | { status: false; error: string }

const checkPasswordStrength = (password: string): PasswordCheckResult => {
  if (password.length < 8) {
    return {
      status: false,
      error: "Пароль должен содержать минимум 8 символов",
    }
  }

  //   if (!/\d/.test(password)) {
  //     return {
  //       status: false,
  //       message: "Пароль должен содержать хотя бы одну цифру",
  //     }
  //   }

  //   if (!/[A-Z]/.test(password)) {
  //     return {
  //       status: false,
  //       message: "Пароль должен содержать хотя бы одну заглавную букву",
  //     }
  //   }

  //   if (!/[a-z]/.test(password)) {
  //     return {
  //       status: false,
  //       message: "Пароль должен содержать хотя бы одну строчную букву",
  //     }
  //   }

  //   if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
  //     return {
  //       status: false,
  //       message:
  //         "Пароль должен содержать хотя бы один спецсимвол (!@#$%^&* и т.д.)",
  //     }
  //   }

  return { status: true }
}

const checkPasswordStrengthMiddleware = async (
  req: Request,
  res: Response<IResp<null>>,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      user: { id },
      currentPassword,
      newPassword,
    }: {
      user: {
        id: IUser["id"]
      }
      currentPassword: IUser["password"]
      newPassword: IUser["password"]
    } = req.body

    if (!id || !currentPassword || !newPassword) {
      res.status(400).json({ status: false, error: errors.allFieldsRequired })
      return
    }

    const isValidNewPassword = checkPasswordStrength(newPassword)

    if (!isValidNewPassword.status) {
      res.status(400).json({ status: false, error: isValidNewPassword.error })
      return
    }

    next()
  } catch (error) {
    res.status(500).json({ status: false, error: errors.serverError })
    return
  }
}

export default checkPasswordStrengthMiddleware
