import { z } from "zod";

const userRegisterValidationSchema = z.object({
  username: z
    .string()
    .min(2, "username name must be at least 2 characters long"),
  email: z.string().email("Invalid email address"),
  fcmToken: z.string().min(10, "FCM Token at least 10 digit long"),
  password: z.string().min(8, "Password must be at least 8 characters long"),
});

const userUpdateValidationSchema = z.object({
  firstName: z
    .string()
    .min(2, "First name must be at least 2 characters long")
    .optional(),
  lastName: z
    .string()
    .min(2, "Last name must be at least 2 characters long")
    .optional(),
  mobile: z.string().min(10, "Mobile Number at least 10 Digit long").optional(),
  role: z.enum(["ADMIN", "USER"]).optional(),
  status: z.enum(["ACTIVE", "BLOCKED", "DELETED"]).optional(),
});

export const userValidation = {
  userRegisterValidationSchema,
  userUpdateValidationSchema,
};
