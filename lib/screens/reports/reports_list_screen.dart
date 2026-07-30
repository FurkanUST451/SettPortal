import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/reports_controller.dart';
import '../../core/constants.dart';
import '../../models/report.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/scrollable_data_table.dart';
import '../../widgets/status_badge.dart';

const _statusLabels = {
  ReportStatus.pending: 'Bekliyor',
  ReportStatus.reviewed: 'İncelendi',
  ReportStatus.dismissed: 'Reddedildi',
};

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReportsController());
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return AdminScaffold(
      title: 'Bildirimler',
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
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tümü')),
                    ..._statusLabels.entries.map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
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
              if (c.error.value != null) {
                return Center(
                  child: Text(
                    'Bildirimler yüklenemedi: ${c.error.value}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final reports = c.filtered;
              if (reports.isEmpty) {
                return const Center(child: Text('Bildirim bulunamadı.'));
              }
              return Card(
                child: ScrollableDataTable(
                  columns: const [
                    DataColumn(label: Text('Tarih')),
                    DataColumn(label: Text('Bildiren')),
                    DataColumn(label: Text('İçerik')),
                    DataColumn(label: Text('Tür')),
                    DataColumn(label: Text('Bildirme Nedeni')),
                    DataColumn(label: Text('Durum')),
                  ],
                  rows: reports.map((r) => _buildRow(r, dateFmt)).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(Report r, DateFormat dateFmt) {
    void openTarget() {
      if (r.type == 'work' && r.targetId.isNotEmpty) {
        Get.toNamed(AppRoutes.workDetail, arguments: r.targetId);
      }
    }

    return DataRow(
      cells: [
        DataCell(
          Text(r.createdAt != null ? dateFmt.format(r.createdAt!) : '—'),
          onTap: openTarget,
        ),
        DataCell(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.reporter.name ?? '—'),
              Text(
                r.reporter.email ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          onTap: openTarget,
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (r.target.thumbnailUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    r.target.thumbnailUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stack) => const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.broken_image_outlined, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  r.target.title ?? r.targetId,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          onTap: openTarget,
        ),
        DataCell(Text(r.target.type ?? r.type), onTap: openTarget),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(r.reason, overflow: TextOverflow.ellipsis),
          ),
          onTap: openTarget,
        ),
        DataCell(StatusBadge.reportStatus(r.status), onTap: openTarget),
      ],
    );
  }
}
