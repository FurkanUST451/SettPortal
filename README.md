# SET Admin Portal

Flutter Web admin panel for the SET video-production marketplace. Separate
codebase from the SET mobile app, but connects to the **same** Firebase
project (`sett-451`) — Auth, Firestore, Storage.

## Stack

- Flutter Web, GetX for state management/routing (matches the mobile app's stack)
- Firebase Auth / Cloud Firestore / Cloud Storage — client SDK, mostly reads
- Cloud Functions (Node 20, Admin SDK) for every destructive/sensitive action

## Security model

- Admin access is gated by a Firebase Auth **custom claim** (`admin: true`),
  never a Firestore field — see `lib/services/auth_service.dart`.
- `firestore.rules` only grants admins extra **read** access. Every write
  (ban, delete, flag, promote/demote admin) goes through a Cloud Function
  using the Admin SDK, which bypasses security rules entirely — the client
  never writes those fields directly.
- Every admin action is recorded in `auditLogs` (append-only, even admins
  can't edit/delete an entry from the client): destructive actions are
  logged server-side by the Cloud Function that performs them; viewing a
  conversation or a user's detail page is logged client-side via
  `AuditLogService`.
- Admins can enroll a **TOTP 2FA** second factor (Google Authenticator, Authy,
  etc.) from the panel's "Güvenlik" screen — see `lib/services/auth_service.dart`
  (`startTotpEnrollment`/`confirmTotpEnrollment`) and
  `lib/screens/security/security_settings_screen.dart`. Not enforced (an admin
  can use the panel without it — the dashboard just nags until it's set up),
  since forcing it could lock out the only admin before Console-side MFA is
  even enabled. See "First-time Firebase setup" below for the one Console
  toggle this needs.
- **Firebase App Check** is wired into the client (`lib/main.dart`,
  `firebase_app_check` package) but not yet configured — see "App Check" below.

## Project layout

```
lib/
  core/         constants (collection names, enums) + theme
  models/       Firestore document models, mirroring the mobile app's schema
  repositories/ Firestore reads: pagination, filters, counts
  services/     AuthService, FunctionsService, AuditLogService
  controllers/  one GetX controller per screen
  screens/      UI, grouped by feature (auth, dashboard, users, jobs, ...)
  routes/       route table + AdminGuardMiddleware
functions/
  index.js      callable Cloud Functions (setAdminRole, banUser, ...)
  scripts/      bootstrap_admin.js — one-time local admin bootstrap
firestore.rules, firestore.indexes.json, firebase.json, .firebaserc
```

## Running locally

```bash
flutter pub get
flutter run -d chrome
```

(There's also `.claude/launch.json` with a `flutter-web` config for previewing
inside Claude Code.)

## First-time Firebase setup

Nothing admin-related exists in `sett-451` yet — no admin accounts, no
deployed rules/functions for this panel. One-time setup:

**1. Deploy Firestore rules + indexes**

```bash
firebase login
firebase deploy --only firestore:rules,firestore:indexes
```

**2. Deploy the Cloud Functions**

```bash
cd functions
npm install
firebase deploy --only functions:admin
```

The codebase is named `"admin"` in `firebase.json` (not `"default"`) so this
deploy can't accidentally delete the mobile app's existing `onNewChatMessage`
function if that's ever deployed from a different codebase/repo.

**3. Bootstrap the first admin**

No admin exists yet, so nobody can call `setAdminRole` to create one — this
has to happen outside the app, once, with a service account key:

```bash
# Firebase Console → sett-451 → Project settings → Service accounts →
# "Generate new private key" → save as functions/scripts/serviceAccountKey.json
# (already gitignored — never commit it)
cd functions
node scripts/bootstrap_admin.js you@example.com
```

That account can now sign in to the panel. It can also grant/revoke the
`admin` claim on other accounts by calling the `setAdminRole` Cloud Function
directly (there's no settings screen for this yet — see below).

**4. Enable TOTP multi-factor auth (for the 2FA screen to work)**

Firebase Console → `sett-451` → Authentication → Sign-in method → Advanced →
Multi-factor authentication → enable **TOTP**. Without this, enrollment in
the panel's "Güvenlik" screen will fail with an error from Firebase, even
though the panel itself loads fine.

## App Check

You mentioned App Check is already set up for the mobile app to stop
scripted mass-downloading from the Keşfet feed — but the "Web" app entry
(the one this admin panel's Firebase config reuses) currently shows a
**Register** button in Firebase Console → App Check → Apps, meaning it isn't
registered yet, and nothing is enforced for it. Two steps to actually turn
this on for the panel:

**1. Register the Web app**

Firebase Console → App Check → Apps → find the **Web** app → Register →
choose **reCAPTCHA v3** → copy the site key it gives you.

**2. Wire the site key into the panel**

Paste it into `lib/core/constants.dart`:

```dart
class AppCheckConfig {
  static const _placeholder = 'PASTE_YOUR_RECAPTCHA_V3_SITE_KEY_HERE';
  static const recaptchaV3SiteKey = 'your-real-site-key-here'; // <- edit this
  ...
```

Until you do this, `main.dart` skips activation entirely (deliberately — an
earlier version of this awaited activation unconditionally with the
placeholder key, which hung the app on boot since the reCAPTCHA script can
never load for a key that doesn't exist).

**3. (Later) Turn on enforcement**

Once the site key is real and you've confirmed the panel still loads and
works normally with it in place, you can:
- Firebase Console → App Check → APIs → set Firestore/Functions to
  **Enforced** (start with "Unenforced/Monitor" first to see metrics without
  risking breakage).
- In `functions/index.js`, add `{ enforceAppCheck: true }` as a second
  argument to any `onCall(...)` you want to reject requests without a valid
  App Check token — commented guidance is already there.

Don't flip either of these on before confirming the real site key works —
enforcing before the client can produce valid tokens locks everyone out,
including you.

## Known gaps / assumptions to verify

- **`works/{workId}/comments` and `works/{workId}/likes`**: you mentioned
  this exists in your local build but hasn't been pushed to the shared
  mobile repo yet, so the field names (`userId`, `text`, `createdAt`, ...) in
  `lib/models/work_comment.dart` / `work_like.dart` and in `firestore.rules`
  are inferred, not confirmed. Double-check them against the real
  implementation once it's merged.
- **`users.banned` / `bannedAt` / `banReason`** and **`works.flagged` /
  `flaggedReason` / `flaggedAt`** are new fields this panel introduces,
  written only by Cloud Functions. The mobile app doesn't read them —
  a ban is still enforced because the Cloud Function also disables the
  user's Firebase Auth account, which blocks login/token refresh regardless.
- **`works/{workId}` had no security rules at all** in the mobile app's
  existing `firestore.rules` (falls through to default-deny) — a pre-existing
  gap, not something introduced here. Worth confirming with whoever owns the
  mobile app that the rule block added in this repo matches their actual
  read/write pattern.
- ~~No UI for promoting/demoting other admins~~ — resolved: the "Güvenlik"
  screen lists current admins (via the `listAdmins` Cloud Function) and lets
  you revoke one; the "Kullanıcı Detayı" screen has an "Admin Yetkisi Ver /
  Kaldır" button for granting it to any existing user. `bootstrap_admin.js`
  is now only needed for the very first admin (or if every admin is
  somehow locked out).
- **No "disputed" status** — `projects` only has
  `pending`/`active`/`completed`/`cancelled`; per your call, the job list
  filters on those four only.

## Deploying the panel itself

This is a static Flutter Web build — host it wherever's convenient (Firebase
Hosting is the obvious choice since everything else is already there):

```bash
flutter build web
# add a "hosting" block to firebase.json pointing at build/web, then:
firebase deploy --only hosting
```
