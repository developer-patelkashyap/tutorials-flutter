const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(JSON.parse(process.env.SERVICE_ACCOUNT_KEY)),
    storageBucket: process.env.BUCKET_PATH,
  });
}

module.exports = admin;
