const messages = {
    smsRequestProcessedSent: "Анкета рассмотрена. Вся информация на вашей почте",
    emailRequestProcessedSent: "Результат проверки регистрации",
    emailRejectRequestProcessedSent: (rejectionReason: string) => `Ваша заявка на регистрацию не прошла окончательную проверку. Причина: "${rejectionReason}". \n\nВы можете зарегистрироваться снова, исправив указанную проблему.`,
    emailAcceptRequestProcessedSent: (login: string, password: string) => `Ваша заявка одобрена. Вы успешно зарегистрированы.\n\nДанные для входа:\nЛогин: ${login}\nПароль: ${password}\n\nРекомендуем:\n- Сохранить эти данные в безопасном месте.\n- Не передавать их третьим лицам.\n- При необходимости — изменить пароль в настройках профиля.`,
}

export default messages