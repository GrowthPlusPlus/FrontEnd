import 'package:dio/dio.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
//import 'package:haenaem/features/challenge/models/challenge_model.dart';
import 'package:haenaem/shared/models/post.dart';
import 'package:haenaem/features/feed/models/comment.dart';
import 'package:haenaem/shared/models/search_challenge_card.dart';
import 'package:haenaem/shared/models/challenge_base.dart';
import 'package:haenaem/shared/models/tag_model.dart';

part 'feed_repository.g.dart';

@riverpod
FeedRepository feedRepository(FeedRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return FeedRepository(dio);
}

class FeedRepository {
  final Dio _dio;
  FeedRepository(this._dio);

  // ── AI 챌린지 추천 데이터 가져오기 ────────────────────────────
  Future<List<SearchChallengeCard>> getAiRecommendations() async {
    try {
      // 명세서에 따른 POST 요청
      final response = await _dio.post('/api/v1/rag/recommend/discovery');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) {
          return SearchChallengeCard(
            // 1. ChallengeBase 매핑 (리팩토링된 구조: id, title)
            base: ChallengeBase(id: item['id'], title: item['title']),
            // 2. 참여자 수
            participantCount: item['participantNumber'] ?? 0,
            // 3. D-Day (명세서에 없으므로 기본값 0 처리)
            dDay: 0,
            // 4. 태그 (API의 객체 리스트를 String 리스트로 변환)
            tags: (item['tags'] as List? ?? [])
                .map(
                  (t) => ChallengeTagModel.fromJson(t as Map<String, dynamic>),
                )
                .toList(),
          );
        }).toList();
      }
      throw Exception('AI 추천 로드 실패');
    } catch (e) {
      debugPrint('❌ AI 추천 에러: $e');
      throw Exception('네트워크 에러가 발생했습니다.');
    }
  }

  /// 공통 피드 조회 메서드
  Future<Map<String, dynamic>> getFeeds(String apiPath, int page) async {
    try {
      final response = await _dio.get(
        apiPath,
        queryParameters: {'page': page, 'size': 10},
      );
      print("응답 데이터: ${response.data}"); // 💡 데이터가 오는지 확인

      if (response.statusCode == 200) {
        final List<dynamic> content = response.data['content'] ?? [];
        final List<Post> posts = [];
        for (var item in content) {
          try {
            posts.add(Post.fromJson(item));
          } catch (e) {
            print("⚠️ 특정 포스트 파싱 실패 (ID: ${item['postId']}): $e");
            // 에러가 난 포스트는 건너뜁니다.
          }
        }

        return {
          'posts': posts,
          'isLast': response.data['last'], // 마지막 페이지 여부
          'number': response.data['number'], // 현재 페이지 번호
        };
      }
      throw Exception('데이터 로드 실패');
    } catch (e) {
      throw Exception('네트워크 에러: $e');
    }
  }

  Future<Map<String, dynamic>> getMemberFeeds(int challengeId, int page) async {
    final String apiPath = '/api/feed/challengeMember/$challengeId';
    return await getFeeds(apiPath, page);
  }

  Future<void> toggleLike(int postId, bool isCurrentlyLiked) async {
    try {
      if (isCurrentlyLiked) {
        // 💡 이미 좋아요 상태라면 DELETE 요청을 보냅니다.
        await _dio.delete('/api/article/$postId/like');
        print("🗑️ [API] 좋아요 취소 성공 (DELETE)");
      } else {
        // 💡 좋아요 상태가 아니라면 POST 요청을 보냅니다.
        await _dio.post('/api/article/$postId/like');
        print("❤️ [API] 좋아요 등록 성공 (POST)");
      }
    } catch (e) {
      print("❌ [API] 좋아요 토글 에러: $e");
      rethrow;
    }
  }

  // 인증글 상세 정보 가져오기
  Future<Post> getArticleDetail(int postId) async {
    try {
      debugPrint('🚀 [GET Request] /api/articles/$postId');
      final response = await _dio.get('/api/articles/$postId');

      if (response.statusCode == 200) {
        debugPrint('📥 상세조회 서버 응답 원본: ${response.data}');
        return Post.fromJson(response.data);
      } else {
        throw Exception('인증글 상세 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 상세 조회 에러: ${e.response?.data}');
      throw Exception('정보를 불러오지 못했습니다.');
    }
  }

  // 인증글 생성
  Future<Post> createArticle({
    required int challengeId,
    required String content,
    required List<int> tempImageIds,
  }) async {
    try {
      final response = await _dio.post(
        '/api/articles',
        data: {
          "content": content,
          "challengeId": challengeId,
          "tempImageIds": tempImageIds,
        },
      );

      if (response.statusCode == 201) {
        return Post.fromJson(response.data);
      } else {
        throw Exception('인증글 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ 인증글 생성 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '게시글 업로드 실패');
    }
  }

  // 인증글 수정
  Future<Post> updateArticle({
    required int postId,
    required String content,
    required List<int> deleteImageIds,
    required List<int> tempImageIds,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/articles/$postId',
        data: {
          "content": content,
          "deleteImageIds": deleteImageIds,
          "tempImageIds": tempImageIds,
        },
      );
      if (response.statusCode == 200) {
        debugPrint('✅ 인증글 수정 성공: ${response.data}');
        return Post.fromJson(response.data);
      } else {
        throw Exception('수정 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ 수정 에러 상세: ${e.response?.data}');
      throw Exception(e.response?.data?['message'] ?? '수정 중 오류 발생');
    }
  }

  // 인증글 삭제
  Future<void> deleteArticle(int postId) async {
    try {
      debugPrint('🚀 [DELETE Request] /api/articles/$postId');
      final response = await _dio.delete('/api/articles/$postId');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('삭제 실패 (Status: ${response.statusCode})');
      }
      debugPrint('✅ 인증글 삭제 성공');
    } on DioException catch (e) {
      debugPrint('❌ 인증글 삭제 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '삭제 중 오류가 발생했습니다.');
    }
  }

  // 댓글 목록 조회
  Future<List<Comment>> getComments({required int postId, int page = 0}) async {
    try {
      final response = await _dio.get(
        '/api/articles/$postId/comments',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final List<dynamic> content = response.data['content'] ?? [];
        return content.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('댓글 목록 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 댓글 조회 에러: ${e.response?.data}');
      throw Exception('댓글을 불러오는 중 오류가 발생했습니다.');
    }
  }

  // 댓글 생성
  Future<void> createComment({
    required int postId,
    required String contents,
  }) async {
    try {
      final response = await _dio.post(
        '/api/articles/$postId/comments',
        data: {"contents": contents},
      );

      if (response.statusCode != 201) {
        throw Exception('댓글 생성 실패 (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 댓글 생성 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '댓글 작성 중 오류가 발생했습니다.');
    }
  }

  // 댓글 수정
  Future<void> updateComment({
    required int commentId,
    required String contents,
  }) async {
    try {
      debugPrint('🚀 [PATCH Request] /api/comments/$commentId');
      final response = await _dio.patch(
        '/api/comments/$commentId',
        data: {"contents": contents},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('댓글 수정 실패 (Status: ${response.statusCode})');
      }
      debugPrint('✅ 댓글 수정 성공');
    } on DioException catch (e) {
      debugPrint('❌ 댓글 수정 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '댓글 수정 중 오류가 발생했습니다.');
    }
  }

  // 댓글 삭제
  Future<void> deleteComment(int commentId) async {
    try {
      debugPrint('🚀 [DELETE Request] /api/comments/$commentId');
      final response = await _dio.delete('/api/comments/$commentId');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('댓글 삭제 실패 (Status: ${response.statusCode})');
      }
      debugPrint('✅ 댓글 삭제 성공');
    } on DioException catch (e) {
      debugPrint('❌ 댓글 삭제 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '댓글 삭제 중 오류가 발생했습니다.');
    }
  }
}
