const bcrypt = require("bcrypt");
const admin = require("../config/firebase");
const jwt = require("jsonwebtoken");
// const userSchema = require("../schema/user.schema");
const getCurrentTimeStamp = require("../utils/timestamp.util");

const db = admin.firestore();
const USERS_COLLECTION = "Users_role";
const JWT_SECRET = process.env.JWT_SECRET;
const bucket = admin.storage().bucket();

exports.signup = async (req, res) => {
  try {
    const { phone, name, email, password, role } = req.body;

    if (!req.file) {
      return res.status(400).json({ error: "Photo is required" });
    }

    const userRef = admin.firestore().collection(USERS_COLLECTION).doc(phone);
    const userDoc = await userRef.get();

    if (userDoc.exists) {
      return res.status(409).json({ error: "User already exists" });
    }

    const fileName = `user_photos/${phone}_${getCurrentTimeStamp()}.jpg`;
    const file = bucket.file(fileName);

    const stream = file.createWriteStream({
      metadata: {
        contentType: req.file.mimetype,
      },
    });

    stream.end(req.file.buffer);

    await new Promise((resolve, reject) => {
      stream.on("finish", resolve);
      stream.on("error", reject);
    });

    const [url] = await file.getSignedUrl({
      action: "read",
      expires: "03-09-2491",
    });

    const hashedPassword = await bcrypt.hash(password, 10);

    const userData = {
      phone,
      name,
      email,
      password: hashedPassword,
      role,
      photo: url,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await userRef.set(userData);

    res.status(201).json({
      message: "User created",
      user: { phone, name, email, role, photo: url },
    });
  } catch (err) {
    console.error("Signup Error:", err);
    res.status(500).json({ error: err.message });
  }
};

exports.login = async (req, res) => {
  const { phone, password } = req.body;
  try {
    const userRef = db.collection(USERS_COLLECTION).doc(phone);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = userDoc.data();
    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      return res.status(401).json({ error: "Invalid password" });
    }

    const token = jwt.sign({ phone: user.phone, role: user.role }, JWT_SECRET, {
      expiresIn: "1d",
    });

    res.status(200).json({
      message: "Login successful",
      token,
      user: {
        phone: user.phone,
        name: user.name,
        email: user.email,
        role: user.role,
        photo: user.photo,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
