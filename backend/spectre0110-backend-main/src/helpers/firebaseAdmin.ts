import admin from "firebase-admin";
import config from "../config";

const base64 = config.firebase.serviceAccountBase64;

if (!base64) {
  throw new Error(
    "Missing Firebase configuration. Set FIREBASE_SERVICE_ACCOUNT_BASE64 in .env (base64-encoded service account JSON)."
  );
}

const serviceAccount = JSON.parse(
  Buffer.from(base64, "base64").toString("utf-8")
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export default admin;
