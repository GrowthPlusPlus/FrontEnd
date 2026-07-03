/// 최초 작성자: 정승빈
library;

import 'package:dio/dio.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/shared/models/user.dart';

part 'challenge_member_repository.g.dart';

@riverpod
ChallengeMemberRepository challengeMemberRepository(
  ChallengeMemberRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider); // ← 공통 Dio 주입
  return ChallengeMemberRepository(dio);
}

class ChallengeMemberRepository {
  final Dio _dio;

  ChallengeMemberRepository(this._dio);

  /// 챌린지 멤버 조회 API
  /// - [challengeId]: 조회할 챌린지 ID
  /// - [page]: 페이지 번호 (0부터 시작, 기본값 0)
  /// - [nickname]: 닉네임 검색어 (선택)
  Future<List<User>> getChallengeMembers(
    int challengeId, {
    int page = 0,
    String? nickname,
  }) async {
    print(
      '🔥 [API Request] 챌린지($challengeId) 멤버 조회 요청 (Page: $page, Nickname: $nickname)',
    );

    try {
      // 1. 쿼리 파라미터 구성
      final Map<String, dynamic> queryParams = {'page': page};

      if (nickname != null && nickname.isNotEmpty) {
        queryParams['nickname'] = nickname;
      }

      // 2. GET 요청
      final response = await _dio.get(
        '/api/challenges/$challengeId/members',
        queryParameters: queryParams,
      );

      print('✨ [API Response] Status: ${response.statusCode}');
      print('📦 [API Response] Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];

        // 3. 응답 데이터 파싱 (Spring Boot Page 객체 또는 단순 리스트 대응)
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          list = data['content'] as List;
          print('✅ [Parsing] Page 객체 감지됨. content 리스트 추출.');
        } else if (data is List) {
          list = data;
          print('✅ [Parsing] 단순 리스트 감지됨.');
        } else {
          print('⚠️ [Parsing Warning] 예상치 못한 데이터 구조입니다.');
        }

        final members = list.map((e) => User.fromJson(e)).toList();
        print('✅ [Success] 총 ${members.length}명의 멤버 로드 완료');

        return members;
      } else {
        throw Exception('멤버 조회 실패 (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('🚨 [DioError] ${e.response?.statusCode} / ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '서버 요청 실패');
    } catch (e) {
      print('🚫 [Exception] $e');
      throw Exception('멤버 정보를 불러오는데 실패했습니다.');
    }
  }

  /// 챌린지 멤버 추방 API
  /// - [challengeId]: 챌린지 ID
  /// - [targetUserId]: 추방할 멤버의 유저 ID
  Future<void> kickMember(int challengeId, int targetUserId) async {
    print('🔥 [API Request] 멤버 추방 요청: 챌린지 $challengeId, 타겟 $targetUserId');

    try {
      final response = await _dio.post(
        '/api/challenges/$challengeId/members/kick',
        data: {
          // [체크 필요] 백엔드 DTO의 필드명과 일치해야 합니다. (예: targetUserId, memberId, kickUserId 등)
          'targetUserId': targetUserId,
        },
      );

      if (response.statusCode == 204) {
        print('✅ [Success] 멤버 추방 성공');
        return;
      } else {
        throw Exception('추방 실패 (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('🚨 [DioError] ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '서버 통신 오류');
    } catch (e) {
      print('🚫 [Exception] $e');
      throw Exception('알 수 없는 오류가 발생했습니다.');
    }
  }

  /// 챌린지장 위임 API
  /// - [challengeId]: 챌린지 ID
  Future<void> delegateChallengeOwnerAuto(int challengeId) async {
    try {
      debugPrint(
        '🚀 [POST Request] /api/challenges/$challengeId/owner/delegateAuto',
      );

      final response = await _dio.post(
        '/api/challenges/$challengeId/owner/delegateAuto',
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('방장 위임 실패 (Status: ${response.statusCode})');
      }
      debugPrint('✅ 방장 위임 성공');
    } on DioException catch (e) {
      debugPrint('❌ 방장 위임 API 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '위임 처리 중 오류가 발생했습니다.');
    }
  }
}
