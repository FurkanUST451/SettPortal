import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import '../../core/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());

    return AdminScaffold(
      title: 'Dashboard',
      actions: [
        Obx(
          () => IconButton(
            tooltip: 'Yenile',
            icon: c.loading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: c.loading.value ? null : c.reload,
          ),
        ),
      ],
      body: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!c.loading.value && !c.mfaEnrolled.value) _MfaNudgeBanner(),
            if (!c.loading.value && !c.mfaEnrolled.value)
              const SizedBox(height: 16),
            Expanded(child: _StatsGrid(c: c)),
          ],
        );
      }),
    );
  }
}

class _MfaNudgeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warning.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Hesabında iki adımlı doğrulama (2FA) kurulu değil. '
                'Şifren ele geçirilirse tek başına bir engel kalmıyor.',
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.security),
              child: const Text('Şimdi Kur'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final DashboardController c;
  const _StatsGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.maxWidth) {
          > 1000 => 4,
          > 700 => 2,
          _ => 1,
        };
        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: _cards(),
        );
      },
    );
  }

  List<Widget> _cards() {
    return [
      _StatCard(
        label: 'Toplam Kullanıcı',
        value: c.totalUsers.value,
        icon: Icons.people_outline,
        color: AppTheme.primary,
      ),
      _StatCard(
        label: 'Bugünkü Yeni Kayıt',
        value: c.newUsersToday.value,
        icon: Icons.person_add_alt_outlined,
        color: AppTheme.success,
      ),
      _StatCard(
        label: 'Client',
        value: c.totalClients.value,
        icon: Icons.badge_outlined,
        color: AppTheme.primary,
      ),
      _StatCard(
        label: 'Freelancer',
        value: c.totalFreelancers.value,
        icon: Icons.camera_alt_outlined,
        color: const Color(0xFF6C3483),
      ),
      _StatCard(
        label: 'Toplam İş',
        value: c.totalProjects.value,
        icon: Icons.work_outline,
        color: AppTheme.primary,
      ),
      _StatCard(
        label: 'Devam Eden İş',
        value: c.activeProjects.value,
        icon: Icons.autorenew,
        color: AppTheme.warning,
      ),
      _StatCard(
        label: 'Tamamlanan İş',
        value: c.completedProjects.value,
        icon: Icons.check_circle_outline,
        color: AppTheme.success,
      ),
      _StatCard(
        label: 'Flagli İçerik',
        value: c.flaggedWorks.value,
        icon: Icons.flag_outlined,
        color: AppTheme.danger,
      ),
    ];
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              '$value',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
