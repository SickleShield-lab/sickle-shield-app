import { Pain } from "@prisma/client";
import prisma from "../../../shared/prisma";
import ApiError from "../../../errors/ApiErrors";

const createPainInDB = async (payload: Pain, userId: string) => {
  const result = await prisma.pain.create({
    data: {
      ...payload,
      userId,
    },
  });

  await prisma.user.update({
    where: {
      id: userId,
    },
    data: {
      painManager: payload.rating,
    },
  });

  return result;
};

const singlePainRecordFromDB = async (painId: string, userId: string) => {
  const pain = await prisma.pain.findUnique({
    where: {
      id: painId,
      userId,
    },
  });
  if (!pain) {
    throw new ApiError(404, "Pain record not found");
  }

  return pain;
};

const allPainRecordsFromDB = async (userId: string, days = 7) => {
  const since = new Date();
  since.setDate(since.getDate() - days);
  since.setHours(0, 0, 0, 0);

  const painRecords = await prisma.pain.findMany({
    where: {
      userId,
      createdAt: {
        gte: since,
      },
    },
    orderBy: { createdAt: "asc" },
  });

  const totalRating = painRecords.reduce((acc: number, record) => {
    return acc + record.rating;
  }, 0);

  const averageRating = painRecords.length
    ? totalRating / painRecords.length
    : 0;

  return { painRecords, averageRating };
};

const updatePainInDB = async (
  painId: string,
  userId: string,
  updatedPain: Partial<Pain>
) => {
  const pain = await prisma.pain.findUnique({
    where: {
      id: painId,
      userId,
    },
  });
  if (!pain) {
    throw new ApiError(404, "Pain record not found");
  }
  const updatedPainRecord = await prisma.pain.update({
    where: { id: painId },
    data: updatedPain,
  });
  return updatedPainRecord;
};

const deletePainInDB = async (painId: string, userId: string) => {
  const pain = await prisma.pain.findUnique({
    where: {
      id: painId,
      userId,
    },
  });
  if (!pain) {
    throw new ApiError(404, "Pain record not found");
  }
  await prisma.pain.delete({
    where: {
      id: painId,
    },
  });
  return;
};

export const painServices = {
  createPainInDB,
  singlePainRecordFromDB,
  allPainRecordsFromDB,
  updatePainInDB,
  deletePainInDB,
};
