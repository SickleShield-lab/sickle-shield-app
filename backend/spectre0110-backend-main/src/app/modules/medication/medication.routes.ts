import express from "express";
import auth from "../../middlewares/auth";
import { medicationController } from "./medication.controller";
import { fileUploader } from "../../../helpers/fileUploader";
import { parseBodyData } from "../../middlewares/parseBodyData";

const router = express.Router();

router.post("/create", auth(), medicationController.createMedication);
router.get("/:medicationId", auth(), medicationController.singleMedication);
router.get("/my/medications", auth(), medicationController.myMedications);
router.patch("/:medicationId", auth(), medicationController.updateMedication);
router.delete("/:medicationId", auth(), medicationController.deleteMedication);
router.post(
  "/report/upload",
  auth(),
  fileUploader.reportFile,
  parseBodyData,
  medicationController.uploadReport
);
router.get("/reports/my-reports", auth(), medicationController.myReports);
router.post("/reminder/create", auth(), medicationController.createReminder);
router.get("/reminders/my-reminders", auth(), medicationController.myReminders);
router.delete(
  "/reminders/:reminderId",
  auth(),
  medicationController.deleteReminder
);
router.delete("/reports/:reportId", auth(), medicationController.deleteReport);
router.get(
  "/reminders/my-reminder/:reminderId",
  auth(),
  medicationController.mySingleReminder
);

export const medicationRoute = router;
