import express from "express";
import auth from "../../middlewares/auth";
import validateRequest from "../../middlewares/validateRequest";
import { moodControllers } from "./mood.controller";
import { moodValidation } from "./mood.validation";

const router = express.Router();

router.post(
  "/log",
  auth(),
  validateRequest(moodValidation.logMoodSchema),
  moodControllers.logMood
);
router.get("/my-moods", auth(), moodControllers.myMoods);

export const moodRoute = router;
