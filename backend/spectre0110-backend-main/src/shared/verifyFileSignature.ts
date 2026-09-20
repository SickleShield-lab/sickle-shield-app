/**
 * Verifies that a file's actual bytes match its declared MIME type, and
 * rejects known-dangerous extensions outright regardless of what type the
 * client claims.
 *
 * Multer's `fileFilter` (see `helpers/fileUploader.ts`) only checks the
 * client-supplied `Content-Type` header, which is trivially spoofable - an
 * attacker can rename a PHP/shell script to "report.pdf" and declare
 * `application/pdf` and it will sail straight through. This closes that gap
 * by checking magic bytes against the declared type before the file is
 * ever written to storage.
 */

const DANGEROUS_EXTENSIONS = [
  ".php", ".php3", ".php4", ".php5", ".php7", ".phtml", ".phar",
  ".exe", ".sh", ".bash", ".bat", ".cmd", ".com", ".scr", ".msi",
  ".js", ".mjs", ".cjs", ".jar", ".py", ".pl", ".cgi", ".rb",
  ".asp", ".aspx", ".jsp", ".jspx", ".dll", ".vbs", ".vbe", ".ps1", ".apk",
];

type SignatureCheck = (buffer: Buffer) => boolean;

const startsWith = (buffer: Buffer, bytes: number[]): boolean =>
  bytes.length <= buffer.length && bytes.every((byte, index) => buffer[index] === byte);

const SIGNATURES: Record<string, SignatureCheck> = {
  "image/jpeg": (b) => startsWith(b, [0xff, 0xd8, 0xff]),
  "image/jpg": (b) => startsWith(b, [0xff, 0xd8, 0xff]),
  "image/png": (b) => startsWith(b, [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  "image/gif": (b) => startsWith(b, [0x47, 0x49, 0x46, 0x38]),
  "image/webp": (b) => startsWith(b, [0x52, 0x49, 0x46, 0x46]) && b.slice(8, 12).toString("ascii") === "WEBP",
  "application/pdf": (b) => startsWith(b, [0x25, 0x50, 0x44, 0x46]), // "%PDF"
  "application/zip": (b) => startsWith(b, [0x50, 0x4b, 0x03, 0x04]) || startsWith(b, [0x50, 0x4b, 0x05, 0x06]),
  // .docx is a zip container under the hood.
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document": (b) =>
    startsWith(b, [0x50, 0x4b, 0x03, 0x04]),
  "application/msword": (b) => startsWith(b, [0xd0, 0xcf, 0x11, 0xe0]), // legacy OLE2 .doc
  "audio/mpeg": (b) =>
    startsWith(b, [0x49, 0x44, 0x33]) || startsWith(b, [0xff, 0xfb]) || startsWith(b, [0xff, 0xf3]) || startsWith(b, [0xff, 0xf2]),
  "audio/mp3": (b) =>
    startsWith(b, [0x49, 0x44, 0x33]) || startsWith(b, [0xff, 0xfb]) || startsWith(b, [0xff, 0xf3]) || startsWith(b, [0xff, 0xf2]),
  "video/mp4": (b) => b.slice(4, 8).toString("ascii") === "ftyp",
  "video/mpeg": (b) => startsWith(b, [0x00, 0x00, 0x01]),
  "video/x-matroska": (b) => startsWith(b, [0x1a, 0x45, 0xdf, 0xa3]),
};

export const verifyFileSignature = (file: Express.Multer.File): void => {
  const extensionMatch = file.originalname.toLowerCase().match(/\.[^.]+$/);
  const extension = extensionMatch ? extensionMatch[0] : "";
  if (DANGEROUS_EXTENSIONS.includes(extension)) {
    throw new Error("This file type isn't allowed.");
  }

  const check = SIGNATURES[file.mimetype];
  if (!check) {
    // No signature defined for an otherwise-allowed type - fail closed
    // rather than silently skip verification for anything unrecognized.
    throw new Error("Couldn't verify this file's contents.");
  }
  if (!check(file.buffer)) {
    throw new Error("This file's contents don't match its declared type.");
  }
};
