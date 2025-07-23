const extensionsToMime: Record<string, string> = {
  // Изображения
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
  png: "image/png",
  gif: "image/gif",
  webp: "image/webp",

  // Документы
  pdf: "application/pdf",
  doc: "application/msword",
  docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  xls: "application/vnd.ms-excel",
  xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  ppt: "application/vnd.ms-powerpoint",
  pptx: "application/vnd.openxmlformats-officedocument.presentationml.presentation",
  txt: "text/plain",

  // Архивы
  zip: "application/zip",
  rar: "application/x-rar-compressed",

  // Прочее
  json: "application/json",
  xml: "application/xml",
};

export default extensionsToMime;
