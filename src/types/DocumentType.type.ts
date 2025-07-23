export const DocumentTypes = {
  ACCESSION_AGREEMENT: "accession_agreement", // ДОГОВОР ПРИСОЕДИНЕНИЯ
  ACCESSION_APPLICATION: "accession_application", // ЗАЯВЛЕНИЕ О ПРИСОЕДИНЕНИИ
  WORKPLACE_RENT_NAIL_MASTER: "workplace_rent_nail_master", // ДОГОВОР АРЕНДЫ РАБОЧЕГО МЕСТА С МАСТЕРОМ НОГТЕВОГО СЕРВИСА
  WORKPLACE_TRANSFER_ACT_NAIL: "workplace_transfer_act_nail", // АКТ ПРИЕМА-ПЕРЕДАЧИ РАБОЧЕГО МЕСТА В АРЕНДУ МАСТЕРОМ НОГТЕВОГО СЕРВИСА
  WORKPLACE_RETURN_ACT_NAIL: "workplace_return_act_nail", // АКТ ВОЗВРАТА РАБОЧЕГО МЕСТА ИЗ АРЕНДЫ МАСТЕРОМ НОГТЕВОГО СЕРВИСА
  WORKPLACE_RENT_BROW_MASTER: "workplace_rent_brow_master", // ДОГОВОР АРЕНДЫ РАБОЧЕГО МЕСТА С МАСТЕРОМ-БРОВИСТОМ
  WORKPLACE_TRANSFER_ACT_BROW: "workplace_transfer_act_brow", // АКТ ПРИЕМА-ПЕРЕДАЧИ РАБОЧЕГО МЕСТА В АРЕНДУ МАСТЕРОМ-БРОВИСТОМ
  WORKPLACE_RETURN_ACT_BROW: "workplace_return_act_brow", // АКТ ВОЗВРАТА РАБОЧЕГО МЕСТА ИЗ АРЕНДЫ МАСТЕРОМ БРОВИСТОМ
  AGENT_AGREEMENT: "agent_agreement", // АГЕНТСКИЙ ДОГОВОР С МАСТЕРАМИ
  AGENT_COMPENSATION_POLICY: "agent_compensation_policy", // ПОРЯДОК ОПРЕДЕЛЕНИЯ ВОЗНАГРАЖДЕНИЯ АГЕНТА
  AGENT_REPORT: "agent_report", // ОТЧЕТ АГЕНТА О ВЫПОЛНЕНИИ ПОРУЧЕНИЯ ПРИНЦИПАЛА
  SERVICE_ACT: "service_act", // АКТ ОКАЗАННЫХ УСЛУГ
  AGENT_TERMINATION_NOTICE: "agent_termination_notice", // УВЕДОМЛЕНИЕ ОБ ОТКАЗЕ ОТ АГЕНТСКОГО ДОГОВОРА
} as const;

type DocumentType = (typeof DocumentTypes)[keyof typeof DocumentTypes];

export default DocumentType;
