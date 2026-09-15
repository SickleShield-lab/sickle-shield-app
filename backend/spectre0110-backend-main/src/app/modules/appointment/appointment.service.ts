import { Appointment } from "@prisma/client";
import prisma from "../../../shared/prisma";
import { paginationHelper } from "../../../shared/pagination";
import { Request } from "express";
import { appointmentFilter } from "../../../shared/appointmentFilter";
import ApiError from "../../../errors/ApiErrors";
import {
  oneSignalNotify,
  sendSingleNotification,
} from "../notifications/notification.services";

//create a new appointment
const createAppointmentInDB = async (
  payload: Appointment,
  userId: string,
  hospitalId: string
) => {
  const existingUser = await prisma.user.findUnique({ where: { id: userId } });
  if (!existingUser) {
    throw new ApiError(404, "User not found");
  }

  const hospitalInfo = await prisma.hospital.findUnique({
    where: {
      id: hospitalId,
    },
  });
  if (!hospitalInfo) {
    throw new ApiError(404, "Hospital Not Found!");
  }
  const result = await prisma.appointment.create({
    data: {
      ...payload,
      userId,
      hospitalId,
    },
  });

  await oneSignalNotify(
    userId,
    `Appointment Request Created for ${hospitalInfo.hospitalName} Successfully`,
    "Appointment Request Created Successfully"
  );

  return result;
};

// Get my appointments with pagination and search
const myAppointmentsFromDB = async (req: Request) => {
  const userId = req.user.id;
  const { page, limit, take, skip } = paginationHelper(req.query as any);

  const appointments = await prisma.appointment.findMany({
    where: { userId },
    skip,
    take,
    orderBy: { createdAt: "desc" },
  });

  const totalCount = await prisma.appointment.count({ where: { userId } });
  const totalPages = Math.ceil(totalCount / limit);

  return {
    totalCount,
    totalPages,
    currentPage: page,
    appointments,
  };
};

// Get all appointments with pagination and search
const allAppointmentsFromDB = async (req: Request) => {
  const { page, limit, take, skip, search } = paginationHelper(
    req.query as any
  );

  const searchFilter = search ? appointmentFilter(search) : {};

  const appointments = await prisma.appointment.findMany({
    where: searchFilter,
    skip,
    take,
    orderBy: { createdAt: "desc" },
  });

  const totalCount = await prisma.appointment.count({ where: searchFilter });
  const totalPages = Math.ceil(totalCount / limit);

  return {
    totalCount,
    totalPages,
    currentPage: page,
    appointments,
  };
};

// Get a specific appointment
const singleAppointmentFromDB = async (
  appointmentId: string,
  userId: string,
  role: string
) => {
  const appointment = await prisma.appointment.findUnique({
    where: { id: appointmentId },
  });
  if (!appointment || (appointment.userId !== userId && role !== "ADMIN")) {
    throw new ApiError(404, "Appointment not found");
  }
  return appointment;
};

// Update an appointment
const updateAppointmentInDB = async (
  appointmentId: string,
  userId: string,
  role: string,
  payload: Partial<Appointment>
) => {
  const appointment = await prisma.appointment.findUnique({
    where: { id: appointmentId },
  });
  if (!appointment || (appointment.userId !== userId && role !== "ADMIN")) {
    throw new ApiError(404, "Appointment not found");
  }
  const result = await prisma.appointment.update({
    where: { id: appointmentId },
    data: payload,
  });

  return result;
};

// Delete an appointment
const deleteAppointment = async (
  appointmentId: string,
  userId: string,
  role: string
) => {
  const appointment = await prisma.appointment.findUnique({
    where: { id: appointmentId },
  });
  if (!appointment || (appointment.userId !== userId && role !== "ADMIN")) {
    throw new ApiError(404, "Appointment not found for delete");
  }
  await prisma.appointment.delete({
    where: { id: appointmentId },
  });

  return;
};

export const appointmentServices = {
  createAppointmentInDB,
  myAppointmentsFromDB,
  allAppointmentsFromDB,
  singleAppointmentFromDB,
  updateAppointmentInDB,
  deleteAppointment,
};
