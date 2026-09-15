import catchAsync from "../../../shared/catchAsync";
import sendResponse from "../../../shared/sendResponse";
import { appointmentServices } from "./appointment.service";

const createAppointment = catchAsync(async (req, res) => {
  const result = await appointmentServices.createAppointmentInDB(
    req.body,
    req.user.id,
    req.params.hospitalId
  );

  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Appointment created successfully",
    data: result,
  });
});

const myAppointments = catchAsync(async (req, res) => {
  const appointments = await appointmentServices.myAppointmentsFromDB(req);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "My appointments fetched successfully",
    data: appointments,
  });
});

const allAppointments = catchAsync(async (req, res) => {
  const appointments = await appointmentServices.allAppointmentsFromDB(req);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "All appointments fetched successfully",
    data: appointments,
  });
});

const getAppointment = catchAsync(async (req, res) => {
  const appointment = await appointmentServices.singleAppointmentFromDB(
    req.params.appointmentId,
    req.user.id,
    req.user.role
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Appointment fetched successfully",
    data: appointment,
  });
});

const updateAppointment = catchAsync(async (req, res) => {
  const updatedAppointment = await appointmentServices.updateAppointmentInDB(
    req.params.appointmentId,
    req.user.id,
    req.user.role,
    req.body
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Appointment updated successfully",
    data: updatedAppointment,
  });
});

const deleteAppointment = catchAsync(async (req, res) => {
  await appointmentServices.deleteAppointment(
    req.params.appointmentId,
    req.user.id,
    req.user.role
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Appointment deleted successfully",
  });
});

export const appointmentControllers = {
  createAppointment,
  myAppointments,
  allAppointments,
  getAppointment,
  updateAppointment,
  deleteAppointment,
};
