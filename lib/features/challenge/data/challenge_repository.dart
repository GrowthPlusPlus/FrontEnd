// 최초 작성자: 강선욱
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/features/challenge/models/challenge_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';
import 'package:haenaem/features/user/models/user_model.dart';
import 'package:haenaem/features/feed/models/post.dart';
import 'package:haenaem/core/network/dio_provider.dart';
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

  // 챌린지 상세정보 조회 수정
  Future<ChallengeDetailModel> getChallengeDetail(int challengeId) async {
    try {
      final response = await _dio.get('api/challenge/$challengeId');
      print("서버 응답 데이터: ${response.data}"); // 데이터 확인 완료!

      // 상세 API는 content 없이 바로 객체가 오므로 response.data를 그대로 사용합니다.
      return ChallengeDetailModel.fromJson(response.data);
    } catch (e) {
      print("상세 조회 에러: $e");
      rethrow;
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
  Future<List<Post>> getChallengePosts({
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
        return content.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('인증글 목록 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 인증글 API 에러: ${e.response?.data}');
      return []; // 에러 시 빈 리스트 반환
    }
  }

  // 챌린지 달력 사진 가져오기
  Future<List<ChallengeCalendarPhoto>> getChallengeCalendarPhotos({
    required int challengeId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/$challengeId/calendar/photos',
        queryParameters: {'year': year, 'month': month},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => ChallengeCalendarPhoto.fromJson(json))
            .toList();
      } else {
        throw Exception('달력 사진 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 달력 사진 API 에러: ${e.response?.data}');
      return [];
    }
  }

  // 인증글 상세 정보 가져오기
  Future<CertificationPostModel> getArticleDetail(int postId) async {
    try {
      debugPrint('🚀 [GET Request] /api/articles/$postId');

      final response = await _dio.get('/api/articles/$postId');

      if (response.statusCode == 200) {
        debugPrint('📥 상세조회 서버 응답 원본: ${response.data}');
        return CertificationPostModel.fromJson(response.data);
      } else {
        throw Exception('인증글 상세 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 상세 조회 에러: ${e.response?.data}');
      throw Exception('정보를 불러오지 못했습니다.');
    }
  }

  // 인증글 생성
  Future<CertificationPostModel> createArticle({
    required int challengeId,
    required String content,
    required List<int> tempImageIds, // 💡 파일 대신 ID 리스트를 받음
  }) async {
    try {
      // ✨ 이제 Multipart가 아닌 일반 JSON 전송입니다.
      final response = await _dio.post(
        '/api/articles',
        data: {
          "content": content,
          "challengeId": challengeId,
          "tempImageIds": tempImageIds,
        },
      );

      if (response.statusCode == 201) {
        return CertificationPostModel.fromJson(response.data);
      } else {
        throw Exception('인증글 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ 인증글 생성 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '게시글 업로드 실패');
    }
  }

  // 인증글 수정
  Future<CertificationPostModel> updateArticle({
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
        return CertificationPostModel.fromJson(response.data);
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

      // 204는 성공을 의미하지만 응답 본문이 없는 상태입니다.
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('삭제 실패 (Status: ${response.statusCode})');
      }
      debugPrint('✅ 인증글 삭제 성공');
    } on DioException catch (e) {
      debugPrint('❌ 인증글 삭제 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '삭제 중 오류가 발생했습니다.');
    }
  }

  // 인증 사진 검증
  Future<int?> verifyImage(File imageFile, int challengeId) async {
    try {
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      // 💡 queryParameters에 challengeId 전달
      final response = await _dio.post(
        '/api/image/verify',
        data: formData,
        queryParameters: {'challengeId': challengeId},
      );

      // Swagger에는 204로 되어있으나 응답 바디가 있다면 tempImageId 추출
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ 이미지 검증 및 임시 업로드 성공: ${response.data}');
        return response.data['tempImageId'];
      }
      return null;
    } on DioException catch (e) {
      debugPrint('❌ 이미지 검증 에러: ${e.response?.data}');
      return null;
    }
  }

  // 특정 게시글의 댓글 목록을 가져오는 함수
  Future<List<ChallengeComment>> getComments({
    required int postId,
    int page = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/articles/$postId/comments',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        // Page 객체의 'content' 배열을 가져옴
        final List<dynamic> content = response.data['content'] ?? [];
        return content.map((json) => ChallengeComment.fromJson(json)).toList();
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
      final Map<String, dynamic> body = {
        "contents": contents, // 명세서 기준 복수형 'contents'
      };

      final response = await _dio.post(
        '/api/articles/$postId/comments',
        data: body,
      );

      if (response.statusCode != 201) {
        throw Exception('댓글 생성 실패 (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 댓글 생성 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '댓글 작성 중 오류가 발생했습니다.');
    }
  }

  // 댓글 삭제
  Future<void> deleteComment(int commentId) async {
    try {
      debugPrint('🚀 [DELETE Request] /api/comments/$commentId');

      final response = await _dio.delete('/api/comments/$commentId');

      // 204 No Content 성공 처리
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('댓글 삭제 실패 (Status: ${response.statusCode})');
      }
      debugPrint('✅ 댓글 삭제 성공');
    } on DioException catch (e) {
      debugPrint('❌ 댓글 삭제 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '댓글 삭제 중 오류가 발생했습니다.');
    }
  }

  // 댓글 수정
  Future<void> updateComment({
    required int commentId,
    required String contents,
  }) async {
    try {
      final Map<String, dynamic> body = {"contents": contents};

      debugPrint('🚀 [PATCH Request] /api/comments/$commentId');

      final response = await _dio.patch('/api/comments/$commentId', data: body);

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('댓글 수정 실패 (Status: ${response.statusCode})');
      }
      debugPrint('✅ 댓글 수정 성공');
    } on DioException catch (e) {
      debugPrint('❌ 댓글 수정 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '댓글 수정 중 오류가 발생했습니다.');
    }
  }

  // 인증글 좋아요 토글
  Future<void> toggleLike({
    required int postId,
    required bool isCurrentlyLiked,
  }) async {
    try {
      if (isCurrentlyLiked) {
        // 이미 좋아요 상태라면 -> 취소
        debugPrint('🚀 [DELETE Request] /api/article/$postId/like');
        await _dio.delete('/api/article/$postId/like');
      } else {
        // 좋아요가 아니라면 -> 등록
        debugPrint('🚀 [POST Request] /api/article/$postId/like');
        await _dio.post('/api/article/$postId/like');
      }
    } on DioException catch (e) {
      debugPrint('❌ 좋아요 토글 에러: ${e.response?.data}');
      throw Exception(e.response?.data?['message'] ?? '좋아요 처리 중 오류 발생');
    }
  }

  // 챌린지 삭제
  Future<void> deleteChallenge(int challengeId) async {
    try {
      debugPrint('🚀 [DELETE Request] /api/challenges/$challengeId');

      final response = await _dio.delete('/api/challenges/$challengeId');

      // 명세서 상 성공 시 204 반환
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('챌린지 삭제 실패 (Status: ${response.statusCode})');
      }
      debugPrint('✅ 챌린지 삭제 성공');
    } on DioException catch (e) {
      debugPrint('❌ 챌린지 삭제 API 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '챌린지 삭제 중 오류가 발생했습니다.');
    }
  }

  Future<void> leaveChallenge(int challengeId) async {
    try {
      // 1. API 경로 설정: /api/challenges/{challengeId}/leaveChallenge
      final response = await _dio.delete(
        '/api/challenges/$challengeId/leaveChallenge',
      );

      // 2. 응답 상태 코드 확인 (서버 설계에 따라 200 또는 204)
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("챌린지 퇴장 성공: $challengeId");
      } else {
        // 서버에서 에러 메시지를 주는 경우 처리
        throw Exception(response.data['message'] ?? '챌린지 나가기에 실패했습니다.');
      }
    } catch (e) {
      debugPrint("챌린지 퇴장 API 에러: $e");
      rethrow; // Provider의 AsyncValue.guard에서 잡을 수 있도록 던져줍니다.
    }
  }

  // 내 페이지 - 나의 챌린지 - 진행 중인 챌린지
  Future<List<ChallengeInProgressModel>> getInProgressChallenges({
    required bool onlyTwo,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/my/inProgress',
        queryParameters: {'onlyTwo': onlyTwo},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => ChallengeInProgressModel.fromJson(e))
            .toList();
      }
      throw Exception('챌린지 로드 실패');
    } on DioException catch (e) {
      throw Exception('네트워크 에러: ${e.message}');
    }
  }

  // 내 페이지 - 나의 챌린지 - 완료한 챌린지
  Future<List<ChallengeInProgressModel>> getSuccessChallenges({
    required bool onlyTwo,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/my/success',
        queryParameters: {'onlyTwo': onlyTwo},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => ChallengeInProgressModel.fromJson(e))
            .toList();
      }
      throw Exception('완료된 챌린지 로드 실패');
    } on DioException catch (e) {
      throw Exception('네트워크 에러: ${e.message}');
    }
  }

  // 내페이지 - 나의 챌린지 - 실패한 챌린지
  Future<List<ChallengeInProgressModel>> getFailedChallenges({
    required bool onlyTwo,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/my/fail', // 💡 실패 챌린지 엔드포인트
        queryParameters: {'onlyTwo': onlyTwo},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => ChallengeInProgressModel.fromJson(e))
            .toList();
      }
      throw Exception('실패한 챌린지 로드 실패');
    } on DioException catch (e) {
      throw Exception('네트워크 에러: ${e.message}');
    }
  }

  // 챌린지 검색 API
  Future<List<SearchChallengeModel>> searchChallenges({
    required String keyword,
    int page = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/search',
        queryParameters: {'keyword': keyword, 'page': page},
      );

      if (response.statusCode == 200) {
        // API 명세상 페이징 객체 내부의 'content' 리스트를 파싱합니다.
        final List<dynamic> content = response.data['content'] ?? [];
        return content
            .map((json) => SearchChallengeModel.fromJson(json))
            .toList();
      } else {
        throw Exception('검색 결과 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 검색 API 에러: ${e.response?.data}');
      throw Exception('검색 중 오류가 발생했습니다.');
    }
  }

  // 챌린지 참여하기 api
  Future<void> participateChallenge(int challengeId) async {
    try {
      debugPrint('🚀 [POST Request] /api/challenges/$challengeId/participate');

      final response = await _dio.post(
        '/api/challenges/$challengeId/participate',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('챌린지 참여에 실패했습니다.');
      }
      debugPrint('✅ 챌린지 참여 성공');
    } on DioException catch (e) {
      debugPrint('❌ 챌린지 참여 API 에러: ${e.response?.data}');
      throw Exception(
        e.response?.data?['message'] ?? '이미 참여 중이거나 참여할 수 없는 챌린지입니다.',
      );
    }
  }

  /// 챌린지 친구 초대
  /// API: POST /api/challenges/{challengeId}/invite/{friendNickname}
  Future<void> inviteFriend(int challengeId, String friendNickname) async {
    try {
      // POST 요청 전송
      await _dio.post('/api/challenges/$challengeId/invite/$friendNickname');
    } catch (e) {
      // 에러 발생 시 호출한 곳(UI)으로 에러를 던짐
      rethrow;
    }
  }

  /*
  // 챌린지 초대 탭 정보 조회 (링크 + 친구목록 + 초대여부)
  // GET /api/challenges/{challengeId}/invite
  Future<ChallengeInviteResponse> getChallengeInviteInfo(
    int challengeId,
  ) async {
    try {
      final response = await _dio.get('/api/challenges/$challengeId/invite');

      if (response.statusCode == 200) {
        return ChallengeInviteResponse.fromJson(response.data);
      } else {
        throw Exception('초대 정보 조회 실패');
      }
    } catch (e) {
      rethrow;
    }
  }
  */
  // 디버깅 모드
  Future<ChallengeInviteResponse> getChallengeInviteInfo(
    int challengeId,
  ) async {
    try {
      debugPrint('🚀 [API 요청 시작] /api/challenges/$challengeId/invite');

      final response = await _dio.get('/api/challenges/$challengeId/invite');

      debugPrint('📥 [API 응답 코드] ${response.statusCode}');
      debugPrint('📦 [API 응답 데이터 원본] ${response.data}'); // ★ 여기가 핵심!

      if (response.statusCode == 200) {
        try {
          final result = ChallengeInviteResponse.fromJson(response.data);
          debugPrint(
            '✅ [파싱 성공] 친구 수: ${result.friends.length}명 / 링크: ${result.challengeLink}',
          );
          return result;
        } catch (e) {
          debugPrint('⚠️ [파싱 에러] 모델 변환 실패: $e');
          debugPrint('🔍 [파싱 실패 데이터] ${response.data}');
          rethrow;
        }
      } else {
        throw Exception('초대 정보 조회 실패 (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ [API 에러 발생] $e');
      rethrow;
    }
  }

  // 챌린지 멤버 조회 API
  // page: 필수 (0부터 시작)
  // nickname: 선택 (검색어)
  Future<List<ChallengeMember>> getChallengeMembers(
    int challengeId, {
    int page = 0,
    String? nickname,
  }) async {
    print(
      '🔥 [API Request] 챌린지($challengeId) 멤버 조회 요청 (Page: $page, Nickname: $nickname)',
    );

    try {
      // 1. 쿼리 파라미터 구성
      final Map<String, dynamic> queryParams = {
        'page': page,
        // 'size': 20, // 명세서에는 없지만, 보통 size도 같이 보냅니다. 필요시 주석 해제하세요.
      };

      // 닉네임이 있을 경우에만 파라미터에 추가
      if (nickname != null && nickname.isNotEmpty) {
        queryParams['nickname'] = nickname;
      }

      // 2. GET 요청 보내기
      final response = await _dio.get(
        '/api/challenges/$challengeId/members',
        queryParameters: queryParams,
      );

      print('✨ [API Response] Status: ${response.statusCode}');
      // 디버깅을 위해 서버가 주는 데이터 구조를 꼭 확인하세요!
      print('📦 [API Response] Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];

        // 3. 응답 데이터 파싱 (PageChallengeMemberResponse 대응)
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          // Case A: Spring Boot Page 객체인 경우 ({ "content": [...], "totalPages": ... })
          list = data['content'] as List;
          print('✅ [Parsing] Page 객체 감지됨. content 리스트 추출.');
        } else if (data is List) {
          // Case B: 그냥 리스트인 경우 ([...])
          list = data;
          print('✅ [Parsing] 단순 리스트 감지됨.');
        } else {
          // Case C: 예상치 못한 구조
          print('⚠️ [Parsing Warning] 예상치 못한 데이터 구조입니다. 확인이 필요합니다.');
          // 일단 data 자체를 리스트로 시도하거나 빈 리스트 반환
          if (data is List) list = data;
        }

        final members = list.map((e) => ChallengeMember.fromJson(e)).toList();
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

  // 챌린지장 위임 api
  Future<void> delegateChallengeOwner(
    int challengeId,
    int delegateMemberId,
  ) async {
    try {
      debugPrint(
        '🚀 [POST Request] /api/challenges/$challengeId/owner/delegate',
      );

      final response = await _dio.post(
        '/api/challenges/$challengeId/owner/delegate',
        data: {'delegateMemberId': delegateMemberId},
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

  // 챌린지 멤버 추방 API
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
}

// Riverpod Provider 설정
@riverpod
ChallengeRepository challengeRepository(ChallengeRepositoryRef ref) {
  // 1. 공통 dioProvider를 감시(watch)하여 인스턴스를 가져옵니다.
  final dio = ref.watch(dioProvider);

  // 2. 이미 모든 설정(BaseURL, 토큰 주입 등)이 끝난 dio를 넘겨줍니다.
  return ChallengeRepository(dio);
}

// 챌린지 초대 정보 Provider
// ChallengeInviteContent에서 ref.watch(challengeInviteInfoProvider(challengeId))로 사용
// .autoDispose 추가
// TODO: autoDispose 제거 고려
final challengeInviteInfoProvider = FutureProvider.autoDispose
    .family<ChallengeInviteResponse, int>((ref, challengeId) async {
      final repo = ref.watch(challengeRepositoryProvider);
      return await repo.getChallengeInviteInfo(challengeId);
    });
