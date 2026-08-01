import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/offer_detail_controller.dart';
import '../../models/app_user.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class OfferDetailScreen extends StatefulWidget {
  const OfferDetailScreen({super.key});

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  late final String offerId;
  late final OfferDetailController controller;

  @override
  void initState() {
    super.initState();
    offerId = Get.arguments as String;
    controller = Get.put(OfferDetailController(offerId), tag: offerId);
  }

  @override
  void dispose() {
    Get.delete<OfferDetailController>(tag: offerId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');
    final currencyFmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return AdminScaffold(
      title: 'Teklif Detayı',
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final offer = controller.offer.value;
        if (offer == null) {
          return const Center(child: Text('Teklif bulunamadı.'));
        }
        final brief = controller.brief.value;
        final sender = controller.sender.value;
        final receiver = controller.receiver.value;

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
                                offer.briefTitle.isEmpty
                                    ? 'Başlıksız Teklif'
                                    : offer.briefTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusBadge.offerStatus(offer.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoRow('Teklif ID', offer.id),
                        _InfoRow('Tutar', currencyFmt.format(offer.amount)),
                        _UserInfoRow(
                          label: 'Gönderen',
                          user: sender,
                          fallbackId: offer.senderId,
                        ),
                        _UserInfoRow(
                          label: 'Alıcı',
                          user: receiver,
                          fallbackId: offer.receiverId,
                        ),
                        _InfoRow(
                          'Oluşturulma',
                          offer.createdAt != null
                              ? dateFmt.format(offer.createdAt!)
                              : '—',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mesaj',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(offer.message.isEmpty ? '—' : offer.message),
                        if (offer.chatId.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => Get.toNamed(
                              AppRoutes.conversationDetail,
                              arguments: offer.chatId,
                            ),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Sohbete Git'),
                          ),
                        ],
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
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Kaynak Brief',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed(
                                  AppRoutes.briefDetail,
                                  arguments: brief.id,
                                ),
                                child: const Text('Detaya Git'),
                              ),
                            ],
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
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _UserInfoRow extends StatelessWidget {
  final String label;
  final AppUser? user;
  final String fallbackId;
  const _UserInfoRow({
    required this.label,
    required this.user,
    required this.fallbackId,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoRow(
      label,
      user == null
          ? fallbackId
          : (user!.fullName.isEmpty ? user!.email : user!.fullName),
      onTap: user == null
          ? null
          : () => Get.toNamed(AppRoutes.userDetail, arguments: user!.id),
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
