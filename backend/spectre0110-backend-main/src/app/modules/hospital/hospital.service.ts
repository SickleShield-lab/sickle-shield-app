import { Request } from "express";
import { uploadInSpace } from "../../../shared/uploadInSpace";
import prisma from "../../../shared/prisma";
import ApiError from "../../../errors/ApiErrors";
import { paginationHelper } from "../../../shared/pagination";
import { hospitalFilter } from "../../../shared/hospitalFilter";
import { EmergencyContact, Hospital } from "@prisma/client";

//create hospital
const createHospitalInDB = async (payload: Hospital, userId: string) => {
  const createdHospital = await prisma.hospital.create({
    data: {
      ...payload,
      userId,
    },
  });
  return createdHospital;
};

// Get all hospitals with pagination and search
const getHospitalsFromDB = async (query: any, userId: string) => {
  const { page, limit, take, skip, search } = paginationHelper(query);

  const searchFilter = search ? hospitalFilter(search) : {};

  const hospitals = await prisma.hospital.findMany({
    where: {
      ...searchFilter,
      userId,
    },
    skip,
    take,
    orderBy: { createdAt: "desc" },
  });

  const totalCount = await prisma.hospital.count({
    where: { ...searchFilter, userId },
  });
  const totalPages = Math.ceil(totalCount / limit);

  return {
    totalCount,
    totalPages,
    currentPage: page,
    hospitals,
  };
};

// Get a single hospital by ID
const getHospitalById = async (id: string) => {
  const hospital = await prisma.hospital.findUnique({
    where: { id },
  });

  if (!hospital) {
    throw new ApiError(404, "Hospital not found!");
  }

  return hospital;
};

// Update a hospital
const updateHospitalInDB = async (req: Request) => {
  const { hospitalId } = req.params;
  const payload = req.body;
  const userId = req.user.id;
  const role = req.user.role;
  let hospitalImages: string | undefined;

  const existingHospital = await prisma.hospital.findUnique({
    where: { id: hospitalId },
  });
  if (
    !existingHospital ||
    (existingHospital.userId !== userId && role !== "ADMIN")
  ) {
    throw new ApiError(404, "Hospital not found!");
  }

  if (req.files && "hospitalImages" in req.files) {
    const uploaded = await Promise.all(
      (req.files["hospitalImages"] as Express.Multer.File[]).map((file) =>
        uploadInSpace(file, "hospitalImages")
      )
    );
    hospitalImages = uploaded[0];
  }

  const updatedHospital = await prisma.hospital.update({
    where: { id: hospitalId },
    data: { ...payload, ...(hospitalImages ? { hospitalImages } : {}) },
  });

  return updatedHospital;
};

// Delete a hospital
const deleteHospitalFromDB = async (
  id: string,
  userId: string,
  role: string
) => {
  const existingHospital = await prisma.hospital.findUnique({ where: { id } });

  if (!existingHospital || (existingHospital.userId !== userId && role !== "ADMIN")) {
    throw new ApiError(404, "Hospital not found!");
  }

  // Appointments have a required FK to their hospital, so deleting a hospital
  // that still has appointments would otherwise fail with a P2003 constraint
  // error and silently leave the hospital in place.
  return await prisma.$transaction(async (tx) => {
    await tx.appointment.deleteMany({ where: { hospitalId: id } });
    return tx.hospital.delete({ where: { id } });
  });
};

// create contact
const createEmergencyContact = async (
  userId: string,
  payload: EmergencyContact
) => {
  await prisma.emergencyContact.create({
    data: {
      ...payload,
      userId,
    },
  });
};

const deleteContact = async (contactId: string, userId: string) => {
  const contact = await prisma.emergencyContact.findUnique({
    where: { id: contactId },
  });
  if (!contact || contact.userId !== userId) {
    throw new ApiError(404, "Emergency contact not found");
  }
  await prisma.emergencyContact.delete({
    where: {
      id: contactId,
    },
  });
  return;
};

// Get all emergency contacts
const emergencyContacts = async (userId: string, query: any) => {
  const { page, limit, take, skip } = paginationHelper(query as any);

  const contacts = await prisma.emergencyContact.findMany({
    where: {
      userId,
    },
    skip,
    take,
    orderBy: { createdAt: "desc" },
  });

  const totalCount = await prisma.emergencyContact.count({ where: { userId } });
  const totalPages = Math.ceil(totalCount / limit);

  return {
    totalCount,
    totalPages,
    currentPage: page,
    contacts,
  };
};

export const hospitalServices = {
  createHospitalInDB,
  getHospitalsFromDB,
  getHospitalById,
  updateHospitalInDB,
  deleteHospitalFromDB,
  createEmergencyContact,
  emergencyContacts,
  deleteContact,
};
