import express from "express";
import { notificationController } from "./notification.controller";
import auth from "../../middlewares/auth";
import validateRequest from "../../middlewares/validateRequest";
import { notificationValidation } from "./notification.validation";

const router = express.Router();

router.get("/", auth(), notificationController.getNotifications);
router.post(
  "/",
  auth(),
  validateRequest(notificationValidation.createNotificationSchema),
  notificationController.createNotification
);
router.get(
  "/:notificationId",
  auth(),
  notificationController.getSingleNotificationById
);

export const notificationsRoute = router;
