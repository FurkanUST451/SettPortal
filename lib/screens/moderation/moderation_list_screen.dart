import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/moderation_controller.dart';
import '../../core/constants.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
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
          Row(
            children: [
              const Text('Tür:'),
              const SizedBox(width: 12),
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
              const SizedBox(width: 24),
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
                      child: SingleChildScrollView(
                        child: DataTable(
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
                            return DataRow(
                              onSelectChanged: (_) => Get.toNamed(
                                AppRoutes.workDetail,
                                arguments: w.id,
                              ),
                              cells: [
                                DataCell(Text(w.title.isEmpty ? '—' : w.title)),
                                DataCell(Text(w.studio)),
                                DataCell(Text(w.type)),
                                DataCell(Text('${w.likeCount}')),
                                DataCell(Text('${w.commentCount}')),
                                DataCell(
                                  Text(
                                    w.createdAt != null
                                        ? dateFmt.format(w.createdAt!)
                                        : '—',
                                  ),
                                ),
                                DataCell(StatusBadge.flagged(w.flagged)),
                              ],
                            );
                          }).toList(),
                        ),
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
