import { Days, Symptoms } from "@prisma/client";
import prisma from "../../../shared/prisma";
import ApiError from "../../../errors/ApiErrors";

//create symptoms
const createsymptomsInDB = async (userId: string, payload: Symptoms) => {
  const existingUser = await prisma.user.findUnique({ where: { id: userId } });
  if (!existingUser) {
    throw new ApiError(404, "User not found");
  }

  const existingsymptoms = await prisma.symptoms.findFirst({
    where: {
      title: payload.title,
      userId,
      day: payload.day,
    },
  });
  if (existingsymptoms) {
    throw new ApiError(409, "symptoms already exists");
  }
  const result = await prisma.symptoms.create({
    data: {
      ...payload,
      userId,
    },
  });

  return result;
};

// Get a symptoms by id
const getsymptomsFromDB = async (symptomsId: string, userId: string) => {
  const result = await prisma.symptoms.findUnique({
    where: {
      id: symptomsId,
      userId,
    },
  });
  if (!result) {
    throw new ApiError(404, "symptoms not found");
  }

  return result;
};

// Get all symptomss for a user
const mysymptomsFromDB = async (userId: string, day: Days) => {
  const result = await prisma.symptoms.findMany({
    where: {
      userId,
      day,
    },
  });

  return result;
};

// Update a symptoms
const updatesymptomsInDB = async (
  symptomsId: string,
  userId: string,
  payload: Symptoms
) => {
  const result = await prisma.symptoms.update({
    where: {
      id: symptomsId,
      userId,
    },
    data: {
      ...payload,
    },
  });

  return result;
};

// Delete a symptoms
const deletesymptomsFromDB = async (symptomsId: string, userId: string) => {
  const user = await prisma.user.findUnique({
    where: {
      id: userId,
    },
  });
  if (!user) {
    throw new ApiError(404, "User not found");
  }

  const symptoms = await prisma.symptoms.findUnique({
    where: {
      id: symptomsId,
    },
  });

  if (!symptoms) {
    throw new ApiError(404, "symptoms not found");
  }

  await prisma.symptoms.delete({
    where: {
      id: symptomsId,
      userId,
    },
  });

  return;
};

export const symptomsServices = {
  createsymptomsInDB,
  getsymptomsFromDB,
  mysymptomsFromDB,
  updatesymptomsInDB,
  deletesymptomsFromDB,
};
