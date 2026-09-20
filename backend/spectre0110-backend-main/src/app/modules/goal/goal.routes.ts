import express from "express";
import auth from "../../middlewares/auth";
import { goalControllers } from "./goal.controller";
import validateRequest from "../../middlewares/validateRequest";
import { goalValidation } from "./goal.validation";

const router = express.Router();

router.post("/weight/create", auth(), goalControllers.createWeightGoal);
router.get("/weight/goals", auth(), goalControllers.getWeightGoals);
router.post(
  "/weight/log",
  auth(),
  validateRequest(goalValidation.logWeightSchema),
  goalControllers.logWeight
);
router.get("/weight/history", auth(), goalControllers.weightHistory);
router.get("/weight/:weightId", auth(), goalControllers.singleWeightGoal);
router.patch("/weight/:weightId", auth(), goalControllers.updateWeightGoal);
router.delete("/weight/:weightId", auth(), goalControllers.deleteWeightGoal);

router.post(
  "/water-intake",
  auth(),
  validateRequest(goalValidation.createWaterIntakeSchema),
  goalControllers.createWaterIntake
);
router.get("/water-intake/goal", auth(), goalControllers.getWaterIntakeGoal);

export const goalRoute = router;
