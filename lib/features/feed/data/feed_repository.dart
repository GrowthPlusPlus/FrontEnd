import 'package:dio/dio.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';

class FeedRepository {
  final Dio _dio;

  FeedRepository(this._dio);

  /// 공통 피드 조회 메서드
  /// [apiPath]를 파라미터로 받아 친구 피드나 둘러보기 피드 모두 처리 가능합니다.
  Future<Map<String, dynamic>> getFeeds(String apiPath, int page) async {
    try {
      final response = await _dio.get(
        apiPath,
        queryParameters: {'page': page, 'size': 10},
      );
      print("응답 데이터: ${response.data}"); // 💡 데이터가 오는지 확인

      if (response.statusCode == 200) {
        final List<dynamic> content = response.data['content'];
        final List<CertificationPostModel> posts = content
            .map((json) => CertificationPostModel.fromJson(json))
            .toList();

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
}
