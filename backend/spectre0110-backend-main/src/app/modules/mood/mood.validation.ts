import { z } from "zod";

const logMoodSchema = z.object({
  mood: z.enum(["great", "good", "okay", "low", "struggling"]),
  note: z.string().max(500).optional(),
});

export const moodValidation = {
  logMoodSchema,
};
