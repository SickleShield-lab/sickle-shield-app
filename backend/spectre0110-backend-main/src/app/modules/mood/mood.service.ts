import prisma from "../../../shared/prisma";
import ApiError from "../../../errors/ApiErrors";

const logMoodInDB = async (
  userId: string,
  payload: { mood: string; note?: string }
) => {
  const existingUser = await prisma.user.findUnique({ where: { id: userId } });
  if (!existingUser) {
    throw new ApiError(404, "User not found");
  }

  const result = await prisma.moodEntry.create({
    data: {
      userId,
      mood: payload.mood as any,
      note: payload.note,
    },
  });

  return result;
};

const myMoodsFromDB = async (userId: string, days: number) => {
  const since = new Date();
  since.setDate(since.getDate() - days);

  const entries = await prisma.moodEntry.findMany({
    where: { userId, loggedAt: { gte: since } },
    orderBy: { loggedAt: "desc" },
  });

  return entries;
};

export const moodServices = {
  logMoodInDB,
  myMoodsFromDB,
};
