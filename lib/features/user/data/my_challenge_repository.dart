// 최초 작성자 : 강선욱
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/features/user/models/my_page_challenge_card.dart';

part 'my_challenge_repository.g.dart';

class MyChallengeRepository {
  final Dio _dio;

  MyChallengeRepository(this._dio);

  /// 내 페이지 - 나의 챌린지 - 진행 중인 챌린지
  Future<List<MyPageChallengeCard>> getInProgressChallenges({
    required bool onlyTwo,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/my/inProgress',
        queryParameters: {'onlyTwo': onlyTwo},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => MyPageChallengeCard.fromJson(e))
            .toList();
      }
      throw Exception('챌린지 로드 실패');
    } on DioException catch (e) {
      throw Exception('네트워크 에러: ${e.message}');
    }
  }

  /// 내 페이지 - 나의 챌린지 - 완료한 챌린지
  Future<List<MyPageChallengeCard>> getSuccessChallenges({
    required bool onlyTwo,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/my/success',
        queryParameters: {'onlyTwo': onlyTwo},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => MyPageChallengeCard.fromJson(e))
            .toList();
      }
      throw Exception('완료된 챌린지 로드 실패');
    } on DioException catch (e) {
      throw Exception('네트워크 에러: ${e.message}');
    }
  }

  /// 내 페이지 - 나의 챌린지 - 실패한 챌린지
  Future<List<MyPageChallengeCard>> getFailedChallenges({
    required bool onlyTwo,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/my/fail',
        queryParameters: {'onlyTwo': onlyTwo},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => MyPageChallengeCard.fromJson(e))
            .toList();
      }
      throw Exception('실패한 챌린지 로드 실패');
    } on DioException catch (e) {
      throw Exception('네트워크 에러: ${e.message}');
    }
  }
}

/// MyChallengeRepository 인스턴스를 제공하는 프로바이더
@riverpod
MyChallengeRepository myChallengeRepository(MyChallengeRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return MyChallengeRepository(dio);
}
