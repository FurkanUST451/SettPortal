import 'dart:async';

import 'package:get/get.dart';

import '../models/chat.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../services/audit_log_service.dart';

/// Opening a conversation is sensitive (dispute/support access to private
/// messages), so every open is written to the audit log exactly once per
/// screen visit — logged as soon as the chat itself loads, not per message.
class ConversationDetailController extends GetxController {
  final String chatId;
  ConversationDetailController(this.chatId);

  final _repo = ChatRepository();
  final _auditLog = AuditLogService();

  final Rxn<Chat> chat = Rxn<Chat>();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool loading = true.obs;

  StreamSubscription<List<ChatMessage>>? _messagesSub;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void onClose() {
    _messagesSub?.cancel();
    super.onClose();
  }

  Future<void> _load() async {
    loading.value = true;
    chat.value = await _repo.fetchById(chatId);
    await _auditLog.logViewConversation(chatId);
    _messagesSub = _repo.watchMessages(chatId).listen(messages.assignAll);
    loading.value = false;
  }
}
