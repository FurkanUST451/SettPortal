/**
 * One-time LOCAL script to grant the very first admin their custom claim.
 * There is no admin yet to call the `setAdminRole` Cloud Function with, so
 * this talks to Firebase Auth directly using a service account key you
 * download yourself — it is never deployed and never runs in the cloud.
 *
 * Setup:
 *   1. Firebase Console → sett-451 → Project settings → Service accounts →
 *      "Generate new private key". Save the downloaded file as
 *      `serviceAccountKey.json` in this same `scripts/` folder.
 *      (.gitignore already excludes it — never commit this file.)
 *   2. From functions/: npm install
 *   3. node scripts/bootstrap_admin.js admin@example.com
 *
 * After running, the admin must sign in (or refresh their session) in the
 * panel for the new claim to take effect — Firebase ID tokens cache claims
 * until the next refresh.
 */
const admin = require("firebase-admin");
const path = require("path");

const email = process.argv[2];
if (!email) {
  console.error("Kullanım: node scripts/bootstrap_admin.js <email>");
  process.exit(1);
}

let serviceAccount;
try {
  serviceAccount = require(path.join(__dirname, "serviceAccountKey.json"));
} catch {
  console.error(
    "scripts/serviceAccountKey.json bulunamadı. Firebase Console > Project " +
      "settings > Service accounts > Generate new private key adımından indirip " +
      "bu klasöre koyun."
  );
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

(async () => {
  const user = await admin.auth().getUserByEmail(email);
  const existingClaims = user.customClaims || {};
  await admin.auth().setCustomUserClaims(user.uid, { ...existingClaims, admin: true });

  // Firebase requires a verified email before enrolling a TOTP second
  // factor. Accounts created manually via the Console (Add user) start
  // unverified, so this fixes that as part of making them an admin.
  if (!user.emailVerified) {
    await admin.auth().updateUser(user.uid, { emailVerified: true });
    console.log(`${email} e-postası doğrulanmış olarak işaretlendi.`);
  }

  console.log(`${email} (uid: ${user.uid}) artık admin.`);
  console.log("Kullanıcının panelde tekrar giriş yapması gerekiyor (token claim'i yeniler).");
  process.exit(0);
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
