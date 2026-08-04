import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/briefs_controller.dart';
import '../../controllers/jobs_controller.dart';
import '../../core/constants.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/scrollable_data_table.dart';
import '../../widgets/status_badge.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  int _tab = 0;
  late final BriefsController _briefsController;
  late final JobsController _projectsController;

  @override
  void initState() {
    super.initState();
    _briefsController = Get.put(BriefsController(), tag: 'jobs-page-briefs');
    _projectsController = Get.put(
      JobsController(),
      tag: 'jobs-page-projects',
    );
  }

  @override
  void dispose() {
    Get.delete<BriefsController>(tag: 'jobs-page-briefs');
    Get.delete<JobsController>(tag: 'jobs-page-projects');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'İş / Anlaşma Yönetimi',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _TabButton(
                label: 'Oluşturulan Briefler',
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              const SizedBox(width: 12),
              _TabButton(
                label: 'Kabul Edilen İşler',
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _tab == 0
                ? _BriefsTab(controller: _briefsController)
                : _ProjectsTab(controller: _projectsController),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return selected
        ? FilledButton(onPressed: onTap, child: Text(label))
        : OutlinedButton(onPressed: onTap, child: Text(label));
  }
}

class _BriefsTab extends StatelessWidget {
  final BriefsController controller;
  const _BriefsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return Column(
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
                    value: BriefStatus.draft,
                    child: Text('Taslak'),
                  ),
                  DropdownMenuItem(
                    value: BriefStatus.submitted,
                    child: Text('Anlaşma Bekliyor'),
                  ),
                  DropdownMenuItem(
                    value: BriefStatus.offerSent,
                    child: Text('Teklif Gönderildi'),
                  ),
                  DropdownMenuItem(
                    value: BriefStatus.cancelled,
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
            if (c.briefs.isEmpty) {
              return const Center(child: Text('Kayıt bulunamadı.'));
            }
            return Card(
              child: Column(
                children: [
                  Expanded(
                    child: ScrollableDataTable(
                      columns: const [
                        DataColumn(label: Text('Başlık')),
                        DataColumn(label: Text('Kategori')),
                        DataColumn(label: Text('Oluşturulma')),
                        DataColumn(label: Text('Durum')),
                      ],
                      rows: c.briefs.map((b) {
                        return DataRow(
                          onSelectChanged: (_) => Get.toNamed(
                            AppRoutes.briefDetail,
                            arguments: b.id,
                          ),
                          cells: [
                            DataCell(
                              Text(b.title.isEmpty ? '—' : b.title),
                            ),
                            DataCell(
                              Text(b.category.isEmpty ? '—' : b.category),
                            ),
                            DataCell(
                              Text(
                                b.createdAt != null
                                    ? dateFmt.format(b.createdAt!)
                                    : '—',
                              ),
                            ),
                            DataCell(StatusBadge.briefStatus(b.status)),
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
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  final JobsController controller;
  const _ProjectsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');
    final currencyFmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Column(
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
    );
  }
}
