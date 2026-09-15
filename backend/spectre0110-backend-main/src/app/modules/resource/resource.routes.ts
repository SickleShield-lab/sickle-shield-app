import { UserRole } from "@prisma/client";
import express from "express";
import auth from "../../middlewares/auth";
import { resourceControllers } from "./resource.controller";
import { fileUploader } from "../../../helpers/fileUploader";
import { parseBodyData } from "../../middlewares/parseBodyData";

const router = express.Router();

router.post(
  "/create",
  auth(UserRole.ADMIN),
  fileUploader.uploadMultiple,
  parseBodyData,
  resourceControllers.createResource
);
router.get("/all", auth(), resourceControllers.allResources);
router.get("/:resourceId", auth(), resourceControllers.singleResource);
router.delete("/:resourceId", auth(UserRole.ADMIN), resourceControllers.deleteResource);

export const resourceRoute = router;
