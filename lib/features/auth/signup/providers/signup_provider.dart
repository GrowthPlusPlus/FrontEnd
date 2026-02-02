// 최초 작성자: 김채영
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/signup_state.dart';

// 회원가입 상태를 관리하는 Provider 정의
final signupProvider = NotifierProvider<SignupNotifier, SignupState>(() {
  return SignupNotifier();
});

class SignupNotifier extends Notifier<SignupState> {
  final _storage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(baseUrl: 'https://hanaem.onrender.com'));
  List<Map<String, dynamic>> _rawServerTags = []; // 태그 ID 조회를 위한 원본 백업

  @override
  SignupState build() {
    return SignupState(); // 초기 상태 반환
  }

  // 닉네임 업데이트
  void updateNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  // 프로필 이미지 업데이트
  void updateImage(File? image) {
    state = state.copyWith(profileImage: image);
  }

  // 한 줄 소개 업데이트
  void updateBio(String bio) {
    state = state.copyWith(bio: bio);
  }

  // 닉네임을 설정하고 중복 여부를 확인합니다.
  // 반환값: true (중복 발생), false (설정 성공)
  Future<bool> updateNicknameAndCheckDuplicate(String nickname) async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');

      final response = await _dio.patch(
        '/api/users/me/nickname',
        data: {"nickname": nickname},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          contentType: Headers.jsonContentType,
        ),
      );

      // 204 No Content: 성공적으로 닉네임이 설정됨
      if (response.statusCode == 204) {
        state = state.copyWith(nickname: nickname); // 로컬 상태 동기화
        debugPrint("✅ 닉네임 설정 성공: $nickname");
        return false; // 중복 아님
      }
      return false;
    } on DioException catch (e) {
      // 409 Conflict: 서버에서 중복으로 판단하고 예외 반환
      if (e.response?.statusCode == 409) {
        debugPrint("🚩 중복된 닉네임: $nickname");
        return true; // 중복임
      }
      // 그 외 400(검증 실패) 등은 예외로 던짐
      debugPrint("🚨 닉네임 설정 중 서버 에러: ${e.response?.statusCode}");
      rethrow;
    }
  }

  /// 프로필 이미지 전용 업로드 API 호출
  Future<bool> uploadProfileImage(File imageFile) async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');

      // 명세서에 따라 'image' 파트로 파일 준비
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: "profile_${DateTime.now().millisecondsSinceEpoch}.jpg",
        ),
      });

      final response = await _dio.post(
        '/api/users/me/profile-image',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          contentType: 'multipart/form-data',
        ),
      );

      return response.statusCode == 204; // 204 No Content면 성공
    } on DioException catch (e) {
      debugPrint("🚨 이미지 업로드 실패: ${e.response?.statusCode}");
      return false;
    }
  }

  // 한 줄 소개 업데이트 API 호출
  Future<bool> updateIntroduction(String bio) async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');

      final response = await _dio.patch(
        '/api/users/me/introduction',
        data: {"introduction": bio}, // 서버 명세에 맞춰 'introduction' 키 사용
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          contentType: Headers.jsonContentType,
        ),
      );

      return response.statusCode == 204; // 성공 시 204 반환
    } on DioException catch (e) {
      debugPrint("🚨 한 줄 소개 업데이트 실패: ${e.response?.statusCode}");
      return false;
    }
  }

  // 전체 태그 조회 및 카테고리별 분류
  Future<void> fetchAllTags() async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');
      final response = await _dio.get(
        '/api/tags',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        _rawServerTags = List<Map<String, dynamic>>.from(response.data);

        // 자동 분류 로직
        final Map<String, List<String>> grouped = {};
        for (var item in _rawServerTags) {
          final category = item['tagCategory'] as String;
          final name = item['tag'] as String;

          if (!grouped.containsKey(category)) {
            grouped[category] = [];
          }
          grouped[category]!.add(name);
        }

        state = state.copyWith(categorizedTags: grouped);
        debugPrint("✅ 태그 분류 완료: ${grouped.keys.length}개 카테고리");
      }
    } catch (e) {
      debugPrint("🚨 태그 로드 실패: $e");
    }
  }

  // 태그 이름 리스트를 ID 리스트로 변환하여 서버에 제출
  // TODO: 임시 우회 로직 백엔드 태그 구현 후에 수정
  Future<bool> submitTags() async {
    return true; // 패스

    state = state.copyWith(isLoading: true);
    try {
      final accessToken = await _storage.read(key: 'accessToken');

      // 이름 리스트를 ID 리스트로 매핑
      final tagIds = state.tags.map((name) {
        return _rawServerTags.firstWhere((t) => t['tag'] == name)['tagId']
            as int;
      }).toList();

      final response = await _dio.post(
        '/api/users/me/tags',
        data: {"tagIds": tagIds},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      return response.statusCode == 204;
    } catch (e) {
      debugPrint("🚨 태그 제출 실패: $e");
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 가입 절차가 모두 끝나면 상태 초기화
  // 이 함수가 없으면 로그아웃 후 다른 계정으로 가입할 때 이전 데이터가 남아있을 수 있음
  void resetState() {
    state = SignupState();
    _rawServerTags = [];
    debugPrint("🧹 회원가입 상태 초기화 완료");
  }

  // 태그 토글 (추가/삭제)
  void toggleTag(String tag) {
    final currentTags = List<String>.from(state.tags);
    if (currentTags.contains(tag)) {
      currentTags.remove(tag);
    } else if (currentTags.length < 6) {
      currentTags.add(tag);
    }
    state = state.copyWith(tags: currentTags);
  }

  // 서버에 최종 회원가입 요청 전송
  Future<bool> submitSignup() async {
    state = state.copyWith(isLoading: true);

    try {
      // 저장된 Access Token 가져오기 (인증용)
      final accessToken = await _storage.read(key: 'accessToken');

      // Multipart 데이터 준비 (이미지 포함)
      final formData = FormData.fromMap({
        "nickname": state.nickname,
        "bio": state.bio,
        "tags": state.tags, // List<String> 형태
        if (state.profileImage != null)
          "profileImage": await MultipartFile.fromFile(
            state.profileImage!.path,
            filename: "profile_${DateTime.now().millisecondsSinceEpoch}.jpg",
          ),
      });

      final response = await _dio.post(
        '/api/user/signup',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("🎉 회원가입 서버 전송 성공!");
        return true;
      }
    } on DioException catch (e) {
      debugPrint("🌐 가입 요청 에러: ${e.response?.data ?? e.message}");
    } finally {
      state = state.copyWith(isLoading: false);
    }
    return false;
  }
}
