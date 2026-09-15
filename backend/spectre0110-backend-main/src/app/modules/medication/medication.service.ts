import { Days, Medication, Reminder } from "@prisma/client";
import prisma from "../../../shared/prisma";
import ApiError from "../../../errors/ApiErrors";
import { Request } from "express";
import { uploadInSpace } from "../../../shared/uploadInSpace";
import {
  startOfDay,
  endOfDay,
  startOfWeek,
  endOfWeek,
  startOfMonth,
  endOfMonth,
} from "date-fns";

//create medication
const createMedicationInDB = async (userId: string, payload: Medication) => {
  const existingUser = await prisma.user.findUnique({ where: { id: userId } });
  if (!existingUser) {
    throw new ApiError(404, "User not found");
  }

  const existingMedication = await prisma.medication.findFirst({
    where: {
      title: payload.title,
      userId,
      day: payload.day,
    },
  });
  if (existingMedication) {
    throw new ApiError(409, "Medication already exists");
  }
  const result = await prisma.medication.create({
    data: {
      ...payload,
      userId,
    },
  });

  return result;
};

// Get a medication by id
const getMedicationFromDB = async (medicationId: string, userId: string) => {
  const result = await prisma.medication.findUnique({
    where: {
      id: medicationId,
      userId,
    },
  });
  if (!result) {
    throw new ApiError(404, "Medication not found");
  }

  return result;
};

// Get all medications for a user
const myMedicationsFromDB = async (userId: string, day: Days) => {
  const result = await prisma.medication.findMany({
    where: {
      userId,
      day,
    },
  });

  return result;
};

// Update a medication
const updateMedicationInDB = async (
  medicationId: string,
  userId: string,
  payload: Medication
) => {
  const result = await prisma.medication.update({
    where: {
      id: medicationId,
      userId,
    },
    data: {
      ...payload,
    },
  });

  return result;
};

// Delete a medication
const deleteMedicationFromDB = async (medicationId: string, userId: string) => {
  const user = await prisma.user.findUnique({
    where: {
      id: userId,
    },
  });
  if (!user) {
    throw new ApiError(404, "User not found");
  }

  const medication = await prisma.medication.findUnique({
    where: {
      id: medicationId,
    },
  });

  if (!medication) {
    throw new ApiError(404, "Medication not found");
  }

  await prisma.medication.delete({
    where: {
      id: medicationId,
      userId,
    },
  });

  return;
};

// upload report
const uploadReport = async (req: Request) => {
  const userId = req.user.id;
  const file = req.file as Express.Multer.File;
  const payload = req.body;

  const reportFile = await uploadInSpace(file, "/report");

  await prisma.report.create({
    data: {
      ...payload,
      reportFile,
      userId,
    },
  });
};

// get report
const myReports = async (userId: string) => {
  const reports = await prisma.report.findMany({
    where: {
      userId,
    },
  });

  return reports;
};

const deleteReport = async (reportId: string, userId: string) => {
  const report = await prisma.report.findUnique({ where: { id: reportId } });
  if (!report || report.userId !== userId) {
    throw new ApiError(404, "Report not found");
  }
  await prisma.report.delete({
    where: {
      id: reportId,
    },
  });

  return;
};

// create reminder
const createReminder = async (userId: string, payload: Reminder) => {
  await prisma.reminder.create({
    data: {
      ...payload,
      userId,
    },
  });
};

const deleteReminder = async (reminderId: string, userId: string) => {
  const reminder = await prisma.reminder.findUnique({
    where: { id: reminderId },
  });
  if (!reminder || reminder.userId !== userId) {
    throw new ApiError(404, "Reminder not found");
  }
  await prisma.reminder.delete({
    where: {
      id: reminderId,
    },
  });
  return;
};

// my reminders
const myReminders = async (userId: string, query: any) => {
  const time = query.time; // today, week, month
  let dateFilter = {};
  const now = new Date();

  if (time === "today") {
    dateFilter = {
      createdAt: {
        gte: startOfDay(now),
        lte: endOfDay(now),
      },
    };
  } else if (time === "week") {
    dateFilter = {
      createdAt: {
        gte: startOfWeek(now, { weekStartsOn: 1 }),
        lte: endOfWeek(now, { weekStartsOn: 1 }),
      },
    };
  } else if (time === "month") {
    dateFilter = {
      createdAt: {
        gte: startOfMonth(now),
        lte: endOfMonth(now),
      },
    };
  }

  const reminders = await prisma.reminder.findMany({
    where: {
      userId,
      ...dateFilter,
    },
  });

  return reminders;
};

// my single reminder
const mySingleReminder = async (userId: string, reminderId: string) => {
  const reminder = await prisma.reminder.findFirst({
    where: {
      id: reminderId,
      userId,
    },
  });

  return reminder;
};

export const medicationServices = {
  createMedicationInDB,
  getMedicationFromDB,
  myMedicationsFromDB,
  updateMedicationInDB,
  deleteMedicationFromDB,
  uploadReport,
  myReports,
  createReminder,
  myReminders,
  mySingleReminder,
  deleteReminder,
  deleteReport,
};
