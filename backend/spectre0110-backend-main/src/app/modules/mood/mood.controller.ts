import catchAsync from "../../../shared/catchAsync";
import sendResponse from "../../../shared/sendResponse";
import { moodServices } from "./mood.service";

const logMood = catchAsync(async (req, res) => {
  const result = await moodServices.logMoodInDB(req.user.id, req.body);
  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Mood logged successfully",
    data: result,
  });
});

const myMoods = catchAsync(async (req, res) => {
  const days = req.query.days ? Number(req.query.days) : 30;
  const result = await moodServices.myMoodsFromDB(req.user.id, days);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Moods fetched successfully",
    data: result,
  });
});

export const moodControllers = {
  logMood,
  myMoods,
};
