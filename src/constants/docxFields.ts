import DocumentType from "../types/DocumentType.type";
import { IDocxFields } from "../types/IDocx.interface";

const docxFields: Record<DocumentType, IDocxFields> = {
  accession_agreement: {
    fields: [],
    texts: [],
    images: [],
  },
  accession_application: {
    fields: [],
    texts: [],
    images: [],
  },
  workplace_rent_nail_master: {
    fields: [
      {
        field: "tdayt",
        fieldRu: "День документа (10)",
      },
      {
        field: "tmontht",
        fieldRu: "Месяц документа (августа)",
      },
      {
        field: "tyeart",
        fieldRu: "Год документа (2025)",
      },
      {
        field: "tfullnamet",
        fieldRu: "Полное имя (Иванов Иван Иванович)",
      },
      {
        field: "tdocnumbert",
        fieldRu: "Номер документа (123)",
      },
      {
        field: "tbirthdatet",
        fieldRu: "Дата рождения (01.01.2000)",
      },
      {
        field: "taddressregt",
        fieldRu:
          "Адрес регистрации (Калужская область, г. Калуга, ул. Ленина, д. 1, кв. 12)",
      },
      {
        field: "tphonet",
        fieldRu: "Телефон (+79999999999)",
      },
      {
        field: "tseriest",
        fieldRu: "Серия паспорта (4500)",
      },
      {
        field: "tnumbert",
        fieldRu: "Номер паспорта (123456)",
      },
      {
        field: "tissuedatet",
        fieldRu: "Дата выдачи паспорта (10.10.2015)",
      },
      {
        field: "tissuedbyt",
        fieldRu:
          "Кем выдан паспорт (Отделом УФМС России по Калужской области в г. Калуге)",
      },
      {
        field: "tinnt",
        fieldRu: "ИНН (771234567890)",
      },
      {
        field: "tbikt",
        fieldRu: "БИК (044525225)",
      },
      {
        field: "tacct",
        fieldRu: "Номер счета (40817810099910000001)",
      },
    ],
    texts: [
      {
        placeholder: "day",
        value: "10",
      },
      {
        placeholder: "month",
        value: "августа",
      },
      {
        placeholder: "year",
        value: "2025",
      },
      {
        placeholder: "fullname",
        value: "Иванов Иван Иванович",
      },
      {
        placeholder: "docnumber",
        value: "123",
      },
      {
        placeholder: "birthdate",
        value: "01.01.2000",
      },
      {
        placeholder: "addressreg",
        value: "Калужская область, г. Калуга, ул. Ленина, д. 1, кв. 12",
      },
      {
        placeholder: "phone",
        value: "+79999999999",
      },
      {
        placeholder: "series",
        value: "4500",
      },
      {
        placeholder: "number",
        value: "123456",
      },
      {
        placeholder: "issuedate",
        value: "10.10.2015",
      },
      {
        placeholder: "issuedby",
        value: "Отделом УФМС России по Калужской области в г. Калуге",
      },
      {
        placeholder: "inn",
        value: "771234567890",
      },
      {
        placeholder: "bik",
        value: "044525225",
      },
      {
        placeholder: "acc",
        value: "40817810099910000001",
      },
    ],
    images: [
      {
        placeholder: "tenantsignature",
        filename: "signature.png",
        widthSm: 3,
        heightSm: 1,
        imageNumber: 1001,
      },
      {
        placeholder: "landlordsignature",
        filename: "signature.png",
        widthSm: 3,
        heightSm: 1,
        imageNumber: 1002,
      },
    ],
  },
  workplace_transfer_act_nail: {
    fields: [],
    texts: [],
    images: [],
  },
  workplace_return_act_nail: {
    fields: [],
    texts: [],
    images: [],
  },
  workplace_rent_brow_master: {
    fields: [],
    texts: [],
    images: [],
  },
  workplace_transfer_act_brow: {
    fields: [],
    texts: [],
    images: [],
  },
  workplace_return_act_brow: {
    fields: [],
    texts: [],
    images: [],
  },
  agent_agreement: {
    fields: [],
    texts: [],
    images: [],
  },
  agent_compensation_policy: {
    fields: [],
    texts: [],
    images: [],
  },
  agent_report: {
    fields: [],
    texts: [],
    images: [],
  },
  service_act: {
    fields: [],
    texts: [],
    images: [],
  },
  agent_termination_notice: {
    fields: [],
    texts: [],
    images: [],
  },
};

export default docxFields;
