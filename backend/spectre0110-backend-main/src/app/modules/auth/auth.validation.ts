import { z } from "zod";

const authLoginSchema = z.object({
  email: z.string().email("Invalid email address"),
});

const updateProfileSchema = z.object({
  username: z
    .string()
    .min(2, "user name must be at least 2 characters long")
    .optional(),
  password: z
    .string()
    .min(8, "Password must be at least 8 characters long")
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/,
      "Password must include at least one uppercase letter, one lowercase letter, one number, and one special character"
    )
    .optional(),
  lang: z.string().min(2, "lang must be at least 2 characters long").optional(),
  gender: z
    .string()
    .min(2, "gender must be at least 2 characters long")
    .optional(),
  diagnosis: z
    .string()
    .min(2, "diagnosis must be at least 2 characters long")
    .optional(),
  weight: z
    .string()
    .min(2, "weight must be at least 2 characters long")
    .optional(),
  bloodGroup: z
    .string()
    .min(2, "bloodGroup must be at least 2 characters long")
    .optional(),
  painManager: z
    .string()
    .min(2, "painManager must be at least 2 characters long")
    .optional(),
  waterIntake: z
    .number()
    .min(1, "water intake min 1 digit")
    .max(10, "water intake maximum 10 digits")
    .optional(),
  mobileNumber: z
    .string()
    .min(10, "Mobile Number at least 10 Digit long")
    .optional(),
  smoking: z.boolean().optional(),
});

export const authValidation = {
  updateProfileSchema,
  authLoginSchema,
};
