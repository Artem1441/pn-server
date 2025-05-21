const errors = {
  missingToken: "Токен отсутствует",
  missingCookies: "Куки отсутствуют",
  incorrectType: "Неверный тип",
  incorrectInn: "Некоррректный ИНН",
  invalidOrExpiredCode: "Invalid or expired code",

  unexpectedError: "Неожиданная ошибка",

  nameAndSurnameInvalid: "Введите имя и фамилию",
  phoneInvalid: "Введите корректный формат телефона",
  emailInvalid: "Введите корректный формат email",
  innInvalid: "Введите корректный формат ИНН (12 цифр)",

  userWithEmailAlreadyExists: "Пользователь с такой почтой уже есть в системе",
  userWithPhoneAlreadyExists:
    "Пользователь с таким телефоном уже есть в системе",
  userWithInnAlreadyExists: "Пользователь с таким ИНН уже есть в системе",

  userNotFound: "Пользователь не найден",

  serverError: "Ошибка сервера",

  troublesWithCheckingInn: "Проблемы со стороны налоговой. Попробуйте ещё раз",

  passportSeriesInvalid: "Серия паспорта должна состоять из 4 цифр",
  passportNumberInvalid: "Номер паспорта должен состоять из 6 цифр",
  issueDateInvalid: "Дата выдачи указана некорректно",
  issuedByInvalid: "Не указано, кем выдан паспорт",
  birthdayInvalid: "Дата рождения указана некорректно",
  nationalityInvalid: "Гражданство должно быть Российской Федерацией",
  registrationAddressInvalid: "Адрес регистрации не указан",
  residentialAddressInvalid: "Фактический адрес проживания не указан",

  passportMainRequired: "Фото основного разворота паспорта не загружено",
  passportRegistrationRequired: "Фото страницы с регистрацией не загружено",
  photoFrontRequired: "Фото пользователя не загружено",

  bankBikRequired: "БИК должен состоять из 9 цифр",
  bankAccRequired: "Номер банковского счёта должен состоять из 20 цифр",

  incorrectLogin: "Пользователя с таким логином не существует",
  incorrectPassword: "Неправильный пароль",

  accountBlocked: "Вас заблокировали в системе",

  registrationIncomplete: "Вы не закончили регистрацию",

  taxServiceRateLimitExceeded:
    "Превышено количество запросов к налоговой. Повторите запрос через минуту",
  notRegisteredAsSelfEmployed:
    "Этот ИНП не числится в системе налога на профессиональный доход",
  taxpayerNotFound: "Указанный ИНН не существует",

  bikNotFound: "Указанный БИК не существует",
  accNotFound: "Указанный расчётный счёт не существует",
  tokenExpired: "Токен просрочен",

  passwordTooShort: "Пароль должен содержать минимум 8 символов",

};

export default errors;
