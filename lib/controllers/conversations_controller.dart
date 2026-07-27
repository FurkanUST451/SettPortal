import 'package:get/get.dart';

import '../models/chat.dart';
import '../repositories/chat_repository.dart';

class ConversationsController extends GetxController {
  final _repo = ChatRepository();

  final RxList<Chat> chats = <Chat>[].obs;
  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    loading.value = true;
    hasMore.value = true;
    final page = await _repo.fetchPage();
    chats.assignAll(page);
    hasMore.value = page.length == ChatRepository.pageSize;
    loading.value = false;
  }

  Future<void> loadMore() async {
    if (loadingMore.value || !hasMore.value || chats.isEmpty) return;
    loadingMore.value = true;
    final cursor = chats.last.createdAt?.toIso8601String();
    final page = await _repo.fetchPage(startAfterCreatedAt: cursor);
    chats.addAll(page);
    hasMore.value = page.length == ChatRepository.pageSize;
    loadingMore.value = false;
  }
}
