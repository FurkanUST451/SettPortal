import 'dart:async';

import 'package:get/get.dart';

import '../models/work.dart';
import '../models/work_comment.dart';
import '../models/work_like.dart';
import '../repositories/work_repository.dart';
import '../services/functions_service.dart';

class WorkDetailController extends GetxController {
  final String workId;
  WorkDetailController(this.workId);

  final _repo = WorkRepository();
  final _functions = FunctionsService();

  final Rxn<Work> work = Rxn<Work>();
  final RxBool loading = true.obs;
  final RxBool actionLoading = false.obs;
  final RxList<WorkComment> comments = <WorkComment>[].obs;
  final RxList<WorkLike> likes = <WorkLike>[].obs;

  StreamSubscription<List<WorkComment>>? _commentsSub;
  StreamSubscription<List<WorkLike>>? _likesSub;

  @override
  void onInit() {
    super.onInit();
    _load();
    _commentsSub = _repo.watchComments(workId).listen(comments.assignAll);
    _likesSub = _repo.watchLikes(workId).listen(likes.assignAll);
  }

  @override
  void onClose() {
    _commentsSub?.cancel();
    _likesSub?.cancel();
    super.onClose();
  }

  Future<void> _load() async {
    loading.value = true;
    work.value = await _repo.fetchById(workId);
    loading.value = false;
  }

  Future<void> flag(String reason) async {
    actionLoading.value = true;
    try {
      await _functions.flagWork(workId: workId, reason: reason);
      await _load();
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> unflag() async {
    actionLoading.value = true;
    try {
      await _functions.unflagWork(workId: workId);
      await _load();
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> deleteWork() async {
    actionLoading.value = true;
    try {
      await _functions.deleteWork(workId: workId);
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> deleteComment(String commentId) =>
      _functions.deleteWorkComment(workId: workId, commentId: commentId);

  Future<void> deleteLike(String likeId) =>
      _functions.deleteWorkLike(workId: workId, likeId: likeId);
}
