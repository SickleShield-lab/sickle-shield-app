import { z } from "zod";

const createPainSchema = z.object({
  pain: z.string().min(2, "Pain must be at least 2 characters long").optional(),
  sensation: z
    .string()
    .min(2, "Sensation must be at least 2 characters long")
    .optional(),
  frequency: z
    .string()
    .min(2, "frequency must be at least 2 characters long")
    .optional(),
  rating: z
    .number()
    .min(1, "Rating minimum 1 digit")
    .max(10, "Rating maximum 10 digits"),
});

export const painValidation = {
  createPainSchema,
};
