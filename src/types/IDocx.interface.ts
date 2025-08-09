import DocumentType from "./DocumentType.type"

export default interface IDocx {
  id: number
  file_key: string
  file_type: DocumentType
  fields?: IDocxFieldsField[]
  created_at: Date
  updated_at: Date
}

export interface IDocxFields {
  fields: IDocxFieldsField[]
  texts: IDocxFieldsText[]
  images: IDocxFieldsImage[]
  stamps: IDocxStamp[]
}

export interface IDocxFieldsField {
  field: string
  fieldRu: string
}

export interface IDocxFieldsText {
  placeholder: string
  value: string
}
export interface IDocxFieldsImage {
  placeholder: string
  filename: string
  widthSm: number
  heightSm: number
  imageNumber: number
}
export interface IDocxStamp {
  pageNum: number
  horizontal: "left" | "right" | "center"
  vertical: "top" | "bottom" | "center"
  offsetX: number
  offsetY: number
}
