import 'package:get/get.dart';

import '../models/project.dart';
import '../repositories/project_repository.dart';

class JobsController extends GetxController {
  final _repo = ProjectRepository();

  final RxList<Project> projects = <Project>[].obs;
  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxnString statusFilter = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    loading.value = true;
    hasMore.value = true;
    final page = await _repo.fetchPage(status: statusFilter.value);
    projects.assignAll(page);
    hasMore.value = page.length == ProjectRepository.pageSize;
    loading.value = false;
  }

  Future<void> loadMore() async {
    if (loadingMore.value || !hasMore.value || projects.isEmpty) return;
    loadingMore.value = true;
    final cursor = projects.last.createdAt?.toIso8601String();
    final page = await _repo.fetchPage(
      status: statusFilter.value,
      startAfterCreatedAt: cursor,
    );
    projects.addAll(page);
    hasMore.value = page.length == ProjectRepository.pageSize;
    loadingMore.value = false;
  }

  void setStatusFilter(String? status) {
    statusFilter.value = status;
    loadFirstPage();
  }
}
