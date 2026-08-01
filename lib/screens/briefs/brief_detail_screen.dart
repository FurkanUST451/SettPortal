import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/brief_detail_controller.dart';
import '../../models/app_user.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class BriefDetailScreen extends StatefulWidget {
  const BriefDetailScreen({super.key});

  @override
  State<BriefDetailScreen> createState() => _BriefDetailScreenState();
}

class _BriefDetailScreenState extends State<BriefDetailScreen> {
  late final String briefId;
  late final BriefDetailController controller;

  @override
  void initState() {
    super.initState();
    briefId = Get.arguments as String;
    controller = Get.put(BriefDetailController(briefId), tag: briefId);
  }

  @override
  void dispose() {
    Get.delete<BriefDetailController>(tag: briefId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return AdminScaffold(
      title: 'Brief Detayı',
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final brief = controller.brief.value;
        if (brief == null) {
          return const Center(child: Text('Brief bulunamadı.'));
        }
        final owner = controller.owner.value;

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
                                brief.title.isEmpty
                                    ? 'Başlıksız Brief'
                                    : brief.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusBadge.briefStatus(brief.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoRow('Brief ID', brief.id),
                        _InfoRow(
                          'Sahibi',
                          owner == null
                              ? brief.ownerId
                              : (owner.fullName.isEmpty
                                    ? owner.email
                                    : owner.fullName),
                          onTap: owner == null
                              ? null
                              : () => Get.toNamed(
                                  AppRoutes.userDetail,
                                  arguments: owner.id,
                                ),
                        ),
                        _InfoRow('Kategori', brief.category),
                        _InfoRow(
                          'Oluşturulma',
                          brief.createdAt != null
                              ? dateFmt.format(brief.createdAt!)
                              : '—',
                        ),
                      ],
                    ),
                  ),
                ),
                if (brief.answers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cevaplar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...brief.answers.entries.map(
                            (e) => _InfoRow(e.key, '${e.value}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gönderilen Freelancerlar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (brief.sentToIds.isEmpty)
                          const Text(
                            'Bu brief henüz kimseye gönderilmemiş.',
                            style: TextStyle(color: Colors.black54),
                          )
                        else
                          Obx(
                            () => Column(
                              children: controller.sentTo
                                  .map((u) => _UserRow(user: u))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _UserRow extends StatelessWidget {
  final AppUser user;
  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.userDetail, arguments: user.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                user.fullName.isEmpty ? user.email : user.fullName,
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }
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
