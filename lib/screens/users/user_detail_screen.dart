import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/user_detail_controller.dart';
import '../../core/theme.dart';
import '../../models/brief.dart';
import '../../models/chat.dart';
import '../../models/offer.dart';
import '../../models/project.dart';
import '../../routes/app_routes.dart';
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
        if (controller.error.value != null) {
          return Center(
            child: Text(
              'Kullanıcı yüklenemedi: ${controller.error.value}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
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
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Briefler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.briefsLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          if (controller.briefs.isEmpty) {
                            return const Text(
                              'Bu kullanıcıya ait brief bulunamadı.',
                              style: TextStyle(color: Colors.black54),
                            );
                          }
                          return Column(
                            children: controller.briefs
                                .map((b) => _BriefRow(brief: b))
                                .toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'İş Teklifleri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.offersLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          if (controller.offers.isEmpty) {
                            return const Text(
                              'Bu kullanıcıya ait iş teklifi bulunamadı.',
                              style: TextStyle(color: Colors.black54),
                            );
                          }
                          return Column(
                            children: controller.offers
                                .map((o) => _OfferRow(offer: o))
                                .toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aktif İşler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.projectsLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          if (controller.projects.isEmpty) {
                            return const Text(
                              'Bu kullanıcıya ait iş bulunamadı.',
                              style: TextStyle(color: Colors.black54),
                            );
                          }
                          return Column(
                            children: controller.projects
                                .map((p) => _ProjectRow(project: p))
                                .toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Konuşmalar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Bu kullanıcının dahil olduğu sohbetler. Açılan '
                          'konuşmalar audit log\'a kaydedilir.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.chatsLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          if (controller.chats.isEmpty) {
                            return const Text(
                              'Bu kullanıcıya ait sohbet bulunamadı.',
                              style: TextStyle(color: Colors.black54),
                            );
                          }
                          return Column(
                            children: controller.chats
                                .map(
                                  (chat) =>
                                      _ChatRow(chat: chat, currentUid: uid),
                                )
                                .toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
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

class _ChatRow extends StatelessWidget {
  final Chat chat;
  final String currentUid;
  const _ChatRow({required this.chat, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    final peerName = chat.clientId == currentUid
        ? chat.freelancerName
        : chat.clientName;
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.conversationDetail, arguments: chat.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peerName.isEmpty ? 'Bilinmeyen kullanıcı' : peerName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (chat.briefTitle.isNotEmpty)
                    Text(
                      chat.briefTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  if (chat.lastMessage?.isNotEmpty == true)
                    Text(
                      chat.lastMessage!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              (chat.lastMessageAt ?? chat.createdAt) != null
                  ? dateFmt.format((chat.lastMessageAt ?? chat.createdAt)!)
                  : '—',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _BriefRow extends StatelessWidget {
  final Brief brief;
  const _BriefRow({required this.brief});

  String? get _notePreview {
    final notes = brief.answers['notes'];
    if (notes is! String || notes.trim().isEmpty) return null;
    final words = notes.trim().split(RegExp(r'\s+'));
    const wordLimit = 8;
    final preview = words.take(wordLimit).join(' ');
    return words.length > wordLimit ? '$preview…' : preview;
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.briefDetail, arguments: brief.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brief.title.isEmpty ? 'Başlıksız Brief' : brief.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (brief.category.isNotEmpty)
                    Text(
                      brief.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  if (_notePreview != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _notePreview!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            StatusBadge.briefStatus(brief.status),
            const SizedBox(width: 12),
            Text(
              brief.createdAt != null
                  ? dateFmt.format(brief.createdAt!)
                  : '—',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  final Offer offer;
  const _OfferRow({required this.offer});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');
    final currencyFmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.offerDetail, arguments: offer.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.briefTitle.isEmpty
                        ? 'Başlıksız Teklif'
                        : offer.briefTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    currencyFmt.format(offer.amount),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge.offerStatus(offer.status),
            const SizedBox(width: 12),
            Text(
              offer.createdAt != null
                  ? dateFmt.format(offer.createdAt!)
                  : '—',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final Project project;
  const _ProjectRow({required this.project});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');
    final currencyFmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.jobDetail, arguments: project.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title.isEmpty ? 'Başlıksız İş' : project.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    currencyFmt.format(project.budget),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge.projectStatus(project.status),
            const SizedBox(width: 12),
            Text(
              project.createdAt != null
                  ? dateFmt.format(project.createdAt!)
                  : '—',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
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
