import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/moderation_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/confirm_action_dialog.dart';
import '../../widgets/scrollable_data_table.dart';
import '../../widgets/status_badge.dart';

class ModerationListScreen extends StatelessWidget {
  const ModerationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ModerationController());
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return AdminScaffold(
      title: 'İçerik Moderasyonu',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Tür:'),
              Obx(
                () => DropdownButton<String?>(
                  value: c.typeFilter.value,
                  hint: const Text('Tümü'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tümü')),
                    DropdownMenuItem(
                      value: WorkType.video,
                      child: Text('Video'),
                    ),
                    DropdownMenuItem(
                      value: WorkType.photo,
                      child: Text('Fotoğraf'),
                    ),
                    DropdownMenuItem(
                      value: WorkType.cgiVfx,
                      child: Text('CGI/VFX'),
                    ),
                    DropdownMenuItem(
                      value: WorkType.graphic,
                      child: Text('Grafik'),
                    ),
                    DropdownMenuItem(value: WorkType.sound, child: Text('Ses')),
                  ],
                  onChanged: c.setTypeFilter,
                ),
              ),
              Obx(
                () => FilterChip(
                  label: const Text('Sadece Flagli'),
                  selected: c.flaggedOnly.value,
                  onSelected: c.setFlaggedOnly,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (c.selectedIds.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _BulkActionBar(c: c),
            );
          }),
          Expanded(
            child: Obx(() {
              if (c.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.works.isEmpty) {
                return const Center(child: Text('Kayıt bulunamadı.'));
              }
              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: ScrollableDataTable(
                        showCheckboxColumn: true,
                        columns: const [
                          DataColumn(label: Text('Başlık')),
                          DataColumn(label: Text('Stüdyo')),
                          DataColumn(label: Text('Tür')),
                          DataColumn(label: Text('Beğeni')),
                          DataColumn(label: Text('Yorum')),
                          DataColumn(label: Text('Tarih')),
                          DataColumn(label: Text('Durum')),
                        ],
                        rows: c.works.map((w) {
                          void openDetail() => Get.toNamed(
                            AppRoutes.workDetail,
                            arguments: w.id,
                          );
                          return DataRow(
                            selected: c.selectedIds.contains(w.id),
                            onSelectChanged: (v) => c.toggleSelection(w.id, v),
                            cells: [
                              DataCell(
                                Text(w.title.isEmpty ? '—' : w.title),
                                onTap: openDetail,
                              ),
                              DataCell(Text(w.studio), onTap: openDetail),
                              DataCell(Text(w.type), onTap: openDetail),
                              DataCell(
                                Text('${w.likeCount}'),
                                onTap: openDetail,
                              ),
                              DataCell(
                                Text('${w.commentCount}'),
                                onTap: openDetail,
                              ),
                              DataCell(
                                Text(
                                  w.createdAt != null
                                      ? dateFmt.format(w.createdAt!)
                                      : '—',
                                ),
                                onTap: openDetail,
                              ),
                              DataCell(
                                StatusBadge.flagged(w.flagged),
                                onTap: openDetail,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    if (c.hasMore.value)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextButton(
                          onPressed: c.loadingMore.value ? null : c.loadMore,
                          child: c.loadingMore.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Daha fazla yükle'),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BulkActionBar extends StatelessWidget {
  final ModerationController c;
  const _BulkActionBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${c.selectedIds.length} seçili'),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: c.bulkActionLoading.value
                    ? null
                    : () => _onBulkFlagPressed(context),
                icon: const Icon(Icons.flag, size: 18),
                label: const Text('Toplu Flagle'),
              ),
              OutlinedButton.icon(
                onPressed: c.bulkActionLoading.value
                    ? null
                    : () => _onBulkUnflagPressed(context),
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: const Text('Toplu Flag Kaldır'),
              ),
              FilledButton.icon(
                onPressed: c.bulkActionLoading.value
                    ? null
                    : () => _onBulkDeletePressed(context),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Toplu Kaldır'),
              ),
              if (c.bulkActionLoading.value)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              TextButton(
                onPressed: c.clearSelection,
                child: const Text('Seçimi Temizle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onBulkFlagPressed(BuildContext context) async {
    final reason = await showConfirmActionDialog(
      title: 'Toplu Flagle',
      message: '${c.selectedIds.length} içerik incelemeye alınacak.',
      requireReason: true,
      confirmLabel: 'Flagle',
      confirmColor: AppTheme.warning,
    );
    if (reason != null) await c.bulkFlag(reason);
  }

  Future<void> _onBulkUnflagPressed(BuildContext context) async {
    final confirmed = await showConfirmActionDialog(
      title: 'Toplu Flag Kaldır',
      message: '${c.selectedIds.length} içeriğin flag işareti kaldırılacak.',
      confirmLabel: 'Kaldır',
    );
    if (confirmed != null) await c.bulkUnflag();
  }

  Future<void> _onBulkDeletePressed(BuildContext context) async {
    final confirmed = await showConfirmActionDialog(
      title: 'Toplu Kaldır',
      message:
          '${c.selectedIds.length} içerik kalıcı olarak kaldırılacak. Bu '
          'işlem geri alınamaz.',
      confirmLabel: 'Kaldır',
      confirmColor: AppTheme.danger,
    );
    if (confirmed != null) await c.bulkDelete();
  }
}
