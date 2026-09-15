import prisma from "../../../shared/prisma";
import bcrypt from "bcryptjs";
import ApiError from "../../../errors/ApiErrors";
import { jwtHelpers } from "../../../helpers/jwtHelpers";
import config from "../../../config";
import { User } from "@prisma/client";
import generateOTP from "../../../helpers/generateOtp";
import sendEmail from "../../../helpers/sendEmail";
import { uploadInSpace } from "../../../shared/uploadInSpace";
import { Request } from "express";
import { oneSignalNotify } from "../notifications/notification.services";

const generateRandomPassword = () => {
  const chars =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let password = "";
  for (let i = 0; i < 6; i++) {
    password += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return password;
};

//login user
const loginUserIntoDB = async (payload: {
  email: string;
  password: string;
  fcmToken: string;
}) => {
  const user = await prisma.user.findUnique({
    where: {
      email: payload.email,
    },
  });

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  const isPasswordValid = await bcrypt.compare(
    payload.password,
    user?.password
  );

  if (!isPasswordValid) {
    throw new ApiError(401, "Invalid credentials");
  }

  await prisma.user.update({
    where: {
      id: user.id,
    },
    data: {
      fcmToken: payload.fcmToken,
    },
  });

  const accessToken = jwtHelpers.generateToken(
    user,
    config.jwt.jwt_secret as string,
    config.jwt.expires_in as string
  );

  const { password, status, createdAt, updatedAt, ...userInfo } = user;

  return {
    accessToken,
    userInfo,
  };
};

const authLogin = async (payload: User) => {
  const user = await prisma.user.findUnique({
    where: {
      email: payload.email,
    },
  });
  if (user) {
    const accessToken = jwtHelpers.generateToken(
      { id: user.id, email: user.email, role: user.role },
      config.jwt.jwt_secret as string,
      config.jwt.expires_in as string
    );

    await prisma.user.update({
      where: {
        id: user.id,
      },
      data: {
        fcmToken: payload.fcmToken,
      },
    });

    const { password, status, createdAt, updatedAt, ...userInfo } = user;

    return {
      accessToken,
      userInfo,
    };
  } else {
    const plainPassword = generateRandomPassword();
    const hashedPassword = await bcrypt.hash(plainPassword, 10);
    const user = await prisma.user.create({
      data: {
        ...payload,
        password: hashedPassword,
      },
    });

    const { password, status, createdAt, updatedAt, ...userInfo } = user;

    const accessToken = jwtHelpers.generateToken(
      { id: user.id, email: user.email, role: user.role },
      config.jwt.jwt_secret as string,
      config.jwt.expires_in as string
    );

    return {
      accessToken,
      userInfo,
    };
  }
};

//send forgot password otp
const sendForgotPasswordOtpDB = async (email: string) => {
  const existringUser = await prisma.user.findUnique({
    where: {
      email: email,
    },
  });
  if (!existringUser) {
    throw new ApiError(404, "User not found");
  }
  // Generate OTP and expiry time
  const otp = generateOTP(); // 4-digit OTP
  const OTP_EXPIRATION_TIME = 5 * 60 * 1000; // 5 minute
  const expiresAt = Date.now() + OTP_EXPIRATION_TIME;
  const subject = "Your Password Reset OTP";

  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; border: 1px solid #ddd; border-radius: 10px; overflow: hidden;">

    <!-- Banner -->
    <div>
      <img src="https://nyc3.digitaloceanspaces.com/smtech-space/uploads/profile/profileImages/1756180990767-dhgse1b37s.png" alt="Banner" style="width: 100%; height: auto;" />
    </div>

    <!-- Content -->
    <div style="padding: 20px;">
      <h3>Hi <b>${existringUser.username}</b>,</h3>
      <p style="font-size: 20px;">
        Password reset requested for email address: ${
          existringUser.email
        } Please use the code below to reset your password
      </p>

      <div style="margin: 30px 0; text-align: center;">
        <span style="font-size: 28px; font-weight: bold; color: #e63946; letter-spacing: 4px;">
          ${otp}
        </span>
      </div>

      <p>If you did not request this reset code, please contact us at 
        <a href="mailto:support@sickleshield.com">support@sickleshield.com</a>
      </p>
    </div>

    <!-- Footer -->
    <div style="background: #f8f8f8; padding: 15px; text-align: center; font-size: 12px; color: #888;">
      &copy; ${new Date().getFullYear()} SickleShield. All rights reserved.
    </div>
  </div>
    `;

  await sendEmail(email, subject, html);
  await prisma.otp.upsert({
    where: {
      email: email,
    },
    update: { otpCode: otp, expiresAt: new Date(expiresAt) },
    create: { email: email, otpCode: otp, expiresAt: new Date(expiresAt) },
  });

  return otp;
};

// verify otp code
const verifyForgotPasswordOtpCodeDB = async (payload: any) => {
  const { email, otp } = payload;

  if (!email && !otp) {
    throw new ApiError(400, "Email and OTP are required.");
  }

  const user = await prisma.user.findUnique({ where: { email: email } });
  if (!user) {
    throw new ApiError(404, "User not found");
  }

  const userId = user.id;

  const verifyData = await prisma.otp.findUnique({
    where: {
      email: email,
    },
  });

  if (!verifyData) {
    throw new ApiError(400, "Invalid or expired OTP.");
  }

  const { otpCode: savedOtp, expiresAt } = verifyData;

  if (otp !== savedOtp) {
    throw new ApiError(401, "Invalid OTP.");
  }

  if (Date.now() > expiresAt.getTime()) {
    await prisma.otp.delete({
      where: {
        email: email,
      },
    }); // OTP has expired
    throw new ApiError(410, "OTP has expired. Please request a new OTP.");
  }

  // OTP is valid
  await prisma.otp.delete({
    where: {
      email: email,
    },
  });

  const accessToken = jwtHelpers.generateToken(
    { id: userId, email },
    config.jwt.jwt_secret as string,
    config.jwt.expires_in as string
  );

  return { accessToken: accessToken };
};

// reset password
const resetForgotPasswordDB = async (newPassword: string, userId: string) => {
  const existingUser = await prisma.user.findUnique({ where: { id: userId } });
  if (!existingUser) {
    throw new ApiError(404, "user not found");
  }
  const email = existingUser.email as string;
  const hashedPassword = await bcrypt.hash(
    newPassword,
    Number(config.jwt.gen_salt)
  );

  await prisma.user.update({
    where: {
      email: email,
    },
    data: {
      password: hashedPassword,
    },
  });

  await oneSignalNotify(
    userId,
    `Password reset has been successfully`,
    "Password reset"
  );
  return;
};

// get profile for logged in user
const getProfileFromDB = async (userId: string) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });
  if (!user) {
    throw new ApiError(404, "user not found!");
  }

  const { password, createdAt, updatedAt, ...sanitizedUser } = user;

  const result = await prisma.waterIntake.findUnique({
    where: {
      userId,
      updatedAt: {
        gte: new Date(new Date().setHours(0, 0, 0, 0)),
        lte: new Date(new Date().setHours(23, 59, 59, 999)),
      },
    },
  });

  return { ...sanitizedUser, lastIntake: result?.amount ?? 0 };
};

const updateProfileIntoDB = async (userId: string, userData: Partial<User>) => {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) {
    throw new ApiError(404, "User not found for edit user");
  }

  let updatedData = { ...userData };
  if (userData.password) {
    const hashedPassword = await bcrypt.hash(userData.password, 10);
    updatedData.password = hashedPassword;
  }

  const updatedUser = await prisma.user.update({
    where: { id: userId },
    data: updatedData,
  });

  const { password, ...sanitizedUser } = updatedUser;
  return sanitizedUser;
};

const changeProfileImageInDB = async (req: Request) => {
  const file = req.file;
  const userId = req.user.id;
  if (!file) {
    throw new ApiError(400, "Profile image is required");
  }

  const profileImage = await uploadInSpace(file, "profile/profileImages");

  const updatedImage = await prisma.user.update({
    where: { id: userId },
    data: { profileImage },
  });

  await oneSignalNotify(
    userId,
    `Password changed successfully`,
    "Password change"
  );

  return updatedImage;
};

export const authService = {
  loginUserIntoDB,
  getProfileFromDB,
  updateProfileIntoDB,
  sendForgotPasswordOtpDB,
  verifyForgotPasswordOtpCodeDB,
  resetForgotPasswordDB,
  changeProfileImageInDB,
  authLogin,
};
