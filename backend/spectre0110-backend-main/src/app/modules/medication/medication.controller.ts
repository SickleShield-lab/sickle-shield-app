import { Days } from "@prisma/client";
import catchAsync from "../../../shared/catchAsync";
import sendResponse from "../../../shared/sendResponse";
import { medicationServices } from "./medication.service";

const createMedication = catchAsync(async (req, res) => {
  const result = await medicationServices.createMedicationInDB(
    req.user.id,
    req.body
  );

  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Medication created successfully",
    data: result,
  });
});

const singleMedication = catchAsync(async (req, res) => {
  const medication = await medicationServices.getMedicationFromDB(
    req.params.medicationId,
    req.user.id
  );

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Medication fetched successfully",
    data: medication,
  });
});

const myMedications = catchAsync(async (req, res) => {
  const { day } = req.query;
  console.log(day);
  const medications = await medicationServices.myMedicationsFromDB(
    req.user.id,
    day as Days
  );

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "All medications fetched successfully",
    data: medications,
  });
});

const updateMedication = catchAsync(async (req, res) => {
  const updatedMedication = await medicationServices.updateMedicationInDB(
    req.params.medicationId,
    req.user.id,
    req.body
  );

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Medication updated successfully",
    data: updatedMedication,
  });
});

const deleteMedication = catchAsync(async (req, res) => {
  const userId = req.user.id;
  await medicationServices.deleteMedicationFromDB(
    req.params.medicationId,
    userId
  );

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Medication deleted successfully",
  });
});

const uploadReport = catchAsync(async (req, res) => {
  await medicationServices.uploadReport(req);

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Report uploaded successfully",
  });
});

const myReports = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const reports = await medicationServices.myReports(userId);

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Report retrived successfully",
    data: reports,
  });
});

const createReminder = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const reports = await medicationServices.createReminder(userId, req.body);

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Reminder created successfully",
    data: reports,
  });
});

const deleteReminder = catchAsync(async (req, res) => {
  const { reminderId } = req.params;
  await medicationServices.deleteReminder(reminderId, req.user.id);

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Reminder deleted successfully",
  });
});

const deleteReport = catchAsync(async (req, res) => {
  const { reportId } = req.params;
  await medicationServices.deleteReport(reportId, req.user.id);

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Report deleted successfully",
  });
});

const myReminders = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const reminders = await medicationServices.myReminders(userId, req.query);

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Reminders retrived successfully",
    data: reminders,
  });
});

const mySingleReminder = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const { reminderId } = req.params;
  const reminders = await medicationServices.mySingleReminder(
    userId,
    reminderId
  );

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Reminder retrived successfully",
    data: reminders,
  });
});

export const medicationController = {
  createMedication,
  singleMedication,
  myMedications,
  updateMedication,
  deleteMedication,
  uploadReport,
  myReports,
  createReminder,
  myReminders,
  mySingleReminder,
  deleteReminder,
  deleteReport,
};
