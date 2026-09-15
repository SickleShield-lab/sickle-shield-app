export const appointmentFilter = (search: string | null) => {
  if (!search) {
    return undefined;
  }

  const searchConditions = [];
  if (search) {
    searchConditions.push(
      { doctorName: { contains: search, mode: "insensitive" } },
      { shift: { contains: search, mode: "insensitive" } },
      { status: { contains: search, mode: "insensitive" } }
    );
  }

  return {
    OR: searchConditions,
  };
};
