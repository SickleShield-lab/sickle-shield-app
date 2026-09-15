import express from "express";
import { userRoutes } from "../modules/user/user.route";
import { authRoute } from "../modules/auth/auth.routes";
import { resourceRoute } from "../modules/resource/resource.routes";
import { hospitalRoute } from "../modules/hospital/hospital.routes";
import { appointmentRoute } from "../modules/appointment/appointment.routes";
import { medicationRoute } from "../modules/medication/medication.routes";
import { symtomsRoute } from "../modules/symptoms/symptoms.routes";
import { painRoute } from "../modules/pain/pain.routes";
import { goalRoute } from "../modules/goal/goal.routes";
import { notificationsRoute } from "../modules/notifications/notification.route";

const router = express.Router();

const moduleRoutes = [
  {
    path: "/users",
    route: userRoutes,
  },

  {
    path: "/auth",
    route: authRoute,
  },
  {
    path: "/resource",
    route: resourceRoute,
  },
  {
    path: "/hospital",
    route: hospitalRoute,
  },
  {
    path: "/appointment",
    route: appointmentRoute,
  },
  {
    path: "/medication",
    route: medicationRoute,
  },
  {
    path: "/symptoms",
    route: symtomsRoute,
  },
  {
    path: "/pain",
    route: painRoute,
  },
  {
    path: "/goal",
    route: goalRoute,
  },
  {
    path: "/notifications",
    route: notificationsRoute,
  },
];

moduleRoutes.forEach((route) => router.use(route.path, route.route));

export default router;
