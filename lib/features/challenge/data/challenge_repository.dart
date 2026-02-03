// 최초 작성자: 강선욱
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';
part 'challenge_repository.g.dart';

// 서버로부터 사용자의 챌린지 데이터를 가져오는 클래스
class ChallengeRepository {
  final Dio _dio;

  ChallengeRepository(this._dio);

  Future<ChallengeMainModel> getChallengeMainData(String date) async {
    try {
      // 1. 쿼리 파라미터에 날짜를 담아 호출합니다.
      final response = await _dio.get(
        '/api/mainHome',
        queryParameters: {'date': date},
      );

      if (response.statusCode == 200) {
        // 성공 시 JSON 데이터를 모델로 변환
        // Swagger에 정의된 구조와 ChallengeMainModel.fromJson이 일치해야 합니다.
        return ChallengeMainModel.fromJson(response.data);
      } else {
        throw Exception('데이터를 불러오는데 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      // Dio 전용 에러 핸들링
      print('❌ Repository 네트워크 에러: ${e.message}');
      throw Exception('서버 연결 실패: ${e.response?.statusMessage}');
    } catch (e) {
      print('❌ Repository 일반 에러: $e');
      throw Exception('알 수 없는 오류 발생');
    }
  }

  // 챌린지 생성 post 요청 보내기
  Future<ChallengeCreateResponse> createChallenge(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('/api/challenges/create', data: data);
      debugPrint('📥 서버 생성 응답 원본: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChallengeCreateResponse.fromJson(response.data);
      } else {
        throw Exception('챌린지 생성 실패');
      }
    } on DioException catch (e) {
      // 서버가 보내준 상세 에러 본문 출력
      debugPrint('❌ 서버 상세 에러: ${e.response?.data}');
      throw Exception(
        '서버 에러: ${e.response?.statusCode} - ${e.response?.data['message'] ?? '잘못된 요청'}',
      );
    }
  }

  // 챌린지 id를 받아서 서버에 요청을 보내는 함수
  Future<ChallengeCalendarModel> getChallengeCalendarData(
    int challengeId,
  ) async {
    try {
      // GET /api/challenges/{challengeId}/calendar
      final response = await _dio.get('/api/challenges/$challengeId/calendar');

      if (response.statusCode == 200) {
        return ChallengeCalendarModel.fromJson(response.data);
      } else {
        throw Exception('달력 요약 정보 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 달력 정보 API 에러: ${e.response?.data}');
      throw Exception('네트워크 에러');
    }
  }

  //연도(year)와 월(month)을 파라미터로 받아 인증글 목록을 가져오는 함수
  Future<List<CertificationPostModel>> getChallengePosts({
    required int challengeId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/$challengeId/calendar/posts',
        queryParameters: {
          'year': year,
          'month': month,
          'page': 0, // 명세서에 따라 0으로 고정
        },
      );

      if (response.statusCode == 200) {
        // Page 객체의 'content' 리스트를 추출
        final List<dynamic> content = response.data['content'] ?? [];
        return content
            .map((json) => CertificationPostModel.fromJson(json))
            .toList();
      } else {
        throw Exception('인증글 목록 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 인증글 API 에러: ${e.response?.data}');
      return []; // 에러 시 빈 리스트 반환
    }
  }
}

// Riverpod Provider 설정
@riverpod
ChallengeRepository challengeRepository(ChallengeRepositoryRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://hanaem.onrender.com/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // 🛡️ 모든 요청에 토큰을 자동으로 붙여주는 인터셉터
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 보안 저장소에서 현재 저장된 액세스 토큰을 읽어옵니다.
        const storage = FlutterSecureStorage();
        final String? token = await storage.read(key: 'accessToken');

        if (token != null) {
          // 헤더에 Authorization: Bearer <token> 추가
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('🔑 토큰 주입 완료: ${token.substring(0, 10)}...');
        } else {
          debugPrint('⚠️ 토큰이 없습니다. 로그인이 필요할 수 있습니다.');
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // 만약 토큰이 만료되어 401 에러가 났다면?
        if (e.response?.statusCode == 401) {
          debugPrint('🔄 토큰 만료 감지! 재발급을 시도합니다...');

          // AuthService에 만들어두신 refreshTokens()를 활용해봅니다.
          final newToken = await AuthService.refreshTokens();

          if (newToken != null) {
            // 새 토큰으로 기존 요청 재시도
            e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final response = await dio.fetch(e.requestOptions);
            return handler.resolve(response);
          }
        }
        return handler.next(e);
      },
    ),
  );

  return ChallengeRepository(dio);
}







// 서버로부터 사용자의 챌린지 메인 데이터를 가져오는 함수

// Future<ChallengeMainModel> getChallengeMainData(String date) async {
//   // 👈 테스트를 위한 가짜(Mock) 데이터 생성
//   await Future.delayed(const Duration(milliseconds: 500)); // 로딩 효과를 위해 약간의 지연

//   final mockData = {
//     "myChallenges": [
//       {
//         "challengeId": 1,
//         "title": "아침 6시 미라클 모닝",
//         "content": "매일 일찍 일어나기",
//         "maxParticipantNumber": 10,
//         "participantNumber": 6,
//         "duringDate": 5,
//         "doIt": true, // 오늘 완료! (초록색 카드)
//         "warning": false,
//       },
//       {
//         "challengeId": 2,
//         "title": "졸업 프로젝트 코딩",
//         "content": "빡코딩 가즈아",
//         "maxParticipantNumber": 3,
//         "participantNumber": 2,
//         "duringDate": 12,
//         "doIt": false, // 아직 안 함
//         "warning": true, // 근데 마감 임박! (빨간색 카드)
//       },
//       {
//         "challengeId": 3,
//         "title": "주 3회 헬스장 가기",
//         "content": "득근득근",
//         "maxParticipantNumber": 5,
//         "participantNumber": 1,
//         "duringDate": 0,
//         "doIt": false,
//         "warning": false, // 일반 상태 (회색 카드)
//       },
//     ],
//     "notificationNumber": 3, // 알림 배지 테스트용
//   };

//   return ChallengeMainModel.fromJson(mockData);

//   // 추후 필요한 기능들(예: 챌린지 생성, 인증 등)도 이곳에 추가하면 됩니다.
// }

// try {
//   // 실제 API 엔드포인트 주소로 변경 필요
//   final response = await _dio.get('/api/mainHome');

//   if (response.statusCode == 200) {
//     // 성공 시 JSON 데이터를 모델로 변환
//     return ChallengeMainModel.fromJson(response.data);
//   } else {
//     throw Exception('데이터를 불러오는데 실패했습니다.');
//   }
// } catch (e) {
//   // 에러 핸들링 (네트워크 오류 등)
//   print('❌ Repository 에러 발생: $e');
//   throw Exception('네트워크 오류: $e');
// }

