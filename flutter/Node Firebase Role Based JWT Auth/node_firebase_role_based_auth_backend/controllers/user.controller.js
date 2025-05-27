const admin = require("../config/firebase");

const db = admin.firestore();
const USERS_COLLECTION = "Users_role";

exports.getProfile = async (req, res) => {
  const { phone } = req.user;
  const userDoc = await db.collection(USERS_COLLECTION).doc(phone).get();
  if (!userDoc.exists) {
    return res.status(404).json({ error: "User not found" });
  }
  const { name, email, role } = userDoc.data();
  res.status(200).json({ phone, name, email, role });
};
