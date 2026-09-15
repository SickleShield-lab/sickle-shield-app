import express from "express";
import auth from "../../middlewares/auth";
import { painControllers } from "./pain.controller";
import validateRequest from "../../middlewares/validateRequest";
import { painValidation } from "./pain.validation";

const router = express.Router();

router.post(
  "/create",
  auth(),
  validateRequest(painValidation.createPainSchema),
  painControllers.createPain
);
router.get("/:painId", auth(), painControllers.singlePain);
router.get("/my/pains", auth(), painControllers.allPains);
router.patch("/:painId", auth(), painControllers.updatePain);
router.delete("/:painId", auth(), painControllers.deletePain);

export const painRoute = router;
