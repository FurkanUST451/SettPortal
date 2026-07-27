/**
 * One-time LOCAL script to enable TOTP-based multi-factor authentication at
 * the project level.
 *
 * Firebase Console's UI only exposes a toggle for SMS-based MFA (Identity
 * Platform → MFA → "SMS based Multi-Factor Authentication") — there's no
 * console option for TOTP. It has to be turned on via the Admin SDK's
 * projectConfigManager, which is what this does. Without running this once,
 * the panel's "Güvenlik" 2FA enrollment fails with:
 *   FirebaseError: Firebase: TOTP based MFA not enabled. (auth/operation-not-allowed)
 *
 * Uses the same service account key as bootstrap_admin.js.
 *
 * Usage: node scripts/enable_totp_mfa.js
 */
const admin = require("firebase-admin");
const path = require("path");

let serviceAccount;
try {
  serviceAccount = require(path.join(__dirname, "serviceAccountKey.json"));
} catch {
  console.error(
    "scripts/serviceAccountKey.json bulunamadı. bootstrap_admin.js için " +
      "kullandığın aynı dosya bu klasörde olmalı."
  );
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

(async () => {
  await admin.auth().projectConfigManager().updateProjectConfig({
    multiFactorConfig: {
      state: "ENABLED",
      providerConfigs: [
        {
          state: "ENABLED",
          totpProviderConfig: {
            adjacentIntervals: 5,
          },
        },
      ],
    },
  });
  console.log("TOTP tabanlı MFA proje seviyesinde etkinleştirildi.");
  console.log(
    "Panelde 'Güvenlik' ekranına dönüp '2FA Kurulumunu Başlat' butonuna " +
      "tekrar tıklayabilirsin."
  );
  process.exit(0);
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
