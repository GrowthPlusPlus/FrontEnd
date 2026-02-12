// 최초 작성자: 강선욱
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
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

  // 닉네임 업데이트 및 중복 체크
  Future<void> updateNickname(String nickname) async {
    await _dio.patch('/api/users/me/nickname', data: {"nickname": nickname});
  }

  // 프로필 이미지 업로드
  Future<void> uploadProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        imageFile.path,
        filename: "profile_${DateTime.now().millisecondsSinceEpoch}.jpg",
      ),
    });

    await _dio.post(
      '/api/users/me/profile-image',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // 한 줄 소개 업데이트
  Future<void> updateIntroduction(String introduction) async {
    await _dio.patch(
      '/api/users/me/introduction',
      data: {"introduction": introduction},
    );
  }

  // 전체 태그 조회
  Future<List<ChallengeTagModel>> getAllTags() async {
    try {
      final response = await _dio.get('/api/tags');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChallengeTagModel.fromJson(json)).toList();
      }
      throw Exception('태그 목록 로드 실패');
    } on DioException catch (e) {
      throw Exception('네트워크 에러: ${e.message}');
    }
  }

  // 유저 태그 선택 (회원가입/프로필 수정 시 사용)
  Future<void> updateUserTags(List<int> tagIds) async {
    try {
      final response = await _dio.post(
        '/api/users/me/tags',
        data: {'tagIds': tagIds},
      );

      if (response.statusCode != 204) {
        throw Exception('태그 업데이트 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 태그 업데이트 에러: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '태그 저장 중 오류 발생');
    }
  }

  Future<void> submitSignup({
    required String nickname,
    required String bio,
    required List<String> tags,
    File? profileImage,
  }) async {
    // 1. Multipart 데이터 준비
    final formData = FormData.fromMap({
      "nickname": nickname,
      "bio": bio,
      "tags": tags, // List<String> 형태
      if (profileImage != null)
        "profileImage": await MultipartFile.fromFile(
          profileImage.path,
          filename: "profile_${DateTime.now().millisecondsSinceEpoch}.jpg",
        ),
    });

    // 2. 요청 전송 (Interceptor 덕분에 토큰은 자동으로 붙습니다)
    await _dio.post(
      '/api/user/signup',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
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
    required List<File> imageFiles,
  }) async {
    try {
      final formData = FormData();

      // JSON 데이터를 파일 파트처럼 추가하여 타입을 명시
      formData.files.add(
        MapEntry(
          'data',
          MultipartFile.fromString(
            jsonEncode({
              "challengeId": challengeId,
              "content": content,
            }), // 필요한 데이터만
            contentType: MediaType('application', 'json'),
          ),
        ),
      );

      // 이미지 파일 추가
      for (var file in imageFiles) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              file.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      debugPrint('🚀 [API Request] /api/articles (Multipart 전송 시작)');

      final response = await _dio.post('/api/articles', data: formData);

      if (response.statusCode == 201) {
        return CertificationPostModel.fromJson(response.data);
      } else {
        throw Exception('인증글 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ 서버 응답 에러 (${e.response?.statusCode}): ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '게시글 업로드 실패');
    }
  }

  // 인증글 수정
  Future<CertificationPostModel> updateArticle({
    required int postId,
    required String content,
    required List<int> deleteImageIds, // 삭제할 이미지 ID들
    required List<File> newImages, // 새로 추가할 이미지 파일들
  }) async {
    try {
      final formData = FormData();

      // 1. JSON 데이터 (request 파트)
      formData.files.add(
        MapEntry(
          'request',
          MultipartFile.fromString(
            jsonEncode({"content": content, "deleteImageIds": deleteImageIds}),
            contentType: MediaType('application', 'json'),
          ),
        ),
      );

      // 2. 새 이미지 파일들 (images 파트)
      for (var file in newImages) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      debugPrint('🚀 [PATCH Request] /api/articles/$postId (Multipart)');

      final response = await _dio.patch(
        '/api/articles/$postId',
        data: formData,
      );

      if (response.statusCode == 200) {
        return CertificationPostModel.fromJson(response.data);
      } else {
        throw Exception('수정 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ 수정 에러: ${e.response?.data}');
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
  Future<bool> verifyImage(File imageFile) async {
    try {
      // 1. Multipart 데이터(FormData) 생성
      final formData = FormData.fromMap({
        // 스웨거 명세서의 키 이름이 "images"이므로 이를 따릅니다.
        // 만약 백엔드에서 단수형 "image"를 원한다면 수정이 필요할 수 있습니다.
        "images": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      debugPrint('🚀 [API Request] /api/image/verify (Multipart) 전송 시작');

      // 2. API 호출
      final response = await _dio.post(
        '/api/image/verify',
        data: formData,
        options: Options(contentType: 'multipart/form-data'), // Multipart 형식 명시
      );

      // 3. 성공 처리 (204 No Content)
      if (response.statusCode == 204) {
        debugPrint('✅ [204] 이미지 검증 성공');
        return true;
      }

      return false;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;

      debugPrint('❌ 이미지 검증 에러 ($statusCode): $errorData');

      // 413 에러(용량 초과)가 난다면 이미지 압축이 필요할 수 있습니다.
      if (statusCode == 413) {
        debugPrint('🚨 요청 용량 초과: 이미지 리사이징을 고려하세요.');
      }

      return false;
    } catch (e) {
      debugPrint('💻 [Client Error] 앱 내부 오류: $e');
      return false;
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

  // 내페이지 - 사용자 프로필 정보
  Future<UserProfileModel> getMyProfile() async {
    try {
      final response = await _dio.get('/api/users/me/profile');

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw Exception('프로필 조회 실패');
      }
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
