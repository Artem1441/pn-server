export default interface IResp<T> {
  status: boolean;
  data?: T;
  error?: string;
}
