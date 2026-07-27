import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}

const _navItems = [
  _NavItem('Dashboard', Icons.dashboard_outlined, AppRoutes.dashboard),
  _NavItem('Kullanıcılar', Icons.people_outline, AppRoutes.users),
  _NavItem('İşler', Icons.work_outline, AppRoutes.jobs),
  _NavItem('İçerik Moderasyonu', Icons.flag_outlined, AppRoutes.moderation),
  _NavItem('Konuşmalar', Icons.chat_outlined, AppRoutes.conversations),
  _NavItem('Audit Log', Icons.history, AppRoutes.auditLog),
  _NavItem('Güvenlik', Icons.security_outlined, AppRoutes.security),
];

/// Shared shell for every authenticated screen: a fixed left navigation
/// column plus a top bar with the signed-in admin's email and sign-out.
class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    final auth = Get.find<AuthService>();

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            color: AppTheme.sidebarBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'SET Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                for (final item in _navItems)
                  _NavTile(
                    item: item,
                    selected:
                        currentRoute.startsWith(item.route) &&
                        (item.route != AppRoutes.dashboard ||
                            currentRoute == AppRoutes.dashboard),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () async {
                          await auth.signOut();
                          Get.offAllNamed(AppRoutes.login);
                        },
                        icon: const Icon(
                          Icons.logout,
                          size: 16,
                          color: Colors.white70,
                        ),
                        label: const Text(
                          'Çıkış Yap',
                          style: TextStyle(color: Colors.white70),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      ...?actions,
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool selected;

  const _NavTile({required this.item, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: () => Get.offAllNamed(item.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: selected ? Colors.white : Colors.white60,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white60,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
