import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/conversation_detail_controller.dart';
import '../../core/theme.dart';
import '../../widgets/admin_scaffold.dart';

class ConversationDetailScreen extends StatefulWidget {
  const ConversationDetailScreen({super.key});

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  late final String chatId;
  late final ConversationDetailController controller;

  @override
  void initState() {
    super.initState();
    chatId = Get.arguments as String;
    controller = Get.put(ConversationDetailController(chatId), tag: chatId);
  }

  @override
  void dispose() {
    Get.delete<ConversationDetailController>(tag: chatId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('dd.MM.yyyy HH:mm');

    return AdminScaffold(
      title: 'Konuşma Detayı',
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final chat = controller.chat.value;
        if (chat == null) {
          return const Center(child: Text('Konuşma bulunamadı.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${chat.clientName}  ↔  ${chat.freelancerName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Brief: ${chat.briefTitle}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu görüntüleme audit log\'a kaydedildi.',
              style: TextStyle(color: AppTheme.warning, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: Obx(() {
                  if (controller.messages.isEmpty) {
                    return const Center(child: Text('Mesaj yok.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.messages.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) {
                      final m = controller.messages[i];
                      final isClient = m.senderId == chat.clientId;
                      return Align(
                        alignment: isClient
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isClient
                                ? const Color(0xFFEFF2F6)
                                : AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isClient
                                    ? chat.clientName
                                    : chat.freelancerName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.type == 'offer'
                                    ? '💰 Teklif mesajı: ${m.content}'
                                    : m.content,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.createdAt != null
                                    ? timeFmt.format(m.createdAt!)
                                    : '',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}
