import { z } from "zod";

const createNotificationSchema = z.object({
  title: z.string().min(1, "title is required"),
  body: z.string().min(1, "body is required"),
});

export const notificationValidation = {
  createNotificationSchema,
};
