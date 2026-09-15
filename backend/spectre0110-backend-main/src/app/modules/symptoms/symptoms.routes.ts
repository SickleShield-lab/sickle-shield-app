import express from "express";
import auth from "../../middlewares/auth";
import { symptomsController } from "./symptoms.controller";

const router = express.Router();

router.post("/create", auth(), symptomsController.createSymptom);
router.get("/:symptomId", auth(), symptomsController.singleSymptom);
router.get("/my/symptoms", auth(), symptomsController.mySymptoms);
router.patch("/:symptomId", auth(), symptomsController.updateSymptom);
router.delete("/:symptomId", auth(), symptomsController.deleteSymptom);

export const symtomsRoute = router;
