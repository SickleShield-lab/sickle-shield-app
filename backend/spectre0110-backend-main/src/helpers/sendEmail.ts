import nodemailer from "nodemailer";
import config from "../config";
const isSmtpConfigured = () =>
  !!config.emailSender.email &&
  !!config.emailSender.app_pass &&
  config.emailSender.email !== "support@example.com" &&
  config.emailSender.app_pass !== "app-specific-password";

const sendEmail = async (
  to: string,
  subject: string,
  html: string,
  text?: string
) => {
  if (!isSmtpConfigured()) {
    console.log(
      `\n[sendEmail] SMTP not configured — logging email instead of sending it.\nTo: ${to}\nSubject: ${subject}\n${text ?? html}\n`
    );
    return;
  }

  // Create a transporter
  const transporter = nodemailer.createTransport({
    host: "mail.privateemail.com", // for Namecheap PrivateEmail
    port: 465,
    secure: true, // use TLS
    auth: {
      user: config.emailSender.email,
      pass: config.emailSender.app_pass,
    },
  });

  // const transporter = nodemailer.createTransport({
  //   service: "gmail",
  //   port: 587,
  //   secure: false,
  //   auth: {
  //     user: config.emailSender.email,
  //     pass: config.emailSender.app_pass,
  //   },
  // });

  // Email options
  const mailOptions = {
    from: `"Sickle Shield" <${config.emailSender.email}>`,
    to,
    subject,
    html,
    text,
  };
  await transporter.sendMail(mailOptions);
};

export default sendEmail;
