import prisma from "../../../shared/prisma";
import { Request } from "express";
import { uploadInSpace } from "../../../shared/uploadInSpace";
import { paginationHelper } from "../../../shared/pagination";
import { resourceFilter } from "../../../shared/resourceFilter";

const createResourceInDB = async (req: Request) => {
  const payload = req.body;
  const files = req.files as { [fieldname: string]: Express.Multer.File[] };

  const processImages = async (files?: Express.Multer.File[]) => {
    if (!files || files.length === 0) return null;
    return Promise.all(
      files.map((file) => uploadInSpace(file, "resourceImages"))
    );
  };

  const [resourceImages] = await Promise.all([
    processImages(files["resourceImages"]),
  ]);

  const createdResource = await prisma.eduResource.create({
    data: { ...payload, resourceImages },
  });
  return createdResource;
};

const getAllResourcesFromDB = async (req: Request) => {
  const { page, limit, skip, take, search } = paginationHelper(
    req.query as any
  );
  const searchFilter = search ? resourceFilter(search) : {};
  const resources = await prisma.eduResource.findMany({
    where: searchFilter,
    skip: skip,
    take: take,
    orderBy: { updatedAt: "desc" },
  });

  const totalCount = await prisma.eduResource.count({
    where: searchFilter,
  });
  const totalPages = Math.ceil(totalCount / limit);

  return {
    totalCount,
    totalPages,
    currentPage: page,
    resources,
  };
};

const singleResource = async (resourceId: string) => {
  const resource = await prisma.eduResource.findUnique({
    where: { id: resourceId },
  });
  if (!resource) {
    throw new Error("Resource not found!");
  }
  return resource;
};

const deleteResource = async (resourceId: string) => {
  const resource = await singleResource(resourceId);
  await prisma.eduResource.delete({ where: { id: resourceId } });
  return resource;
};

export const resourceServices = {
  createResourceInDB,
  getAllResourcesFromDB,
  singleResource,
  deleteResource,
};
