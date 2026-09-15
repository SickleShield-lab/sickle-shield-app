import { z } from "zod";

const createWaterIntakeSchema = z.object({
  amount: z
    .number()
    .min(1, "water intake minimum 1 glass")
    .max(10, "water intake maximum 10 glasses"),
});

export const goalValidation = {
  createWaterIntakeSchema,
};
