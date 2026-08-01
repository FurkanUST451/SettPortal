import 'package:get/get.dart';

import '../screens/audit_log/audit_log_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/briefs/brief_detail_screen.dart';
import '../screens/conversations/conversation_detail_screen.dart';
import '../screens/conversations/conversations_list_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/jobs/job_detail_screen.dart';
import '../screens/jobs/jobs_list_screen.dart';
import '../screens/moderation/moderation_list_screen.dart';
import '../screens/moderation/work_detail_screen.dart';
import '../screens/offers/offer_detail_screen.dart';
import '../screens/reports/reports_list_screen.dart';
import '../screens/security/security_settings_screen.dart';
import '../screens/users/user_detail_screen.dart';
import '../screens/users/users_list_screen.dart';
import 'app_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      middlewares: [GuestOnlyMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => const UsersListScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.userDetail,
      page: () => const UserDetailScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.jobs,
      page: () => const JobsListScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.jobDetail,
      page: () => const JobDetailScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.briefDetail,
      page: () => const BriefDetailScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.offerDetail,
      page: () => const OfferDetailScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.moderation,
      page: () => const ModerationListScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.workDetail,
      page: () => const WorkDetailScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsListScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.conversations,
      page: () => const ConversationsListScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.conversationDetail,
      page: () => const ConversationDetailScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.auditLog,
      page: () => const AuditLogScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.security,
      page: () => const SecuritySettingsScreen(),
      middlewares: [AdminGuardMiddleware()],
    ),
  ];
}
