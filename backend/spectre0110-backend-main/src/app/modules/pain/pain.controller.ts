import catchAsync from "../../../shared/catchAsync";
import sendResponse from "../../../shared/sendResponse";
import { painServices } from "./pain.service";

const createPain = catchAsync(async (req, res) => {
  const result = await painServices.createPainInDB(req.body, req.user.id);
  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Pain created successfully",
    data: result,
  });
});

const singlePain = catchAsync(async (req, res) => {
  const pain = await painServices.singlePainRecordFromDB(
    req.params.painId,
    req.user.id
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Pain fetched successfully",
    data: pain,
  });
});

const allPains = catchAsync(async (req, res) => {
  const days = req.query.days ? Number(req.query.days) : 7;
  const pains = await painServices.allPainRecordsFromDB(req.user.id, days);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "All pains fetched successfully",
    data: pains,
  });
});

const updatePain = catchAsync(async (req, res) => {
  const updatedPain = await painServices.updatePainInDB(
    req.params.painId,
    req.user.id,
    req.body
  );
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Pain updated successfully",
    data: updatedPain,
  });
});

const deletePain = catchAsync(async (req, res) => {
  await painServices.deletePainInDB(req.params.painId, req.user.id);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Pain deleted successfully",
  });
});

export const painControllers = {
  createPain,
  singlePain,
  allPains,
  updatePain,
  deletePain,
};
