const express = require("express");
const userRouter = express.Router();
const userController = require("../controllers/user.controller");
const { verifyToken } = require("../middleware/auth.middleware");

userRouter.get("/profile", verifyToken, userController.getProfile);

module.exports = userRouter;
