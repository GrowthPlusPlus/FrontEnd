import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/calendar_post.dart';
import 'package:haenaem/core/network/dio_provider.dart';

part 'post_repository.g.dart';

// 최초 작성자 : 강선욱
class PostRepository {
  final Dio _dio;

  PostRepository(this._dio);

  // 챌린지의 특정 연월 인증 포스트 목록 조회
  Future<List<CalendarPost>> getChallengePosts({
    required int challengeId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/$challengeId/calendar/posts',
        queryParameters: {'year': year, 'month': month, 'page': 0},
      );

      if (response.statusCode == 200) {
        final List<dynamic> content = response.data['content'] ?? [];
        return content
            .map((e) => CalendarPost.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('인증글 목록 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 인증글 API 에러: ${e.response?.data}');
      return [];
    }
  }
}

@riverpod
PostRepository postRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return PostRepository(dio);
}
