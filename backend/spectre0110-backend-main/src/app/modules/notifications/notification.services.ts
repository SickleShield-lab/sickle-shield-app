import axios from "axios";
import ApiError from "../../../errors/ApiErrors";
import admin from "../../../helpers/firebaseAdmin";
import prisma from "../../../shared/prisma";
import config from "../../../config";

// Send notification to a single user
export const sendSingleNotification = async (
  userId: string,
  body: string,
  title: string
) => {
  const user = await prisma.user.findUnique({
    where: {
      id: userId,
    },
    select: {
      fcmToken: true,
    },
  });

  await prisma.notification.create({
    data: {
      userId,
      title,
      body,
    },
  });

  if (user?.fcmToken) {
    const message = {
      notification: {
        body: body,
        title: title,
      },
      token: user?.fcmToken,
    };

    await prisma.notification.create({
      data: {
        userId: userId,
        body: body,
        title: title,
      },
    });

    try {
      const response = await admin.messaging().send(message);
      return response;
    } catch (error: any) {
      if (error.code === "messaging/invalid-registration-token") {
        throw new ApiError(400, "Invalid FCM registration token");
      } else if (error.code === "messaging/registration-token-not-registered") {
        throw new ApiError(404, "FCM token is no longer registered");
      } else {
        throw new ApiError(500, "Failed to send notification");
      }
    }
  }
  return;
};

export const oneSignalNotify = async (
  userId: string,
  body: string,
  title: string
) => {
  const ONE_SIGNAL_APP_ID = config.oneSignal.appId;
  const ONE_SIGNAL_API_KEY = config.oneSignal.apiKey;

  if (!ONE_SIGNAL_APP_ID || !ONE_SIGNAL_API_KEY) {
    throw new ApiError(
      500,
      "Missing OneSignal configuration. Set ONESIGNAL_APP_ID and ONESIGNAL_API_KEY in .env"
    );
  }

  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  await prisma.notification.create({
    data: {
      userId,
      title,
      body,
    },
  });

  if (user?.fcmToken) {
    await axios.post(
      "https://onesignal.com/api/v1/notifications",
      {
        app_id: ONE_SIGNAL_APP_ID,
        target_channel: "push",
        include_subscription_ids: [user.fcmToken],
        headings: { en: title },
        contents: { en: body },
      },
      {
        headers: {
          Authorization: `Basic ${ONE_SIGNAL_API_KEY}`,
          "Content-Type": "application/json",
        },
      }
    );
  }

  return;
};

const getNotificationsFromDB = async (userId: string) => {
  const notifications = await prisma.notification.findMany({
    where: {
      userId: userId,
    },
    orderBy: { createdAt: "desc" },
  });

  if (notifications.length === 0) {
    throw new ApiError(404, "No notifications found for the user");
  }

  return notifications;
};

const getSingleNotificationFromDB = async (notificationId: string) => {
  const notification = await prisma.notification.findFirst({
    where: {
      id: notificationId,
    },
  });

  if (!notification) {
    throw new ApiError(404, "Notification not found for the user");
  }

  await prisma.notification.update({
    where: { id: notificationId },
    data: { read: true },
  });

  return notification;
};

export const notificationServices = {
  getNotificationsFromDB,
  getSingleNotificationFromDB,
};
