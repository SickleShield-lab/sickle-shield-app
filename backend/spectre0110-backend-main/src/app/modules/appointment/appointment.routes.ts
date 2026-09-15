import { UserRole } from "@prisma/client";
import express from "express";
import auth from "../../middlewares/auth";
import { appointmentControllers } from "./appointment.controller";

const router = express.Router();

router.post(
  "/create/:hospitalId",
  auth(UserRole.USER, UserRole.ADMIN),
  appointmentControllers.createAppointment
);
router.get("/my-appointments", auth(), appointmentControllers.myAppointments);
router.get(
  "/all-appointments",
  auth(UserRole.ADMIN),
  appointmentControllers.allAppointments
);
router.get("/:appointmentId", auth(), appointmentControllers.getAppointment);
router.patch(
  "/:appointmentId",
  auth(),
  appointmentControllers.updateAppointment
);
router.delete(
  "/:appointmentId",
  auth(),
  appointmentControllers.deleteAppointment
);

export const appointmentRoute = router;
