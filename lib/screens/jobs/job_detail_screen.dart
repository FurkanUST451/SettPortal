import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/job_detail_controller.dart';
import '../../models/app_user.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late final String projectId;
  late final JobDetailController controller;

  @override
  void initState() {
    super.initState();
    projectId = Get.arguments as String;
    controller = Get.put(JobDetailController(projectId), tag: projectId);
  }

  @override
  void dispose() {
    Get.delete<JobDetailController>(tag: projectId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');
    final currencyFmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return AdminScaffold(
      title: 'İş Detayı',
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final project = controller.project.value;
        if (project == null) {
          return const Center(child: Text('İş bulunamadı.'));
        }
        final brief = controller.brief.value;
        final offer = controller.offer.value;
        final client = controller.client.value;
        final freelancer = controller.freelancer.value;

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
                                project.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusBadge.projectStatus(project.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoRow('Proje ID', project.id),
                        _InfoRow(
                          'Müşteri',
                          _userLabel(client, project.clientId),
                          onTap: client == null
                              ? null
                              : () => Get.toNamed(
                                  AppRoutes.userDetail,
                                  arguments: client.id,
                                ),
                        ),
                        _InfoRow('Müşteri E-posta', client?.email ?? '—'),
                        _InfoRow(
                          'Freelancer',
                          _userLabel(freelancer, project.freelancerId),
                          onTap: freelancer == null
                              ? null
                              : () => Get.toNamed(
                                  AppRoutes.userDetail,
                                  arguments: freelancer.id,
                                ),
                        ),
                        _InfoRow(
                          'Freelancer E-posta',
                          freelancer?.email ?? '—',
                        ),
                        _InfoRow('Bütçe', currencyFmt.format(project.budget)),
                        if (project.category != null)
                          _InfoRow('Kategori', project.category!),
                        if (project.location != null)
                          _InfoRow('Konum', project.location!),
                        _InfoRow(
                          'Oluşturulma',
                          project.createdAt != null
                              ? dateFmt.format(project.createdAt!)
                              : '—',
                        ),
                        _InfoRow(
                          'Teslim Tarihi',
                          project.deadline != null
                              ? dateFmt.format(project.deadline!)
                              : '—',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Açıklama',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.description.isEmpty
                              ? '—'
                              : project.description,
                        ),
                      ],
                    ),
                  ),
                ),
                if (brief != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kaynak Brief (salt okunur)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InfoRow('Başlık', brief.title),
                          _InfoRow('Kategori', brief.category),
                          _InfoRow('Durum', brief.status),
                        ],
                      ),
                    ),
                  ),
                ],
                if (offer != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kaynak Teklif (salt okunur)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InfoRow('Tutar', currencyFmt.format(offer.amount)),
                          _InfoRow('Durum', offer.status),
                          _InfoRow('Mesaj', offer.message),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

String _userLabel(AppUser? user, String fallbackId) {
  if (user == null) return fallbackId;
  return user.fullName.isEmpty ? user.email : user.fullName;
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
