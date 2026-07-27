import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/users_controller.dart';
import '../../core/constants.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
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
          Row(
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
              const SizedBox(width: 16),
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
              const SizedBox(width: 16),
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
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Ad Soyad')),
                            DataColumn(label: Text('E-posta')),
                            DataColumn(label: Text('Rol')),
                            DataColumn(label: Text('Kayıt Tarihi')),
                            DataColumn(label: Text('Durum')),
                          ],
                          rows: c.users.map((u) {
                            return DataRow(
                              onSelectChanged: (_) => Get.toNamed(
                                AppRoutes.userDetail,
                                arguments: u.id,
                              ),
                              cells: [
                                DataCell(
                                  Text(u.fullName.isEmpty ? '—' : u.fullName),
                                ),
                                DataCell(Text(u.email)),
                                DataCell(StatusBadge.role(u.role)),
                                DataCell(
                                  Text(
                                    u.createdAt != null
                                        ? dateFmt.format(u.createdAt!)
                                        : '—',
                                  ),
                                ),
                                DataCell(StatusBadge.banned(u.banned)),
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
