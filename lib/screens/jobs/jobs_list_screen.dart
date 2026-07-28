import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/jobs_controller.dart';
import '../../core/constants.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/scrollable_data_table.dart';
import '../../widgets/status_badge.dart';

class JobsListScreen extends StatelessWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(JobsController());
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');
    final currencyFmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return AdminScaffold(
      title: 'İş / Anlaşma Yönetimi',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Durum:'),
              Obx(
                () => DropdownButton<String?>(
                  value: c.statusFilter.value,
                  hint: const Text('Tümü'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tümü')),
                    DropdownMenuItem(
                      value: ProjectStatus.pending,
                      child: Text('Bekliyor'),
                    ),
                    DropdownMenuItem(
                      value: ProjectStatus.active,
                      child: Text('Devam Ediyor'),
                    ),
                    DropdownMenuItem(
                      value: ProjectStatus.completed,
                      child: Text('Tamamlandı'),
                    ),
                    DropdownMenuItem(
                      value: ProjectStatus.cancelled,
                      child: Text('İptal Edildi'),
                    ),
                  ],
                  onChanged: c.setStatusFilter,
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
              if (c.projects.isEmpty) {
                return const Center(child: Text('Kayıt bulunamadı.'));
              }
              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: ScrollableDataTable(
                        columns: const [
                          DataColumn(label: Text('Başlık')),
                          DataColumn(label: Text('Bütçe')),
                          DataColumn(label: Text('Oluşturulma')),
                          DataColumn(label: Text('Teslim Tarihi')),
                          DataColumn(label: Text('Durum')),
                        ],
                        rows: c.projects.map((p) {
                          return DataRow(
                            onSelectChanged: (_) => Get.toNamed(
                              AppRoutes.jobDetail,
                              arguments: p.id,
                            ),
                            cells: [
                              DataCell(Text(p.title.isEmpty ? '—' : p.title)),
                              DataCell(Text(currencyFmt.format(p.budget))),
                              DataCell(
                                Text(
                                  p.createdAt != null
                                      ? dateFmt.format(p.createdAt!)
                                      : '—',
                                ),
                              ),
                              DataCell(
                                Text(
                                  p.deadline != null
                                      ? dateFmt.format(p.deadline!)
                                      : '—',
                                ),
                              ),
                              DataCell(StatusBadge.projectStatus(p.status)),
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
