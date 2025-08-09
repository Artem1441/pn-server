import DocumentType from "../types/DocumentType.type"
import { IDocxFields } from "../types/IDocx.interface"

const docxFields: Record<DocumentType, IDocxFields> = {
  accession_agreement: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  accession_application: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  workplace_rent_nail_master: {
    fields: [
      {
        field: "tnumbert",
        fieldRu: "Порядковый номер сотрудника (TJM-0001 / PEE-0001)",
      },
      {
        field: "tcitynamet",
        fieldRu: "Название города (Тюмень / Пермь)",
      },
      {
        field: "tdateaccesst",
        fieldRu: "Дата подписания документа (24 сентября 2025)",
      },
      {
        field: "tfullnamellct",
        fieldRu:
          'Полное наименование организации (Общество с Ограниченной Ответственностью "ПроНогти")',
      },
      {
        field: "tnamellct",
        fieldRu: 'Сокращённое наименование организации (ООО "ПроНогти")',
      },
      {
        field: "tpostt",
        fieldRu: "Должность подписанта (им.падеж) (Генеральный директор)",
      },
      {
        field: "tpostvt",
        fieldRu: "Должность подписанта (вин.падеж) (Генерального директора)",
      },
      {
        field: "tfullnamesignatoryvt",
        fieldRu:
          "ФИО подписанта со стороны компании (вин.падеж) (Луговой Марии Васильевны)",
      },
      {
        field: "tnamesignatoryt",
        fieldRu: "Инициалы подписанта со стороны компании (Луговая М.В.)",
      },
      {
        field: "tlegalinstrumentrt",
        fieldRu:
          "Документ права подписи (род.падеж) (Устава / Доверенности № 01 от 24 сентября 2025 г.)",
      },
      {
        field: "tsubjectfirstt",
        fieldRu: "Обращение (Гражданка / Гражданин)",
      },
      {
        field: "tsubjectsecondt",
        fieldRu: "Упоминание (именуемая / именуемый)",
      },
      {
        field: "tfullnameworkert",
        fieldRu: "ФИО мастера (им.падеж) (Давыдова Виктория Сергеевна)",
      },
      {
        field: "tnameworkert",
        fieldRu: "Инициалы мастера (Давыдова В.С.)",
      },
      {
        field: "tspacet",
        fieldRu: "Площадь (2 / 3)",
      },
      {
        field: "tspacetxtt",
        fieldRu: "Текстовое описание площади ((два) / (три))",
      },
      {
        field: "tobjectdescriptiont",
        fieldRu: "Описание объекта (на первом этаже многоквартирного дома)",
      },
      {
        field: "tcadastralnumbert",
        fieldRu: "Кадастровый номер (72:23:0000000:9418)",
      },
      {
        field: "taddressstudiot",
        fieldRu: "Адрес объекта (г. Тюмень, бульвар Бориса Щербины, д. 20/2)",
      },
      {
        field: "tpurposet",
        fieldRu: "Целевое использование (маникюрного сервиса / бровиста)",
      },
      {
        field: "tlistequipmentonet",
        fieldRu:
          'Стол – 1 шт.',
      },
      {
        field: "tlistequipmenttwot",
        fieldRu:
        'Стул на колесиках для мастера – 1 шт.',
      },
      {
        field: "tlistequipmentthreet",
        fieldRu:
        'Стул для клиента – 1 шт.',
      },
      {
        field: "tlistequipmentfourt",
        fieldRu:
        "Пылесос/ вытяжка – 1 шт."
      },
      {
        field: "tlistequipmentfivet",
        fieldRu:
        "Аппарат для маникюра и педикюра – 1 шт."
      },
      {
        field: "tlistequipmentsixt",
        fieldRu:
        "Лампы для сушки материалов – 2 шт."
      },
      {
        field: "tlistequipmentsevent",
        fieldRu:
        "Лампа настольная – 1 шт."
      },
      {
        field: "tlistequipmenteightt",
        fieldRu:
        "Набор расходных материалов для маникюра/педикюра – 1 к-т."
      },
      {
        field: "tcommonareast",
        fieldRu: "Места общего пользования (на первом этаже)",
      },
      {
        field: "tdaterentalt",
        fieldRu: "Дата договора аренды (29.10.2022)",
      },
      {
        field: "townershipt",
        fieldRu:
          "Право собственности (собственникам на праве долевой собственности)",
      },
      {
        field: "tregistrationnumbert",
        fieldRu:
          "Регистрационные данные (72:23:0000000:9418-72/047/2021-7 от 06.09.2021 г. и 72:23:0000000:9418-72/047/2021-6 от 06.09.2021)",
      },
      {
        field: "ttypeservicet",
        fieldRu:
          "Тип услуг (маникюра / маникюра и педикюра / оформления бровей)",
      },
      {
        field: "trentalcostt",
        fieldRu: "Стоимость аренды (100 / 150 / 200)",
      },
      {
        field: "trentalcosttxtt",
        fieldRu:
          "Текстовое описание цены аренды ((сто) / (сто пятьдесят) / (двести))",
      },
      {
        field: "treriodicityt",
        fieldRu:
          "Периодичность оплаты (еженедельно каждый понедельник / каждые две недели в понедельник)",
      },
      {
        field: "tstartworkt",
        fieldRu: "Начало работы",
      },
      {
        field: "tendworkt",
        fieldRu: "Окончание работы",
      },
      {
        field: "tgeneralequipmentt",
        fieldRu:
          "Общее оборудование (сухожары, ультразвуковую мойку, ванночки для обработки инструментов)",
      },
      {
        field: "taddresslegalt",
        fieldRu:
          "Юридический адрес (625048, РФ, Тюменская обл., г. Тюмень, ул. Лопарева, д. 83, офис 4)",
      },
      {
        field: "taddressactualt",
        fieldRu:
          "Фактический адрес (625048, РФ, Тюменская обл., г. Тюмень, ул. Лопарева, д. 83, офис 4)",
      },
      {
        field: "tphonenumberllct",
        fieldRu: "Телефонный номер (+7 (3452) 533-522)",
      },
      {
        field: "temailllct",
        fieldRu: "Электронная почта (mail@pronogti.studio)",
      },
      {
        field: "togrnllct",
        fieldRu: "ОГРН (1227200017660)",
      },
      {
        field: "tinnllct",
        fieldRu: "ИНН (7203545676)",
      },
      {
        field: "tkppllct",
        fieldRu: "КПП (720301001)",
      },
      {
        field: "trsllct",
        fieldRu: "Расчетный счёт (40702810001500155408)",
      },
      {
        field: "tbankllct",
        fieldRu: 'Название банка (ООО "Банк Точка")',
      },
      {
        field: "tbikllct",
        fieldRu: "БИК (044525104)",
      },
      {
        field: "tksllct",
        fieldRu: "Корреспондетский счёт (30101810745374525104)",
      },
      {
        field: "tdatebirtht",
        fieldRu: "Дата рождения",
      },
      {
        field: "tregistrationt",
        fieldRu: "Прописка мастера",
      },
      {
        field: "tphonenumberworkert",
        fieldRu: "Телефонный номер мастера",
      },
      {
        field: "tseriespassportt",
        fieldRu: "Серия паспорта",
      },
      {
        field: "tnumberpassportt",
        fieldRu: "Номер паспорта",
      },
      {
        field: "tdatepassportt",
        fieldRu: "Дата выдачи паспорта",
      },
      {
        field: "tauthoritypassportt",
        fieldRu: "Орган выдавший паспорт",
      },
      {
        field: "tcodepassportt",
        fieldRu: "Код подразделения",
      },
      {
        field: "tinnworkert",
        fieldRu: "ИНН самозанятого",
      },
      {
        field: "tbikworkert",
        fieldRu: "БИК банка",
      },
      {
        field: "tbankworkert",
        fieldRu: "Название банка",
      },
      {
        field: "trsworkert",
        fieldRu: "Расчетный счёт",
      },
      {
        field: "isignaturellci",
        fieldRu: "Подпись подписанта компании",
      },
      {
        field: "isignatureworkeri",
        fieldRu: "Подпись мастера",
      },
    ],
    texts: [
      {
        placeholder: "number",
        value: "TJM-0001",
      },
      {
        placeholder: "cityname",
        value: "Тюмень",
      },
      {
        placeholder: "dateaccess",
        value: "24 сентября 2025",
      },
      {
        placeholder: "fullnamellc",
        value: 'Общество с Ограниченной Ответственностью "ПроНогти"',
      },
      {
        placeholder: "namellc",
        value: 'ООО "ПроНогти"',
      },
      {
        placeholder: "post",
        value: "Генеральный директор",
      },
      {
        placeholder: "postv",
        value: "Генерального директора",
      },
      {
        placeholder: "fullnamesignatoryv",
        value: "Луговой Марии Васильевны",
      },
      {
        placeholder: "namesignatory",
        value: "Луговая М.В.",
      },
      {
        placeholder: "legalinstrumentr",
        value: "Устава / Доверенности № 01 от 24 сентября 2025 г.",
      },
      {
        placeholder: "subjectfirst",
        value: "Гражданка",
      },
      {
        placeholder: "subjectsecond",
        value: "именуемая",
      },
      {
        placeholder: "fullnameworker",
        value: "Давыдова Виктория Сергеевна",
      },
      {
        placeholder: "nameworker",
        value: "Давыдова В.С.",
      },
      {
        placeholder: "space",
        value: "2",
      },
      {
        placeholder: "spacetxt",
        value: "(два)",
      },
      {
        placeholder: "objectdescription",
        value: "на первом этаже многоквартирного дома",
      },
      {
        placeholder: "cadastralnumber",
        value: "72:23:0000000:9418",
      },
      {
        placeholder: "addressstudio",
        value: "г. Тюмень, бульвар Бориса Щербины, д. 20/2",
      },
      {
        placeholder: "purpose",
        value: "маникюрного сервиса",
      },
      {
        placeholder: "listequipmentone",
        value:
          'Стол – 1 шт.',
      },
      {
        placeholder: "listequipmenttwo",
        value:
        'Стул на колесиках для мастера – 1 шт.',
      },
      {
        placeholder: "listequipmentthree",
        value:
        'Стул для клиента – 1 шт.',
      },
      {
        placeholder: "listequipmentfour",
        value:
        "Пылесос/ вытяжка – 1 шт."
      },
      {
        placeholder: "listequipmentfive",
        value:
        "Аппарат для маникюра и педикюра – 1 шт."
      },
      {
        placeholder: "listequipmentsix",
        value:
        "Лампы для сушки материалов – 2 шт."
      },
      {
        placeholder: "listequipmentseven",
        value:
        "Лампа настольная – 1 шт."
      },
      {
        placeholder: "listequipmenteight",
        value:
        "Набор расходных материалов для маникюра/педикюра – 1 к-т."
      },
      {
        placeholder: "commonareas",
        value: "на первом этаже",
      },
      {
        placeholder: "daterental",
        value: "29.10.2022",
      },
      {
        placeholder: "ownership",
        value: "собственникам на праве долевой собственности",
      },
      {
        placeholder: "registrationnumber",
        value: "72:23:0000000:9418-72/047/2021-7 от 06.09.2021 г.",
      },
      {
        placeholder: "typeservice",
        value: "маникюра",
      },
      {
        placeholder: "rentalcost",
        value: "100",
      },
      {
        placeholder: "rentalcosttxt",
        value: "(сто)",
      },
      {
        placeholder: "reriodicity",
        value: "еженедельно каждый понедельник",
      },
      {
        placeholder: "startwork",
        value: "09:00",
      },
      {
        placeholder: "endwork",
        value: "18:00",
      },
      {
        placeholder: "generalequipment",
        value:
          "сухожары, ультразвуковую мойку, ванночки для обработки инструментов",
      },
      {
        placeholder: "addresslegal",
        value:
          "625048, РФ, Тюменская обл., г. Тюмень, ул. Лопарева, д. 83, офис 4",
      },
      {
        placeholder: "addressactual",
        value:
          "625048, РФ, Тюменская обл., г. Тюмень, ул. Лопарева, д. 83, офис 4",
      },
      {
        placeholder: "phonenumberllc",
        value: "+7 (3452) 533-522",
      },
      {
        placeholder: "emailllc",
        value: "mail@pronogti.studio",
      },
      {
        placeholder: "ogrnllc",
        value: "1227200017660",
      },
      {
        placeholder: "innllc",
        value: "7203545676",
      },
      {
        placeholder: "kppllc",
        value: "720301001",
      },
      {
        placeholder: "rsllc",
        value: "40702810001500155408",
      },
      {
        placeholder: "bankllc",
        value: 'ООО "Банк Точка"',
      },
      {
        placeholder: "bikllc",
        value: "044525104",
      },
      {
        placeholder: "ksllc",
        value: "30101810745374525104",
      },
      {
        placeholder: "datebirth",
        value: "15.03.1990",
      },
      {
        placeholder: "registration",
        value: "г. Тюмень, ул. Республики, д. 15, кв. 42",
      },
      {
        placeholder: "phonenumberworker",
        value: "+7 (912) 345-67-89",
      },
      {
        placeholder: "seriespassport",
        value: "7202",
      },
      {
        placeholder: "numberpassport",
        value: "123456",
      },
      {
        placeholder: "datepassport",
        value: "20.05.2015",
      },
      {
        placeholder: "authoritypassport",
        value:
          "Отделом УФМС России по Тюменской области в Ленинском районе г. Тюмени",
      },
      {
        placeholder: "codepassport",
        value: "720-001",
      },
      {
        placeholder: "innworker",
        value: "123456789012",
      },
      {
        placeholder: "bikworker",
        value: "044525999",
      },
      {
        placeholder: "bankworker",
        value: 'ПАО "Сбербанк"',
      },
      {
        placeholder: "rsworker",
        value: "40802810123456789012",
      },
    ],
    images: [
      {
        placeholder: "signaturellc",
        filename: "signature.png",
        widthSm: 2,
        heightSm: 0.66,
        imageNumber: 1001,
      },
      {
        placeholder: "signatureworker",
        filename: "signature.png",
        widthSm: 2,
        heightSm: 0.66,
        imageNumber: 1002,
      },
    ],
    stamps: [
      {
        pageNum: 3,
        horizontal: "right",
        vertical: "bottom",
        offsetX: 120,
        offsetY: 40,
      },
      {
        pageNum: 4,
        horizontal: "left",
        vertical: "bottom",
        offsetX: 10,
        offsetY: 40,
      },
      {
        pageNum: 5,
        horizontal: "right",
        vertical: "top",
        offsetX: 40,
        offsetY: 40,
      },
    ],
  },
  workplace_transfer_act_nail: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  workplace_return_act_nail: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  workplace_rent_brow_master: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  workplace_transfer_act_brow: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  workplace_return_act_brow: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  agent_agreement: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  agent_compensation_policy: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  agent_report: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  service_act: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
  agent_termination_notice: {
    fields: [],
    texts: [],
    images: [],
    stamps: [],
  },
}

export default docxFields
