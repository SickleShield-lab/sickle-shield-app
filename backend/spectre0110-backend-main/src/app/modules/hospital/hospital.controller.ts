import catchAsync from "../../../shared/catchAsync";
import sendResponse from "../../../shared/sendResponse";
import { hospitalServices } from "./hospital.service";

const createHospital = catchAsync(async (req, res) => {
  const resource = await hospitalServices.createHospitalInDB(
    req.body,
    req.user.id
  );
  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Hospital created successfully",
    data: resource,
  });
});

const allHospitals = catchAsync(async (req, res) => {
  const hospitals = await hospitalServices.getHospitalsFromDB(
    req.query,
    req.user.id
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "My hospitals fetched successfully",
    data: hospitals,
  });
});

const singleHospital = catchAsync(async (req, res) => {
  const hospital = await hospitalServices.getHospitalById(
    req.params.hospitalId
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Hospital fetched successfully",
    data: hospital,
  });
});

const updateHospital = catchAsync(async (req, res) => {
  const updatedHospital = await hospitalServices.updateHospitalInDB(req);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Hospital updated successfully",
    data: updatedHospital,
  });
});

const deleteHospital = catchAsync(async (req, res) => {
  await hospitalServices.deleteHospitalFromDB(
    req.params.hospitalId,
    req.user.id,
    req.user.role
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Hospital deleted successfully",
  });
});

const createEmergencyContact = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const resource = await hospitalServices.createEmergencyContact(
    userId,
    req.body
  );
  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Emergency contact created successfully",
    data: resource,
  });
});

const deleteContact = catchAsync(async (req, res) => {
  await hospitalServices.deleteContact(req.params.contactId, req.user.id);
  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Emergency contact deleted successfully",
  });
});

const emergencyContacts = catchAsync(async (req, res) => {
  const contacts = await hospitalServices.emergencyContacts(
    req.user.id,
    req.query
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "My emergency contacts fetched successfully",
    data: contacts,
  });
});

export const hospitalControllers = {
  createHospital,
  allHospitals,
  singleHospital,
  updateHospital,
  deleteHospital,
  createEmergencyContact,
  emergencyContacts,
  deleteContact,
};
