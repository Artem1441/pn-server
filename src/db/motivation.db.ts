import { Motivation } from "../models/Motivation.model";
import IMotivation from "../types/IMotivation.interface";

export const getMotivation = async (): Promise<IMotivation> => {
  try {
    const motivation = await Motivation.findOne();
    if (!motivation) return await Motivation.create(getDefaultMotivation());
    return motivation;
  } catch (error) {
    console.error("Ошибка при получении мотивации:", error);
    throw null;
  }
};

export const updateMotivation = async (
  {
    id,
    allowance_data, 
    deduction_data
  }: {
    id: IMotivation["id"]
    allowance_data: IMotivation["allowance_data"]
    deduction_data: IMotivation["deduction_data"]
  }
): Promise<void> => {
  try {
    const motivation = await Motivation.findByPk(id);
    if (!motivation) throw null;
    motivation.allowance_data = allowance_data;
    motivation.deduction_data = deduction_data;

    await motivation.save();
  } catch (error) {
    console.error("Ошибка при обновлении мотивации:", error);
    throw null;
  }
};

const getDefaultMotivation = (): Partial<IMotivation> => ({
  allowance_data: [],
  deduction_data: []
});
