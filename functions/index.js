const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();
// Same region as the mobile app's existing Cloud Function (onNewChatMessage)
// so all functions for this project live in one place.
//
// Once the panel's Web app is registered for App Check (Firebase Console →
// App Check → Apps) and lib/core/constants.dart's real reCAPTCHA site key is
// wired in and confirmed working, each `onCall` below can take a second
// options argument `{ enforceAppCheck: true }` to reject calls without a
// valid App Check token. Left off for now since enforcing it before the
// client actually sends valid tokens would just break every button in the panel.
setGlobalOptions({ region: "europe-west1" });

const db = admin.firestore();
const auth = admin.auth();

/** Throws if the caller isn't signed in with the `admin` custom claim. */
function assertIsAdmin(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Giriş yapmanız gerekiyor.");
  }
  if (request.auth.token.admin !== true) {
    throw new HttpsError("permission-denied", "Bu işlem için admin yetkisi gerekiyor.");
  }
  return request.auth;
}

function writeAuditLog({ adminUid, adminEmail, action, targetType, targetId, metadata }) {
  return db.collection("auditLogs").add({
    adminUid,
    adminEmail: adminEmail || null,
    action,
    targetType: targetType || null,
    targetId: targetId || null,
    metadata: metadata || {},
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Grants or revokes the `admin` custom claim on another user. Only callable
 * by an existing admin — the very first admin has to be granted out-of-band
 * via functions/scripts/bootstrap_admin.js, run locally with a service
 * account key, since there's no admin yet to call this function.
 */
exports.setAdminRole = onCall(async (request) => {
  const caller = assertIsAdmin(request);
  const { uid, isAdmin } = request.data || {};
  if (!uid || typeof isAdmin !== "boolean") {
    throw new HttpsError("invalid-argument", "uid ve isAdmin (boolean) gerekli.");
  }
  if (uid === caller.uid && isAdmin === false) {
    throw new HttpsError("failed-precondition", "Kendi admin yetkinizi kaldıramazsınız.");
  }

  const target = await auth.getUser(uid);
  await auth.setCustomUserClaims(uid, { ...(target.customClaims || {}), admin: isAdmin });

  await writeAuditLog({
    adminUid: caller.uid,
    adminEmail: caller.token.email,
    action: isAdmin ? "promote_admin" : "demote_admin",
    targetType: "user",
    targetId: uid,
  });
  return { success: true };
});

/**
 * Lists every user currently holding the `admin` custom claim. Firebase
 * custom claims aren't queryable from Firestore or listed anywhere in the
 * client SDK — this has to walk every Auth user via the Admin SDK, which is
 * why it's a Cloud Function rather than a Firestore read.
 */
exports.listAdmins = onCall(async (request) => {
  assertIsAdmin(request);

  const admins = [];
  let pageToken;
  do {
    const result = await auth.listUsers(1000, pageToken);
    for (const userRecord of result.users) {
      if (userRecord.customClaims && userRecord.customClaims.admin === true) {
        admins.push({
          uid: userRecord.uid,
          email: userRecord.email || null,
          disabled: userRecord.disabled,
        });
      }
    }
    pageToken = result.pageToken;
  } while (pageToken);

  return { admins };
});

/** Disables the Firebase Auth account and mirrors the ban onto the Firestore
 * user doc (`banned`/`bannedAt`/`banReason`) so the panel and, eventually,
 * the mobile app can display/check it cheaply without an Admin SDK call. */
exports.banUser = onCall(async (request) => {
  const caller = assertIsAdmin(request);
  const { uid, reason } = request.data || {};
  if (!uid) throw new HttpsError("invalid-argument", "uid gerekli.");

  await auth.updateUser(uid, { disabled: true });
  await db.collection("users").doc(uid).set(
    {
      banned: true,
      bannedAt: new Date().toISOString(),
      banReason: reason || null,
    },
    { merge: true }
  );

  await writeAuditLog({
    adminUid: caller.uid,
    adminEmail: caller.token.email,
    action: "ban_user",
    targetType: "user",
    targetId: uid,
    metadata: { reason: reason || null },
  });
  return { success: true };
});

exports.unbanUser = onCall(async (request) => {
  const caller = assertIsAdmin(request);
  const { uid } = request.data || {};
  if (!uid) throw new HttpsError("invalid-argument", "uid gerekli.");

  await auth.updateUser(uid, { disabled: false });
  await db.collection("users").doc(uid).set(
    { banned: false, bannedAt: null, banReason: null },
    { merge: true }
  );

  await writeAuditLog({
    adminUid: caller.uid,
    adminEmail: caller.token.email,
    action: "unban_user",
    targetType: "user",
    targetId: uid,
  });
  return { success: true };
});

exports.flagWork = onCall(async (request) => {
  const caller = assertIsAdmin(request);
  const { workId, reason } = request.data || {};
  if (!workId) throw new HttpsError("invalid-argument", "workId gerekli.");

  await db.collection("works").doc(workId).set(
    {
      flagged: true,
      flaggedReason: reason || null,
      flaggedAt: new Date().toISOString(),
    },
    { merge: true }
  );

  await writeAuditLog({
    adminUid: caller.uid,
    adminEmail: caller.token.email,
    action: "flag_work",
    targetType: "work",
    targetId: workId,
    metadata: { reason: reason || null },
  });
  return { success: true };
});

exports.unflagWork = onCall(async (request) => {
  const caller = assertIsAdmin(request);
  const { workId } = request.data || {};
  if (!workId) throw new HttpsError("invalid-argument", "workId gerekli.");

  await db.collection("works").doc(workId).set(
    { flagged: false, flaggedReason: null, flaggedAt: null },
    { merge: true }
  );

  await writeAuditLog({
    adminUid: caller.uid,
    adminEmail: caller.token.email,
    action: "unflag_work",
    targetType: "work",
    targetId: workId,
  });
  return { success: true };
});

/** Deletes a work doc AND its comments/likes subcollections. */
exports.deleteWork = onCall(async (request) => {
  const caller = assertIsAdmin(request);
  const { workId } = request.data || {};
  if (!workId) throw new HttpsError("invalid-argument", "workId gerekli.");

  await db.recursiveDelete(db.collection("works").doc(workId));

  await writeAuditLog({
    adminUid: caller.uid,
    adminEmail: caller.token.email,
    action: "delete_work",
    targetType: "work",
    targetId: workId,
  });
  return { success: true };
});

exports.deleteWorkComment = onCall(async (request) => {
  const caller = assertIsAdmin(request);
  const { workId, commentId } = request.data || {};
  if (!workId || !commentId) {
    throw new HttpsError("invalid-argument", "workId ve commentId gerekli.");
  }

  await db.collection("works").doc(workId).collection("comments").doc(commentId).delete();

  await writeAuditLog({
    adminUid: caller.uid,
    adminEmail: caller.token.email,
    action: "delete_work_comment",
    targetType: "work_comment",
    targetId: `${workId}/${commentId}`,
  });
  return { success: true };
});

exports.deleteWorkLike = onCall(async (request) => {
  const caller = assertIsAdmin(request);
  const { workId, likeId } = request.data || {};
  if (!workId || !likeId) {
    throw new HttpsError("invalid-argument", "workId ve likeId gerekli.");
  }

  await db.collection("works").doc(workId).collection("likes").doc(likeId).delete();

  await writeAuditLog({
    adminUid: caller.uid,
    adminEmail: caller.token.email,
    action: "delete_work_like",
    targetType: "work_like",
    targetId: `${workId}/${likeId}`,
  });
  return { success: true };
});
