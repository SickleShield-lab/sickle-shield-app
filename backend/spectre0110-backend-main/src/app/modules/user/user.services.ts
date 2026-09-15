import { PendingUser, User } from "@prisma/client";
import ApiError from "../../../errors/ApiErrors";
import bcrypt from "bcryptjs";
import { jwtHelpers } from "../../../helpers/jwtHelpers";
import config from "../../../config";
import prisma from "../../../shared/prisma";

const UUID_REGEX =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const isValidId = (id: string) => UUID_REGEX.test(id);
import generateOTP from "../../../helpers/generateOtp";
import sendEmail from "../../../helpers/sendEmail";

const createUserIntoDB = async (payload: PendingUser) => {
  const OTP_EXPIRATION_TIME = 5 * 60 * 1000;
  const expiresAt = new Date(Date.now() + OTP_EXPIRATION_TIME);
  const otp = generateOTP();

  const existingEmail = await prisma.user.findUnique({
    where: { email: payload.email },
  });

  if (existingEmail) {
    throw new ApiError(400, "Email already exist");
  }

  const hashedPassword = bcrypt.hashSync(payload.password, 10);

  await prisma.pendingUser.upsert({
    where: {
      email: payload.email,
    },
    create: {
      email: payload.email,
      fcmToken: payload.fcmToken,
      username: payload.username,
      password: hashedPassword,
    },
    update: {
      fcmToken: payload.fcmToken,
    },
  });

  // Send verification email
  const subject = "Signup Verification";
  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; border: 1px solid #ddd; border-radius: 10px; overflow: hidden;">

    <!-- Banner -->
    <div>
      <img src="https://nyc3.digitaloceanspaces.com/smtech-space/uploads/profile/profileImages/1756180990767-dhgse1b37s.png" alt="Banner" style="width: 100%; height: auto;" />
    </div>

    <!-- Content -->
    <div style="padding: 20px;">
      <h3>Hi <b>${payload.username}</b>,</h3>
      <p style="font-size: 20px;">
        Login requested for email address: ${
          payload.email
        } Please use the code below to login on the <b>SickleShield</b> app
      </p>

      <div style="margin: 30px 0; text-align: center;">
        <span style="font-size: 28px; font-weight: bold; color: #e63946; letter-spacing: 4px;">
          ${otp}
        </span>
      </div>

      <p>If you did not request this login code, please contact us at 
        <a href="mailto:support@sickleshield.com">support@sickleshield.com</a>
      </p>
    </div>

    <!-- Footer -->
    <div style="background: #f8f8f8; padding: 15px; text-align: center; font-size: 12px; color: #888;">
      &copy; ${new Date().getFullYear()} SickleShield. All rights reserved.
    </div>
  </div>
    `;
  await sendEmail(payload.email, subject, html);

  // Upsert OTP
  await prisma.otp.upsert({
    where: { email: payload.email },
    update: { otpCode: otp, expiresAt },
    create: { email: payload.email, otpCode: otp, expiresAt },
  });

  return otp;
};

const signupVerification = async (payload: { email: string; otp: string }) => {
  const { email, otp } = payload;

  const existingUser = await prisma.user.findUnique({
    where: {
      email,
    },
  });

  if (existingUser) {
    throw new ApiError(400, "Already verified this email");
  }

  const pendingUser = await prisma.pendingUser.findFirst({
    where: {
      email: payload.email,
    },
  });

  if (!pendingUser) {
    throw new ApiError(404, "No pending signup found. Please sign up first.");
  }

  const otpData = await prisma.otp.findUnique({
    where: { email },
  });

  if (!otpData) {
    throw new ApiError(400, "Invalid or expired OTP.");
  }

  if (otpData.otpCode !== otp) {
    throw new ApiError(401, "Incorrect OTP.");
  }

  if (Date.now() > otpData.expiresAt.getTime()) {
    await prisma.otp.delete({ where: { email } });
    throw new ApiError(410, "OTP has expired. Please request a new one.");
  }

  // Step 4: Create user and cleanup
  const user = await prisma.$transaction(async (tx) => {
    await tx.otp.delete({ where: { email } });
    await tx.pendingUser.delete({
      where: { email },
    });

    return tx.user.create({
      data: {
        email: pendingUser.email,
        username: pendingUser.username,
        password: pendingUser.password,
        fcmToken: pendingUser.fcmToken ?? null,
      },
      select: {
        id: true,
        username: true,
        email: true,
        role: true,
      },
    });
  });

  // Step 5: Generate token
  const accessToken = jwtHelpers.generateToken(
    { id: user.id, role: user.role },
    config.jwt.jwt_secret!,
    config.jwt.expires_in!
  );

  return { accessToken, user };
};

//get single user
const getSingleUserIntoDB = async (id: string) => {
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) {
    throw new ApiError(404, "user not found!");
  }

  const { password, ...sanitizedUser } = user;
  return sanitizedUser;
};

//get all users
const getUsersIntoDB = async () => {
  const users = await prisma.user.findMany();
  if (users.length === 0) {
    throw new ApiError(404, "Users not found!");
  }
  const sanitizedUsers = users.map((user) => {
    const { password, ...sanitizedUser } = user;
    return sanitizedUser;
  });
  return sanitizedUsers;
};

//update user
const updateUserIntoDB = async (id: string, userData: any) => {
  if (!isValidId(id)) {
    throw new ApiError(400, "Invalid user ID format");
  }
  const existingUser = await getSingleUserIntoDB(id);
  if (!existingUser) {
    throw new ApiError(404, "user not found for edit user");
  }
  const updatedUser = await prisma.user.update({
    where: { id },
    data: userData,
  });

  const { password, ...sanitizedUser } = updatedUser;

  return sanitizedUser;
};

//delete user
const deleteUserIntoDB = async (userId: string, loggedId: string) => {
  if (!isValidId(userId)) {
    throw new ApiError(400, "Invalid user ID format");
  }

  if (userId === loggedId) {
    throw new ApiError(403, "You can't delete your own account!");
  }
  const existingUser = await getSingleUserIntoDB(userId);
  if (!existingUser) {
    throw new ApiError(404, "user not found for delete this");
  }
  await prisma.user.delete({
    where: { id: userId },
  });
  return;
};

export const userService = {
  createUserIntoDB,
  signupVerification,
  getUsersIntoDB,
  getSingleUserIntoDB,
  updateUserIntoDB,
  deleteUserIntoDB,
};
