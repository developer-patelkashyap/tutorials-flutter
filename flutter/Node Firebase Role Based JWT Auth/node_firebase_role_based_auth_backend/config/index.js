const express = require("express");
const cors = require("cors");
require("dotenv").config();

const authRoutes = require("../routes/auth.routes");
const userRoutes = require("../routes/user.routes");

const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());
app.use(cors({ origin: "*" }));

app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
