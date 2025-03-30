interface IResp<T> {
  status: boolean;
  data?: T;
  error?: string;
}

export default IResp;
