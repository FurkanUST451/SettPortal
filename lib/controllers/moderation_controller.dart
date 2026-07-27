import 'package:get/get.dart';

import '../models/work.dart';
import '../repositories/work_repository.dart';

class ModerationController extends GetxController {
  final _repo = WorkRepository();

  final RxList<Work> works = <Work>[].obs;
  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxnString typeFilter = RxnString();
  final RxBool flaggedOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    loading.value = true;
    hasMore.value = true;
    final page = await _repo.fetchPage(
      type: typeFilter.value,
      flaggedOnly: flaggedOnly.value ? true : null,
    );
    works.assignAll(page);
    hasMore.value = page.length == WorkRepository.pageSize;
    loading.value = false;
  }

  Future<void> loadMore() async {
    if (loadingMore.value || !hasMore.value || works.isEmpty) return;
    loadingMore.value = true;
    final cursor = works.last.createdAt?.toIso8601String();
    final page = await _repo.fetchPage(
      type: typeFilter.value,
      flaggedOnly: flaggedOnly.value ? true : null,
      startAfterCreatedAt: cursor,
    );
    works.addAll(page);
    hasMore.value = page.length == WorkRepository.pageSize;
    loadingMore.value = false;
  }

  void setTypeFilter(String? type) {
    typeFilter.value = type;
    loadFirstPage();
  }

  void setFlaggedOnly(bool value) {
    flaggedOnly.value = value;
    loadFirstPage();
  }
}
