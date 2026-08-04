import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/brief_detail_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../models/brief.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/confirm_action_dialog.dart';
import '../../widgets/status_badge.dart';

class BriefDetailScreen extends StatefulWidget {
  const BriefDetailScreen({super.key});

  @override
  State<BriefDetailScreen> createState() => _BriefDetailScreenState();
}

class _BriefDetailScreenState extends State<BriefDetailScreen> {
  late final String briefId;
  late final BriefDetailController controller;

  @override
  void initState() {
    super.initState();
    briefId = Get.arguments as String;
    controller = Get.put(BriefDetailController(briefId), tag: briefId);
  }

  @override
  void dispose() {
    Get.delete<BriefDetailController>(tag: briefId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return AdminScaffold(
      title: 'Brief Detayı',
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final brief = controller.brief.value;
        if (brief == null) {
          return const Center(child: Text('Brief bulunamadı.'));
        }
        final owner = controller.owner.value;

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
                            Expanded(
                              child: Text(
                                brief.title.isEmpty
                                    ? 'Başlıksız Brief'
                                    : brief.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusBadge.briefStatus(brief.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoRow('Brief ID', brief.id),
                        _InfoRow(
                          'Sahibi',
                          owner == null
                              ? brief.ownerId
                              : (owner.fullName.isEmpty
                                    ? owner.email
                                    : owner.fullName),
                          onTap: owner == null
                              ? null
                              : () => Get.toNamed(
                                  AppRoutes.userDetail,
                                  arguments: owner.id,
                                ),
                        ),
                        _InfoRow('Kategori', brief.category),
                        _InfoRow(
                          'Oluşturulma',
                          brief.createdAt != null
                              ? dateFmt.format(brief.createdAt!)
                              : '—',
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            Obx(
                              () => OutlinedButton.icon(
                                onPressed: controller.actionLoading.value
                                    ? null
                                    : () => _onEditPressed(brief),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Düzenle'),
                              ),
                            ),
                            Obx(
                              () => OutlinedButton.icon(
                                onPressed: controller.actionLoading.value
                                    ? null
                                    : _onDeletePressed,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.danger,
                                ),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Sil'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (brief.answers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cevaplar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...brief.answers.entries.map(
                            (e) => _InfoRow(e.key, '${e.value}'),
                          ),
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
                          'Gönderilen Freelancerlar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (brief.sentToIds.isEmpty)
                          const Text(
                            'Bu brief henüz kimseye gönderilmemiş.',
                            style: TextStyle(color: Colors.black54),
                          )
                        else
                          Obx(
                            () => Column(
                              children: controller.sentTo
                                  .map((u) => _UserRow(user: u))
                                  .toList(),
                            ),
                          ),
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

  Future<void> _onEditPressed(Brief brief) async {
    final result = await _showEditBriefDialog(brief);
    if (result != null) {
      await controller.saveEdits(
        title: result.title,
        category: result.category,
        status: result.status,
      );
    }
  }

  Future<void> _onDeletePressed() async {
    final confirmed = await showConfirmActionDialog(
      title: 'Brief\'i Sil',
      message:
          'Bu briefi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
      confirmLabel: 'Sil',
      confirmColor: AppTheme.danger,
    );
    if (confirmed != null) {
      await controller.delete();
      Get.back();
    }
  }
}

class _BriefEditResult {
  final String title;
  final String category;
  final String status;
  const _BriefEditResult(this.title, this.category, this.status);
}

Future<_BriefEditResult?> _showEditBriefDialog(Brief brief) async {
  final titleController = TextEditingController(text: brief.title);
  final categoryController = TextEditingController(text: brief.category);
  final status = RxString(brief.status);
  const statusOptions = [
    BriefStatus.draft,
    BriefStatus.submitted,
    BriefStatus.offerSent,
    BriefStatus.cancelled,
  ];

  final result = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Brief\'i Düzenle'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Başlık'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: status.value,
                decoration: const InputDecoration(labelText: 'Durum'),
                items: statusOptions
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(_briefStatusLabel(s)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) status.value = v;
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Kaydet'),
        ),
      ],
    ),
  );

  if (result != true) return null;
  return _BriefEditResult(
    titleController.text.trim(),
    categoryController.text.trim(),
    status.value,
  );
}

String _briefStatusLabel(String status) {
  switch (status) {
    case BriefStatus.submitted:
      return 'Anlaşma Bekliyor';
    case BriefStatus.offerSent:
      return 'Teklif Gönderildi';
    case BriefStatus.cancelled:
      return 'İptal Edildi';
    case BriefStatus.draft:
    default:
      return 'Taslak';
  }
}

class _UserRow extends StatelessWidget {
  final AppUser user;
  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.userDetail, arguments: user.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                user.fullName.isEmpty ? user.email : user.fullName,
              ),
            ),
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
  final VoidCallback? onTap;
  const _InfoRow(this.label, this.value, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      style: onTap == null
          ? null
          : const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: onTap == null
                ? valueWidget
                : InkWell(onTap: onTap, child: valueWidget),
          ),
        ],
      ),
    );
  }
}
