import catchAsync from "../../../shared/catchAsync";
import { authService } from "./auth.service";
import sendResponse from "../../../shared/sendResponse";

//login user
const loginUser = catchAsync(async (req, res) => {
  const result = await authService.loginUserIntoDB(req.body);
  res.cookie("accessToken", result.accessToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "none",
    maxAge: 24 * 60 * 60 * 1000,
  });
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "User successfully logged in",
    data: result,
  });
});

const authLogin = catchAsync(async (req, res) => {
  const result = await authService.authLogin(req.body);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "User successfully authenticated",
    data: result,
  });
});

//send forgot password otp
const sendForgotPasswordOtp = catchAsync(async (req, res) => {
  const email = req.body.email as string;
  const response = await authService.sendForgotPasswordOtpDB(email);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "OTP send successfully",
    data: response,
  });
});

// verify forgot password otp code
const verifyForgotPasswordOtpCode = catchAsync(async (req, res) => {
  const payload = req.body;
  const response = await authService.verifyForgotPasswordOtpCodeDB(payload);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "OTP verified successfully.",
    data: response,
  });
});

// update forgot password
const resetPassword = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const { newPassword } = req.body;
  const result = await authService.resetForgotPasswordDB(newPassword, userId);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Password updated successfully.",
    data: result,
  });
});

// get profile for logged in user
const getProfile = catchAsync(async (req, res) => {
  const { id } = req.user;
  const user = await authService.getProfileFromDB(id);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "User profile retrieved successfully",
    data: user,
  });
});

// update user profile only logged in user
const updateProfile = catchAsync(async (req, res) => {
  const { id } = req.user;
  const updatedUser = await authService.updateProfileIntoDB(id, req.body);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "User profile updated successfully",
    data: updatedUser,
  });
});

const changeProfileImage = catchAsync(async (req, res) => {
  const updatedImage = await authService.changeProfileImageInDB(req);
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Your profile image has beeb updated successfully",
    data: updatedImage,
  });
});

export const authController = {
  loginUser,
  getProfile,
  updateProfile,
  sendForgotPasswordOtp,
  verifyForgotPasswordOtpCode,
  resetPassword,
  changeProfileImage,
  authLogin,
};
