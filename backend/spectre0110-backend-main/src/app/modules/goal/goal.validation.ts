import { z } from "zod";

const createWaterIntakeSchema = z.object({
  amount: z
    .number()
    .min(1, "water intake minimum 1 glass")
    .max(10, "water intake maximum 10 glasses"),
});

const logWeightSchema = z.object({
  weight: z
    .number()
    .positive("weight must be a positive number")
    .max(1000, "weight seems too high"),
});

export const goalValidation = {
  createWaterIntakeSchema,
  logWeightSchema,
};
