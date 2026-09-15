import { Days } from "@prisma/client";
import catchAsync from "../../../shared/catchAsync";
import sendResponse from "../../../shared/sendResponse";
import { symptomsServices } from "./symptoms.service";

const createSymptom = catchAsync(async (req, res) => {
  const result = await symptomsServices.createsymptomsInDB(
    req.user.id,
    req.body
  );

  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Symptoms created successfully",
    data: result,
  });
});

const singleSymptom = catchAsync(async (req, res) => {
  const symptom = await symptomsServices.getsymptomsFromDB(
    req.params.symptomId,
    req.user.id
  );

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Symptoms fetched successfully",
    data: symptom,
  });
});

const mySymptoms = catchAsync(async (req, res) => {
  const { day } = req.query;
  const symptoms = await symptomsServices.mysymptomsFromDB(
    req.user.id,
    day as Days
  );

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "All symptoms fetched successfully",
    data: symptoms,
  });
});

const updateSymptom = catchAsync(async (req, res) => {
  const updatedSymptom = await symptomsServices.updatesymptomsInDB(
    req.params.symptomId,
    req.user.id,
    req.body
  );

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Symptoms updated successfully",
    data: updatedSymptom,
  });
});

const deleteSymptom = catchAsync(async (req, res) => {
  const userId = req.user.id;
  await symptomsServices.deletesymptomsFromDB(req.params.symptomId, userId);

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Symptoms deleted successfully",
  });
});

export const symptomsController = {
  createSymptom,
  singleSymptom,
  mySymptoms,
  updateSymptom,
  deleteSymptom,
};
