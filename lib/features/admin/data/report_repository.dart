// 최초 작성자 : [작성자명]
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import '../models/report.dart';

part 'report_repository.g.dart';

class AdminReportRepository {
  final Dio _dio;

  AdminReportRepository(this._dio);

  // 1. 신고 횟수 순 게시글 목록 조회
  Future<List<ReportedArticleSummary>> fetchReportedArticles() async {
    try {
      final response = await _dio.get('/api/reports/articles');
      debugPrint('📥 신고 게시글 목록 응답: ${response.data}');

      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map(
              (e) => ReportedArticleSummary.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        return list;
      } else {
        throw Exception('신고 게시글 조회 실패 (상태 코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 신고 게시글 서버 에러: ${e.response?.data}');
      throw Exception(
        '서버 에러: ${e.response?.statusCode} - ${e.response?.data['message'] ?? '잘못된 요청'}',
      );
    } catch (e) {
      debugPrint('❌ 신고 게시글 파싱 에러: $e');
      throw Exception('데이터 처리 중 오류가 발생했습니다.');
    }
  }

  // 2. 신고 횟수 순 댓글 목록 조회
  Future<List<ReportedCommentSummary>> fetchReportedComments() async {
    try {
      final response = await _dio.get('/api/reports/comments');
      debugPrint('📥 신고 댓글 목록 응답: ${response.data}');

      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map(
              (e) => ReportedCommentSummary.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        return list;
      } else {
        throw Exception('신고 댓글 조회 실패 (상태 코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 신고 댓글 서버 에러: ${e.response?.data}');
      throw Exception(
        '서버 에러: ${e.response?.statusCode} - ${e.response?.data['message'] ?? '잘못된 요청'}',
      );
    } catch (e) {
      debugPrint('❌ 신고 댓글 파싱 에러: $e');
      throw Exception('데이터 처리 중 오류가 발생했습니다.');
    }
  }

  // 3. 신고 게시글 상세 조회
  Future<ArticleReportDetail> fetchArticleReportDetail(int articleId) async {
    try {
      final response = await _dio.get('/api/reports/articles/$articleId');
      debugPrint('📥 신고 게시글 상세 응답 ($articleId): ${response.data}');

      if (response.statusCode == 200) {
        // 단일 객체 응답이거나 혹은 배열 형태로 감싸져 올 경우를 고려한 안전한 파싱 구조
        final dynamic data = response.data;
        if (data is List) {
          if (data.isEmpty) throw Exception('신고 상세 내역이 존재하지 않습니다.');
          return ArticleReportDetail.fromJson(
            data.first as Map<String, dynamic>,
          );
        }
        return ArticleReportDetail.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception('신고 게시글 상세 조회 실패 (상태 코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 신고 게시글 상세 서버 에러: ${e.response?.data}');
      throw Exception(
        '서버 에러: ${e.response?.statusCode} - ${e.response?.data['message'] ?? '잘못된 요청'}',
      );
    } catch (e) {
      debugPrint('❌ 신고 게시글 상세 파싱 에러: $e');
      throw Exception('데이터 처리 중 오류가 발생했습니다.');
    }
  }

  // 4. 신고 댓글 상세 정보 조회
  Future<CommentReportDetail> fetchCommentReportDetail(int commentId) async {
    try {
      final response = await _dio.get('/api/reports/comments/$commentId');
      debugPrint('📥 신고 댓글 상세 응답 ($commentId): ${response.data}');

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is List) {
          if (data.isEmpty) throw Exception('신고 상세 내역이 존재하지 않습니다.');
          return CommentReportDetail.fromJson(
            data.first as Map<String, dynamic>,
          );
        }
        return CommentReportDetail.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception('신고 댓글 상세 조회 실패 (상태 코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 신고 댓글 상세 서버 에러: ${e.response?.data}');
      throw Exception(
        '서버 에러: ${e.response?.statusCode} - ${e.response?.data['message'] ?? '잘못된 요청'}',
      );
    } catch (e) {
      debugPrint('❌ 신고 댓글 상세 파싱 에러: $e');
      throw Exception('데이터 처리 중 오류가 발생했습니다.');
    }
  }

  // 5. 게시글 신고 기각 (신고 취소)
  Future<bool> dismissArticleReport(int articleId, int reportId) async {
    try {
      final response = await _dio.delete(
        '/api/reports/articles/$articleId/$reportId',
      );
      debugPrint('📥 게시글 신고 기각 응답: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw Exception('게시글 신고 기각 처리 실패');
    } on DioException catch (e) {
      debugPrint('❌ 게시글 신고 기각 에러: ${e.response?.data}');
      throw Exception('신고 기각 에러: ${e.response?.data['message'] ?? '요청 실패'}');
    } catch (e) {
      throw Exception('처리 중 오류가 발생했습니다.');
    }
  }

  // 6. 댓글 신고 기각 (신고 취소)
  Future<bool> dismissCommentReport(int commentId, int reportId) async {
    try {
      final response = await _dio.delete(
        '/api/reports/comments/$commentId/$reportId',
      );
      debugPrint('📥 댓글 신고 기각 응답: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw Exception('댓글 신고 기각 처리 실패');
    } on DioException catch (e) {
      debugPrint('❌ 댓글 신고 기각 에러: ${e.response?.data}');
      throw Exception('신고 기각 에러: ${e.response?.data['message'] ?? '요청 실패'}');
    } catch (e) {
      throw Exception('처리 중 오류가 발생했습니다.');
    }
  }

  // 7. 게시글 강제 삭제
  Future<bool> deleteArticleByAdmin(int postId) async {
    try {
      final response = await _dio.delete('/api/admin/articles/$postId');
      debugPrint('📥 관리자 게시글 삭제 응답: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw Exception('관리자 권한 게시글 삭제 실패');
    } on DioException catch (e) {
      debugPrint('❌ 관리자 게시글 삭제 에러: ${e.response?.data}');
      throw Exception('게시글 삭제 에러: ${e.response?.data['message'] ?? '요청 실패'}');
    } catch (e) {
      throw Exception('처리 중 오류가 발생했습니다.');
    }
  }

  // 8. 댓글 강제 삭제
  Future<bool> deleteCommentByAdmin(int commentId) async {
    try {
      final response = await _dio.delete('/api/admin/comments/$commentId');
      debugPrint('📥 관리자 댓글 삭제 응답: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw Exception('관리자 권한 댓글 삭제 실패');
    } on DioException catch (e) {
      debugPrint('❌ 관리자 댓글 삭제 에러: ${e.response?.data}');
      throw Exception('댓글 삭제 에러: ${e.response?.data['message'] ?? '요청 실패'}');
    } catch (e) {
      throw Exception('처리 중 오류가 발생했습니다.');
    }
  }
}

// Provider 설정
@riverpod
AdminReportRepository adminReportRepository(AdminReportRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return AdminReportRepository(dio);
}
