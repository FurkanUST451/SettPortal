import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/user_detail_controller.dart';
import '../../core/theme.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/confirm_action_dialog.dart';
import '../../widgets/status_badge.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late final String uid;
  late final UserDetailController controller;

  @override
  void initState() {
    super.initState();
    uid = Get.arguments as String;
    controller = Get.put(UserDetailController(uid), tag: uid);
  }

  @override
  void dispose() {
    Get.delete<UserDetailController>(tag: uid);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return AdminScaffold(
      title: 'Kullanıcı Detayı',
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = controller.user.value;
        if (user == null) {
          return const Center(child: Text('Kullanıcı bulunamadı.'));
        }
        final freelancer = controller.freelancerProfile.value;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.fullName.isEmpty
                                  ? user.email
                                  : user.fullName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            StatusBadge.role(user.role),
                            const SizedBox(width: 8),
                            StatusBadge.banned(user.banned),
                            Obx(() {
                              if (controller.adminStatusLoading.value ||
                                  !controller.isAdmin.value) {
                                return const SizedBox.shrink();
                              }
                              return const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: StatusBadge(
                                  label: 'Admin',
                                  color: AppTheme.primary,
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoRow('E-posta', user.email),
                        _InfoRow('Kullanıcı ID', user.id),
                        if (user.age != null) _InfoRow('Yaş', '${user.age}'),
                        if (user.gender != null)
                          _InfoRow('Cinsiyet', user.gender!),
                        _InfoRow(
                          'Kayıt Tarihi',
                          user.createdAt != null
                              ? dateFmt.format(user.createdAt!)
                              : '—',
                        ),
                        if (user.banned) ...[
                          _InfoRow(
                            'Yasaklanma Tarihi',
                            user.bannedAt != null
                                ? dateFmt.format(user.bannedAt!)
                                : '—',
                          ),
                          _InfoRow('Yasaklanma Nedeni', user.banReason ?? '—'),
                        ],
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            Obx(
                              () => FilledButton.icon(
                                onPressed: controller.actionLoading.value
                                    ? null
                                    : () => _onBanUnbanPressed(user.banned),
                                style: FilledButton.styleFrom(
                                  backgroundColor: user.banned
                                      ? AppTheme.success
                                      : AppTheme.danger,
                                ),
                                icon: Icon(
                                  user.banned ? Icons.lock_open : Icons.block,
                                ),
                                label: Text(
                                  user.banned
                                      ? 'Yasağı Kaldır'
                                      : 'Hesabı Askıya Al / Yasakla',
                                ),
                              ),
                            ),
                            Obx(
                              () => OutlinedButton.icon(
                                onPressed:
                                    (controller.actionLoading.value ||
                                        controller.adminStatusLoading.value)
                                    ? null
                                    : () => _onToggleAdminPressed(
                                        controller.isAdmin.value,
                                      ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: controller.isAdmin.value
                                      ? AppTheme.danger
                                      : AppTheme.primary,
                                ),
                                icon: Icon(
                                  controller.isAdmin.value
                                      ? Icons.remove_moderator_outlined
                                      : Icons.admin_panel_settings_outlined,
                                ),
                                label: Text(
                                  controller.isAdmin.value
                                      ? 'Admin Yetkisini Kaldır'
                                      : 'Admin Yetkisi Ver',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (freelancer != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Freelancer Profili',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            'Kategoriler',
                            freelancer.categories.join(', '),
                          ),
                          _InfoRow('Deneyim', '${freelancer.experience} yıl'),
                          _InfoRow('Konum', freelancer.location),
                          _InfoRow(
                            'Puan',
                            freelancer.rating.toStringAsFixed(1),
                          ),
                          _InfoRow('Bio', freelancer.bio),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _onBanUnbanPressed(bool currentlyBanned) async {
    if (currentlyBanned) {
      final confirmed = await showConfirmActionDialog(
        title: 'Yasağı Kaldır',
        message:
            'Bu kullanıcının yasağını kaldırmak istediğinize emin misiniz?',
        confirmLabel: 'Yasağı Kaldır',
        confirmColor: AppTheme.success,
      );
      if (confirmed != null) await controller.unban();
    } else {
      final reason = await showConfirmActionDialog(
        title: 'Hesabı Askıya Al',
        message:
            'Bu kullanıcı giriş yapamayacak. Bu işlem audit log\'a kaydedilecek.',
        requireReason: true,
        confirmLabel: 'Askıya Al',
        confirmColor: AppTheme.danger,
      );
      if (reason != null) await controller.ban(reason);
    }
  }

  Future<void> _onToggleAdminPressed(bool currentlyAdmin) async {
    final confirmed = await showConfirmActionDialog(
      title: currentlyAdmin ? 'Admin Yetkisini Kaldır' : 'Admin Yetkisi Ver',
      message: currentlyAdmin
          ? 'Bu kullanıcı artık panele giriş yapamayacak. Emin misin?'
          : 'Bu kullanıcı panele admin olarak giriş yapabilecek ve tüm '
                'yönetici işlemlerini yapabilecek. Emin misin?',
      confirmLabel: currentlyAdmin ? 'Kaldır' : 'Admin Yap',
      confirmColor: currentlyAdmin ? AppTheme.danger : AppTheme.primary,
    );
    if (confirmed != null) await controller.toggleAdmin();
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
