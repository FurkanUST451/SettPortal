import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/users_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/confirm_action_dialog.dart';
import '../../widgets/scrollable_data_table.dart';
import '../../widgets/status_badge.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(UsersController());
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return AdminScaffold(
      title: 'Kullanıcı Yönetimi',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'E-posta ile ara (örn. ali@)',
                  ),
                  onSubmitted: c.setSearchQuery,
                ),
              ),
              Obx(
                () => DropdownButton<String?>(
                  value: c.roleFilter.value,
                  hint: const Text('Rol'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tümü')),
                    DropdownMenuItem(
                      value: UserRole.client,
                      child: Text('Client'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.freelancer,
                      child: Text('Freelancer'),
                    ),
                  ],
                  onChanged: c.setRoleFilter,
                ),
              ),
              Obx(
                () => DropdownButton<bool?>(
                  value: c.bannedFilter.value,
                  hint: const Text('Durum'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tümü')),
                    DropdownMenuItem(value: false, child: Text('Aktif')),
                    DropdownMenuItem(value: true, child: Text('Yasaklı')),
                  ],
                  onChanged: c.setBannedFilter,
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
              if (c.users.isEmpty) {
                return const Center(child: Text('Kayıt bulunamadı.'));
              }
              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: ScrollableDataTable(
                        showCheckboxColumn: true,
                        columns: const [
                          DataColumn(label: Text('Ad Soyad')),
                          DataColumn(label: Text('E-posta')),
                          DataColumn(label: Text('Rol')),
                          DataColumn(label: Text('Kayıt Tarihi')),
                          DataColumn(label: Text('Durum')),
                        ],
                        rows: c.users.map((u) {
                          void openDetail() => Get.toNamed(
                            AppRoutes.userDetail,
                            arguments: u.id,
                          );
                          return DataRow(
                            selected: c.selectedIds.contains(u.id),
                            onSelectChanged: (v) => c.toggleSelection(u.id, v),
                            cells: [
                              DataCell(
                                Text(u.fullName.isEmpty ? '—' : u.fullName),
                                onTap: openDetail,
                              ),
                              DataCell(Text(u.email), onTap: openDetail),
                              DataCell(
                                StatusBadge.role(u.role),
                                onTap: openDetail,
                              ),
                              DataCell(
                                Text(
                                  u.createdAt != null
                                      ? dateFmt.format(u.createdAt!)
                                      : '—',
                                ),
                                onTap: openDetail,
                              ),
                              DataCell(
                                StatusBadge.banned(u.banned),
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
  final UsersController c;
  const _BulkActionBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Obx(
          () => Row(
            children: [
              Text('${c.selectedIds.length} seçili'),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: c.bulkActionLoading.value
                    ? null
                    : () => _onBulkBanPressed(context),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
                icon: const Icon(Icons.block, size: 18),
                label: const Text('Toplu Yasakla'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: c.bulkActionLoading.value
                    ? null
                    : () => _onBulkUnbanPressed(context),
                icon: const Icon(Icons.lock_open, size: 18),
                label: const Text('Toplu Yasağı Kaldır'),
              ),
              const Spacer(),
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

  Future<void> _onBulkBanPressed(BuildContext context) async {
    final reason = await showConfirmActionDialog(
      title: 'Toplu Yasakla',
      message:
          '${c.selectedIds.length} kullanıcı askıya alınacak. Bu işlem audit '
          'log\'a her kullanıcı için ayrı ayrı kaydedilecek.',
      requireReason: true,
      confirmLabel: 'Askıya Al',
      confirmColor: AppTheme.danger,
    );
    if (reason != null) await c.bulkBan(reason);
  }

  Future<void> _onBulkUnbanPressed(BuildContext context) async {
    final confirmed = await showConfirmActionDialog(
      title: 'Toplu Yasağı Kaldır',
      message: '${c.selectedIds.length} kullanıcının yasağı kaldırılacak.',
      confirmLabel: 'Yasağı Kaldır',
      confirmColor: AppTheme.success,
    );
    if (confirmed != null) await c.bulkUnban();
  }
}
