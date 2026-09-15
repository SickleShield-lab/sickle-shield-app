import path from "path";
import multer from "multer";

//file upload in local storage
// const storage = multer.diskStorage({
//   destination: function (req, file, cb) {
//     cb(null, path.join(process.cwd(), "uploads"));
//   },
//   filename: function (req, file, cb) {
//     // Add a timestamp to the original filename
//     const timestamp = Date.now();
//     const ext = path.extname(file.originalname);
//     const baseName = path.basename(file.originalname, ext);

//     const newFilename = `${timestamp}-${baseName}${ext}`;
//     cb(null, newFilename);
//   },
// });

// const upload = multer({ storage: storage });

// // Upload single images
// const updateProfileImage = upload.single("avatar");
// const uploadQuizImage = upload.single("quizImage");

// // Upload multiple images for portfolio
// const sendFiles = upload.fields([
//   { name: "sendFiles", maxCount: 10 },
//   { name: "messageFiles", maxCount: 10 },
// ]);

// export const fileUploader = {
//   sendFiles,
//   updateProfileImage,
//   uploadQuizImage,
// };

// file upload in bucket
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: { fileSize: 3000 * 1024 * 1024 }, // 3000 MB limit
  fileFilter: (req, file, cb) => {
    const allowedMimeTypes = [
      "image/jpeg",
      "image/jpg",
      "image/png",
      "image/gif",
      "image/webp",
      "video/mpeg",
      "video/mp4",
      "audio/mpeg",
      "audio/mp3",
      "video/x-matroska",
      "audio/mpeg",
      "application/zip",
      "application/pdf",
    ];
    if (!allowedMimeTypes.includes(file.mimetype)) {
      return cb(new Error("File type not allowed") as unknown as null, false);
    }
    cb(null, true);
  },
});

// upload single image
const courseImage = upload.single("courseImage");
const profileImage = upload.single("profileImage");
const reportFile = upload.single("reportFile");

// upload multiple image
const uploadMultiple = upload.fields([
  { name: "thumbnail", maxCount: 1 },
  { name: "resourceImages", maxCount: 5 },
  { name: "hospitalImages", maxCount: 5 },
]);

export const fileUploader = {
  upload,
  courseImage,
  uploadMultiple,
  profileImage,
  reportFile,
};
