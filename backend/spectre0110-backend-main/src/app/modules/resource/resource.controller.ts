import { resourceServices } from "./resource.service";
import catchAsync from "../../../shared/catchAsync";
import sendResponse from "../../../shared/sendResponse";

const createResource = catchAsync(async (req, res) => {
  const resource = await resourceServices.createResourceInDB(req);
  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Resource created successfully",
    data: resource,
  });
});

const allResources = catchAsync(async (req, res) => {
  const resource = await resourceServices.getAllResourcesFromDB(req);
  sendResponse(res, {
    statusCode: 201,
    success: true,
    message: "Resources retrived successfully",
    data: resource,
  });
});

const singleResource = catchAsync(async (req, res) => {
  const { resourceId } = req.params;
  const resource = await resourceServices.singleResource(resourceId);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Resource retrived successfully",
    data: resource,
  });
});

const deleteResource = catchAsync(async (req, res) => {
  const { resourceId } = req.params;
  await resourceServices.deleteResource(resourceId);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Resource deleted successfully",
  });
});

export const resourceControllers = {
  createResource,
  allResources,
  singleResource,
  deleteResource,
};
