import express from "express";
import auth from "../../middlewares/auth";
import { hospitalControllers } from "./hospital.controller";
import { fileUploader } from "../../../helpers/fileUploader";
import { parseBodyData } from "../../middlewares/parseBodyData";

const router = express.Router();

router.post("/create", auth(), hospitalControllers.createHospital);
router.get("/all", auth(), hospitalControllers.allHospitals);
router.get("/:hospitalId", hospitalControllers.singleHospital);
router.patch(
  "/:hospitalId",
  auth(),
  fileUploader.uploadMultiple,
  parseBodyData,
  hospitalControllers.updateHospital
);
router.delete("/:hospitalId", auth(), hospitalControllers.deleteHospital);
router.post(
  "/emergency-contact/create",
  auth(),
  hospitalControllers.createEmergencyContact
);
router.delete(
  "/emergency-contact/delete/:contactId",
  auth(),
  hospitalControllers.deleteContact
);
router.get(
  "/emergency/contacts",
  auth(),
  hospitalControllers.emergencyContacts
);

export const hospitalRoute = router;
