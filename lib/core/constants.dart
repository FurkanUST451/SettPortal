/// Firestore collection names shared with the SET mobile app (project sett-451).
/// Keep these in sync with the mobile app's repositories if it ever renames a collection.
class FsCollections {
  static const users = 'users';
  static const freelancers = 'freelancers';
  static const briefs = 'briefs';
  static const offers = 'offers';
  static const projects = 'projects';
  static const chats = 'chats';
  static const messages = 'messages'; // subcollection of chats
  static const works = 'works';
  static const comments = 'comments'; // subcollection of works
  static const likes = 'likes'; // subcollection of works
  static const auditLogs = 'auditLogs';
  static const reports = 'reports';
}

/// Values of `reports.status`, written by the mobile app (create) and by
/// admins reviewing a report (update).
class ReportStatus {
  static const pending = 'pending';
  static const reviewed = 'reviewed';
  static const dismissed = 'dismissed';
}

/// Business role stored on `users.role` by the mobile app. Not an admin permission.
class UserRole {
  static const client = 'client';
  static const freelancer = 'freelancer';
}

class ProjectStatus {
  static const pending = 'pending';
  static const active = 'active';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const all = [pending, active, completed, cancelled];
}

class BriefStatus {
  static const draft = 'draft';
  static const submitted = 'submitted';
  static const offerSent = 'offer_sent';
}

class OfferStatus {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
}

class WorkType {
  static const video = 'video';
  static const photo = 'photo';
  static const cgiVfx = 'cgiVfx';
  static const graphic = 'graphic';
  static const sound = 'sound';
}

/// Action names written to `auditLogs.action`. Kept as plain strings (not a
/// Dart enum) so the audit trail stays readable in Firestore console and new
/// actions can be added without a schema migration.
class AuditAction {
  static const viewConversation = 'view_conversation';
  static const viewUserDetail = 'view_user_detail';
  static const banUser = 'ban_user';
  static const unbanUser = 'unban_user';
  static const flagWork = 'flag_work';
  static const unflagWork = 'unflag_work';
  static const deleteWork = 'delete_work';
  static const deleteWorkComment = 'delete_work_comment';
  static const deleteWorkLike = 'delete_work_like';
  static const promoteAdmin = 'promote_admin';
  static const demoteAdmin = 'demote_admin';
  static const editBrief = 'edit_brief';
  static const deleteBrief = 'delete_brief';
}

/// Firebase App Check config. Get this from Firebase Console → App Check →
/// Apps → the "Web" app entry → Register → reCAPTCHA v3 → copy the site key.
/// Safe to leave as a placeholder until then: App Check enforcement isn't
/// turned on for anything yet, so an invalid/placeholder key just means no
/// attestation token is attached to requests — nothing currently checks for one.
class AppCheckConfig {
  static const _placeholder = 'PASTE_YOUR_RECAPTCHA_V3_SITE_KEY_HERE';
  static const recaptchaV3SiteKey = _placeholder;

  /// False until the placeholder above is replaced with a real site key.
  /// main.dart uses this to skip activation entirely rather than attempt it
  /// with a key that can't possibly work.
  static bool get isConfigured => recaptchaV3SiteKey != _placeholder;
}

/// Names of the deployed callable Cloud Functions (see functions/index.js).
class CallableFunctions {
  static const setAdminRole = 'setAdminRole';
  static const listAdmins = 'listAdmins';
  static const banUser = 'banUser';
  static const unbanUser = 'unbanUser';
  static const flagWork = 'flagWork';
  static const unflagWork = 'unflagWork';
  static const deleteWork = 'deleteWork';
  static const deleteWorkComment = 'deleteWorkComment';
  static const deleteWorkLike = 'deleteWorkLike';
}
