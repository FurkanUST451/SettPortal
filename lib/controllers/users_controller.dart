import 'package:get/get.dart';

import '../models/app_user.dart';
import '../repositories/user_repository.dart';
import '../services/functions_service.dart';

class UsersController extends GetxController {
  final _repo = UserRepository();
  final _functions = FunctionsService();

  final RxList<AppUser> users = <AppUser>[].obs;
  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxnString roleFilter = RxnString();
  final RxnBool bannedFilter = RxnBool();
  final RxString searchQuery = ''.obs;

  bool get _isSearching => searchQuery.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    loading.value = true;
    hasMore.value = true;
    if (_isSearching) {
      users.assignAll(
        await _repo.searchByEmailPrefix(searchQuery.value.trim()),
      );
      hasMore.value = false;
    } else {
      final page = await _repo.fetchPage(
        role: roleFilter.value,
        banned: bannedFilter.value,
      );
      users.assignAll(page);
      hasMore.value = page.length == UserRepository.pageSize;
    }
    loading.value = false;
  }

  Future<void> loadMore() async {
    if (loadingMore.value || !hasMore.value || _isSearching || users.isEmpty) {
      return;
    }
    loadingMore.value = true;
    final cursor = users.last.createdAt?.toIso8601String();
    final page = await _repo.fetchPage(
      role: roleFilter.value,
      banned: bannedFilter.value,
      startAfterCreatedAt: cursor,
    );
    users.addAll(page);
    hasMore.value = page.length == UserRepository.pageSize;
    loadingMore.value = false;
  }

  void setRoleFilter(String? role) {
    roleFilter.value = role;
    loadFirstPage();
  }

  void setBannedFilter(bool? banned) {
    bannedFilter.value = banned;
    loadFirstPage();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    loadFirstPage();
  }

  Future<void> banUser(String uid, String reason) async {
    await _functions.banUser(uid: uid, reason: reason);
    await loadFirstPage();
  }

  Future<void> unbanUser(String uid) async {
    await _functions.unbanUser(uid: uid);
    await loadFirstPage();
  }
}
