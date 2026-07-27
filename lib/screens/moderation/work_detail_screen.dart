import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/work_detail_controller.dart';
import '../../core/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/confirm_action_dialog.dart';
import '../../widgets/status_badge.dart';

class WorkDetailScreen extends StatefulWidget {
  const WorkDetailScreen({super.key});

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  late final String workId;
  late final WorkDetailController controller;

  @override
  void initState() {
    super.initState();
    workId = Get.arguments as String;
    controller = Get.put(WorkDetailController(workId), tag: workId);
  }

  @override
  void dispose() {
    Get.delete<WorkDetailController>(tag: workId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return AdminScaffold(
      title: 'İçerik Detayı',
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final work = controller.work.value;
        if (work == null) {
          return const Center(child: Text('İçerik bulunamadı.'));
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                work.title.isEmpty ? '—' : work.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusBadge.flagged(work.flagged),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoRow('İçerik ID', work.id),
                        _InfoRow('Stüdyo', work.studio),
                        _InfoRow('Tür', work.type),
                        _InfoRow('Freelancer ID', work.freelancerId ?? '—'),
                        _InfoRow(
                          'Yüklenme Tarihi',
                          work.createdAt != null
                              ? dateFmt.format(work.createdAt!)
                              : '—',
                        ),
                        if (work.flagged) ...[
                          _InfoRow('Flag Nedeni', work.flaggedReason ?? '—'),
                          _InfoRow(
                            'Flaglenme Tarihi',
                            work.flaggedAt != null
                                ? dateFmt.format(work.flaggedAt!)
                                : '—',
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Text(
                          'Açıklama',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          work.description?.isNotEmpty == true
                              ? work.description!
                              : '—',
                        ),
                        if (work.mediaUrl != null) ...[
                          const SizedBox(height: 16),
                          SelectableText(
                            work.mediaUrl!,
                            style: const TextStyle(color: AppTheme.primary),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            Obx(
                              () => OutlinedButton.icon(
                                onPressed: controller.actionLoading.value
                                    ? null
                                    : () => _onFlagUnflagPressed(work.flagged),
                                icon: Icon(
                                  work.flagged
                                      ? Icons.flag_outlined
                                      : Icons.flag,
                                ),
                                label: Text(
                                  work.flagged ? 'Flag Kaldır' : 'Flagle',
                                ),
                              ),
                            ),
                            Obx(
                              () => FilledButton.icon(
                                onPressed: controller.actionLoading.value
                                    ? null
                                    : _onDeletePressed,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.danger,
                                ),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('İçeriği Kaldır'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Yorumlar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: Obx(() {
                              if (controller.comments.isEmpty) {
                                return const Center(child: Text('Yorum yok.'));
                              }
                              return ListView.separated(
                                itemCount: controller.comments.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final comment = controller.comments[i];
                                  return ListTile(
                                    title: Text(comment.text),
                                    subtitle: Text(
                                      '${comment.userName ?? comment.userId} · '
                                      '${comment.createdAt != null ? dateFmt.format(comment.createdAt!) : '—'}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppTheme.danger,
                                      ),
                                      onPressed: () =>
                                          _onDeleteComment(comment.id),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Beğeniler',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: Obx(() {
                              if (controller.likes.isEmpty) {
                                return const Center(child: Text('Beğeni yok.'));
                              }
                              return ListView.separated(
                                itemCount: controller.likes.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final like = controller.likes[i];
                                  return ListTile(
                                    title: Text(like.userId),
                                    subtitle: Text(
                                      like.createdAt != null
                                          ? dateFmt.format(like.createdAt!)
                                          : '—',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppTheme.danger,
                                      ),
                                      onPressed: () =>
                                          controller.deleteLike(like.id),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _onFlagUnflagPressed(bool currentlyFlagged) async {
    if (currentlyFlagged) {
      final confirmed = await showConfirmActionDialog(
        title: 'Flag Kaldır',
        message:
            'Bu içeriğin flag işaretini kaldırmak istediğinize emin misiniz?',
        confirmLabel: 'Kaldır',
      );
      if (confirmed != null) await controller.unflag();
    } else {
      final reason = await showConfirmActionDialog(
        title: 'İçeriği Flagle',
        message: 'Bu içerik incelemeye alınacak.',
        requireReason: true,
        confirmLabel: 'Flagle',
        confirmColor: AppTheme.warning,
      );
      if (reason != null) await controller.flag(reason);
    }
  }

  Future<void> _onDeletePressed() async {
    final reason = await showConfirmActionDialog(
      title: 'İçeriği Kaldır',
      message: 'Bu içerik kalıcı olarak kaldırılacak. Bu işlem geri alınamaz.',
      confirmLabel: 'Kaldır',
      confirmColor: AppTheme.danger,
    );
    if (reason == null) return;
    await controller.deleteWork();
    Get.offNamed(AppRoutes.moderation);
  }

  Future<void> _onDeleteComment(String commentId) async {
    final confirmed = await showConfirmActionDialog(
      title: 'Yorumu Sil',
      message: 'Bu yorum kalıcı olarak silinecek.',
      confirmLabel: 'Sil',
      confirmColor: AppTheme.danger,
    );
    if (confirmed != null) await controller.deleteComment(commentId);
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
            width: 140,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
