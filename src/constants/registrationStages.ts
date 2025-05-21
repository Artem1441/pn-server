const registrationStages = {
  accessionAgreement: "accession agreement",
  identificationData: "identification data",
  personalData: "personal data",
  waitingRoom: "waiting room"
} as const;

type RegistrationStageKeys = keyof typeof registrationStages;

type StageType = (typeof registrationStages)[RegistrationStageKeys];

export type { RegistrationStageKeys, StageType };

export default registrationStages;
