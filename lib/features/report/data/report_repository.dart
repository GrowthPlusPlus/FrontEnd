// 최초 작성자: 정승빈

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/network/dio_provider.dart';

// Repository Provider
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(dioProvider));
});

class ReportRepository {
  final Dio _dio;

  ReportRepository(this._dio);

  // 인증글 신고 API
  Future<void> reportArticle({
    required int articleId,
    required String reportReason,
    required String detailReason,
  }) async {
    try {
      await _dio.post(
        '/api/articles/$articleId/report',
        data: {'reportReason': reportReason, 'detailReason': detailReason},
      );
    } on DioException catch (e) {
      debugPrint('---------- [인증글 신고 실패] ----------');
      debugPrint('대상 ID: $articleId');
      debugPrint('상태 코드: ${e.response?.statusCode}');
      debugPrint('에러 데이터: ${e.response?.data}');
      debugPrint('------------------------------------');
      rethrow;
    }
  }

  // 댓글 신고 API
  Future<void> reportComment({
    required int commentId,
    required String reportReason,
    required String detailReason,
  }) async {
    try {
      await _dio.post(
        '/api/comments/$commentId/report',
        data: {'reportReason': reportReason, 'detailReason': detailReason},
      );
    } on DioException catch (e) {
      debugPrint('---------- [댓글 신고 실패] ----------');
      debugPrint('대상 ID: $commentId');
      debugPrint('상태 코드: ${e.response?.statusCode}');
      debugPrint('에러 데이터: ${e.response?.data}');
      debugPrint('------------------------------------');
      rethrow;
    }
  }
}
