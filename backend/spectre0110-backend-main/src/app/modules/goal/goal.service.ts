import { TargetType, WaterIntake, WeightGoal } from "@prisma/client";
import prisma from "../../../shared/prisma";
import ApiError from "../../../errors/ApiErrors";

const createWeightGoalInDB = async (userId: string, payload: WeightGoal) => {
  const existingUser = await prisma.user.findUnique({
    where: { id: userId },
  });
  if (!existingUser) {
    throw new ApiError(404, "User not found");
  }

  const existingWeightGoal = await prisma.weightGoal.findFirst({
    where: { userId, targetType: payload.targetType },
  });
  if (existingWeightGoal) {
    throw new ApiError(409, "Weight goal already exists");
  }

  const result = await prisma.weightGoal.create({
    data: {
      ...payload,
      userId,
    },
  });

  return result;
};

const getMyWeightGoalsFromDB = async (
  userId: string,
  targetType: TargetType
) => {
  const userInfo = await prisma.user.findUnique({
    where: {
      id: userId,
    },
  });
  if (!userInfo) {
    throw new ApiError(404, "User not found");
  }
  const result = await prisma.weightGoal.findFirst({
    where: {
      userId,
      targetType,
    },
    select: {
      id: true,
      targetType: true,
      startWeight: true,
      targetWeight: true,
    },
  });

  return {
    ...result,
    id: result?.id || null,
    targetType: result?.targetType || targetType,
    startWeight: result?.startWeight || 0,
    targetWeight: result?.targetWeight || 0,
    currentWeight: Number(userInfo.weight),
  };
};

const singleWeightGoalFromDB = async (userId: string, weightId: string) => {
  const weightGoal = await prisma.weightGoal.findUnique({
    where: {
      id: weightId,
      userId,
    },
  });
  if (!weightGoal) {
    throw new ApiError(404, "Weight goal not found");
  }

  return weightGoal;
};

const updateWeightGoalInDB = async (
  userId: string,
  weightId: string,
  payload: WeightGoal
) => {
  const existingWeightGoal = await prisma.weightGoal.findUnique({
    where: { id: weightId, userId },
  });
  if (!existingWeightGoal) {
    throw new ApiError(404, "Weight goal not found");
  }
  const result = await prisma.weightGoal.update({
    where: { id: weightId },
    data: payload,
  });
  return result;
};

const deleteWeightGoalFromDB = async (userId: string, weightId: string) => {
  const existingWeightGoal = await prisma.weightGoal.findUnique({
    where: { id: weightId, userId },
  });
  if (!existingWeightGoal) {
    throw new ApiError(404, "Weight goal not found");
  }
  await prisma.weightGoal.delete({
    where: { id: weightId },
  });
  return;
};

const createWaterIntakeInDB = async (payload: WaterIntake, userId: string) => {
  const userInfo = await prisma.user.findUnique({
    where: {
      id: userId,
    },
  });
  if (!userInfo) {
    throw new ApiError(404, "User not found");
  }
  const result = await prisma.waterIntake.upsert({
    where: {
      userId,
    },
    update: {
      amount: payload.amount,
    },
    create: {
      ...payload,
      userId,
    },
  });

  const waterIntakePercentage = userInfo?.waterIntake
    ? (result.amount / userInfo.waterIntake) * 100
    : 0;

  return Number(waterIntakePercentage.toFixed(2));
};

const getWaterIntakeFromDB = async (userId: string) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });
  if (!user) {
    throw new ApiError(404, "User not found");
  }

  const result = await prisma.waterIntake.findUnique({
    where: {
      userId,
      updatedAt: {
        gte: new Date(new Date().setHours(0, 0, 0, 0)),
        lte: new Date(new Date().setHours(23, 59, 59, 999)),
      },
    },
  });

  if (!result) {
    return {
      amount: 0,
      percentage: 0,
      target: user.waterIntake,
    };
  }

  const intakePercentage =
    ((result?.amount ?? 0) / (user?.waterIntake ?? 0)) * 100;

  return {
    amount: result.amount,
    percentage: intakePercentage,
    target: user.waterIntake,
  };
};

export const goalServices = {
  createWeightGoalInDB,
  getMyWeightGoalsFromDB,
  singleWeightGoalFromDB,
  updateWeightGoalInDB,
  deleteWeightGoalFromDB,
  createWaterIntakeInDB,
  getWaterIntakeFromDB,
};
