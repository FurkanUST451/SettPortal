import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/audit_log_controller.dart';
import '../../core/constants.dart';
import '../../widgets/admin_scaffold.dart';

const _actionLabels = {
  AuditAction.viewConversation: 'Konuşma Görüntüleme',
  AuditAction.viewUserDetail: 'Kullanıcı Detayı Görüntüleme',
  AuditAction.banUser: 'Kullanıcı Yasaklama',
  AuditAction.unbanUser: 'Yasak Kaldırma',
  AuditAction.flagWork: 'İçerik Flagleme',
  AuditAction.unflagWork: 'Flag Kaldırma',
  AuditAction.deleteWork: 'İçerik Silme',
  AuditAction.deleteWorkComment: 'Yorum Silme',
  AuditAction.deleteWorkLike: 'Beğeni Silme',
  AuditAction.promoteAdmin: 'Admin Yetkisi Verme',
  AuditAction.demoteAdmin: 'Admin Yetkisi Alma',
};

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AuditLogController());
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm:ss');

    return AdminScaffold(
      title: 'Audit Log',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Aksiyon:'),
              const SizedBox(width: 12),
              Obx(
                () => DropdownButton<String?>(
                  value: c.actionFilter.value,
                  hint: const Text('Tümü'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tümü')),
                    ..._actionLabels.entries.map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    ),
                  ],
                  onChanged: c.setActionFilter,
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
              final entries = c.filtered;
              if (entries.isEmpty) {
                return const Center(child: Text('Kayıt bulunamadı.'));
              }
              return Card(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Tarih')),
                      DataColumn(label: Text('Admin')),
                      DataColumn(label: Text('Aksiyon')),
                      DataColumn(label: Text('Hedef')),
                    ],
                    rows: entries.map((e) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              e.createdAt != null
                                  ? dateFmt.format(e.createdAt!)
                                  : '—',
                            ),
                          ),
                          DataCell(Text(e.adminEmail ?? e.adminUid)),
                          DataCell(Text(_actionLabels[e.action] ?? e.action)),
                          DataCell(
                            Text(
                              [
                                e.targetType,
                                e.targetId,
                              ].where((s) => s != null).join(': '),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
