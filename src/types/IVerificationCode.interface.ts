interface IVerificationCode {
  id: number;
  user_id: number;
  type: "phone" | "email";
  value: string;
  code: string;
  expires_at: Date;
  is_used: boolean;
  created_at: Date;
}

export default IVerificationCode;
