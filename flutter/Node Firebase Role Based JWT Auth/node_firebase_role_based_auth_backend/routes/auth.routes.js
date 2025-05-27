const express = require("express");
const authRouter = express.Router();
const authController = require("../controllers/auth.controller");
const { verifyToken } = require("../middleware/auth.middleware");

const multer = require("multer");
const storage = multer.memoryStorage();
const upload = multer({ storage });

authRouter.post(
  "/signup",
  verifyToken,
  upload.single("photo"),
  authController.signup
);
authRouter.post("/login", authController.login);

module.exports = authRouter;
