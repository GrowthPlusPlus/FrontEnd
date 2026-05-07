import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/report_repository.dart';

part 'report_provider.g.dart';

enum ReportTargetType { article, comment }

@riverpod
class ReportController extends _$ReportController {
  @override
  FutureOr<void> build() {}

  Future<bool> submitReport({
    required ReportTargetType targetType,
    required int targetId,
    required String reportReason,
    required String detailReason,
  }) async {
    state = const AsyncValue.loading();

    try {
      if (targetType == ReportTargetType.article) {
        await ref
            .read(reportRepositoryProvider)
            .reportArticle(
              articleId: targetId,
              reportReason: reportReason,
              detailReason: detailReason,
            );
      } else {
        await ref
            .read(reportRepositoryProvider)
            .reportComment(
              commentId: targetId,
              reportReason: reportReason,
              detailReason: detailReason,
            );
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      if (e is DioException) {
        debugPrint('---------- [신고 컨트롤러 오류] ----------');
        debugPrint('타입: $targetType, ID: $targetId');
        debugPrint('서버 응답: ${e.response?.data}');
        debugPrint('---------------------------------------');
      } else {
        debugPrint('신고 처리 중 알 수 없는 에러: $e');
      }

      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}
