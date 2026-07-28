import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/conversations_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/scrollable_data_table.dart';

class ConversationsListScreen extends StatelessWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ConversationsController());
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return AdminScaffold(
      title: 'Konuşmalar',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Bu ekran sadece anlaşmazlık/destek amaçlı erişim içindir. '
              'Her açılan konuşma audit log\'a kaydedilir.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (c.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.chats.isEmpty) {
                return const Center(child: Text('Kayıt bulunamadı.'));
              }
              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: ScrollableDataTable(
                        columns: const [
                          DataColumn(label: Text('Client')),
                          DataColumn(label: Text('Freelancer')),
                          DataColumn(label: Text('Brief')),
                          DataColumn(label: Text('Son Mesaj')),
                          DataColumn(label: Text('Oluşturulma')),
                        ],
                        rows: c.chats.map((chat) {
                          return DataRow(
                            onSelectChanged: (_) => Get.toNamed(
                              AppRoutes.conversationDetail,
                              arguments: chat.id,
                            ),
                            cells: [
                              DataCell(Text(chat.clientName)),
                              DataCell(Text(chat.freelancerName)),
                              DataCell(Text(chat.briefTitle)),
                              DataCell(
                                Text(
                                  chat.lastMessage?.isNotEmpty == true
                                      ? chat.lastMessage!
                                      : '—',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  chat.createdAt != null
                                      ? dateFmt.format(chat.createdAt!)
                                      : '—',
                                ),
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
