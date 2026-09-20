import { TargetType } from "@prisma/client";
import catchAsync from "../../../shared/catchAsync";
import sendResponse from "../../../shared/sendResponse";
import { goalServices } from "./goal.service";

const createWeightGoal = catchAsync(async (req, res) => {
  const result = await goalServices.createWeightGoalInDB(req.user.id, req.body);
  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Weight goal created successfully",
    data: result,
  });
});

const getWeightGoals = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const { targetType } = req.query;
  const goals = await goalServices.getMyWeightGoalsFromDB(
    userId,
    targetType as TargetType
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Weight goal fetched successfully",
    data: goals,
  });
});

const singleWeightGoal = catchAsync(async (req, res) => {
  const goal = await goalServices.singleWeightGoalFromDB(
    req.user.id,
    req.params.weightId
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Weight goal fetched successfully",
    data: goal,
  });
});

const updateWeightGoal = catchAsync(async (req, res) => {
  const updatedGoal = await goalServices.updateWeightGoalInDB(
    req.user.id,
    req.params.weightId,
    req.body
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Weight goal updated successfully",
    data: updatedGoal,
  });
});

const deleteWeightGoal = catchAsync(async (req, res) => {
  await goalServices.deleteWeightGoalFromDB(req.user.id, req.params.weightId);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Weight goal deleted successfully",
  });
});

const logWeight = catchAsync(async (req, res) => {
  const result = await goalServices.logWeightEntryInDB(req.user.id, req.body.weight);
  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Weight logged successfully",
    data: result,
  });
});

const weightHistory = catchAsync(async (req, res) => {
  const days = req.query.days ? Number(req.query.days) : 30;
  const result = await goalServices.weightHistoryFromDB(req.user.id, days);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Weight history fetched successfully",
    data: result,
  });
});

const createWaterIntake = catchAsync(async (req, res) => {
  const result = await goalServices.createWaterIntakeInDB(
    req.body,
    req.user.id
  );
  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Water intake goal created successfully",
    data: result,
  });
});

const getWaterIntakeGoal = catchAsync(async (req, res) => {
  const goal = await goalServices.getWaterIntakeFromDB(req.user.id);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Water intake goal fetched successfully",
    data: goal,
  });
});

export const goalControllers = {
  createWeightGoal,
  getWeightGoals,
  singleWeightGoal,
  updateWeightGoal,
  deleteWeightGoal,
  logWeight,
  weightHistory,
  createWaterIntake,
  getWaterIntakeGoal,
};
