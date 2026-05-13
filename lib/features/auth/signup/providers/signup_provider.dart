// 최초 작성자: 김채영
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:haenaem/features/challenge/models/challenge_model.dart';
import 'package:haenaem/shared/models/tag_model.dart';
import '../models/signup_state.dart';
import 'package:haenaem/features/user/data/user_repository.dart';

// 회원가입 상태를 관리하는 Provider 정의
final signupProvider = NotifierProvider<SignupNotifier, SignupState>(() {
  return SignupNotifier();
});

class SignupNotifier extends Notifier<SignupState> {
  List<ChallengeTagModel> _allServerTags = []; // 태그 ID 조회를 위한 원본 백업

  @override
  SignupState build() {
    return SignupState(); // 초기 상태 반환
  }

  // 로컬 상태만 업데이트
  void updateNickname(String nickname) =>
      state = state.copyWith(nickname: nickname);
  void updateImage(File? image) => state = state.copyWith(profileImage: image);
  void updateBio(String bio) => state = state.copyWith(bio: bio);

  // // 닉네임을 설정하고 중복 여부를 확인합니다.
  // // 반환값: true (중복 발생), false (설정 성공)
  // Future<bool> updateNicknameAndCheckDuplicate(String nickname) async {
  //   try {
  //     final repository = ref.read(challengeRepositoryProvider);
  //     await repository.updateNickname(nickname); // 💡 Repo 메서드 호출

  //     state = state.copyWith(nickname: nickname);
  //     return false; // 성공 (중복 아님)
  //   } on DioException catch (e) {
  //     if (e.response?.statusCode == 409) return true; // 중복임
  //     rethrow;
  //   }
  // }

  // /// 프로필 이미지 전용 업로드 API 호출
  // Future<bool> uploadProfileImage(File imageFile) async {
  //   try {
  //     final repository = ref.read(challengeRepositoryProvider);
  //     await repository.uploadProfileImage(imageFile); // 💡 Repo 메서드 호출
  //     return true;
  //   } catch (e) {
  //     debugPrint("🚨 이미지 업로드 실패: $e");
  //     return false;
  //   }
  // }

  // // 한 줄 소개 업데이트 API 호출
  // Future<bool> updateIntroduction(String bio) async {
  //   try {
  //     final repository = ref.read(challengeRepositoryProvider);
  //     await repository.updateIntroduction(bio); // 💡 Repo 메서드 호출
  //     return true;
  //   } catch (e) {
  //     debugPrint("🚨 한 줄 소개 업데이트 실패: $e");
  //     return false;
  //   }
  // }

  // 전체 태그 조회 및 카테고리별 분류
  // 태그 정보 로드
  Future<void> fetchAllTags() async {
    try {
      // 리포지토리 호출
      final repository = ref.read(userRepositoryProvider);
      _allServerTags = await repository.getAllTags();

      // 카테고리별 분류 로직
      final Map<String, List<String>> grouped = {};
      for (var tagModel in _allServerTags) {
        final category = tagModel.tagCategory;
        final name = tagModel.tag;

        if (!grouped.containsKey(category)) {
          grouped[category] = [];
        }
        grouped[category]!.add(name);
      }

      state = state.copyWith(categorizedTags: grouped);
      debugPrint("✅ 태그 API 연동 성공: ${_allServerTags.length}개 태그 로드");
    } catch (e) {
      debugPrint("🚨 태그 로드 실패: $e");
    }
  }

  // // 선택된 태그 이름들을 ID로 변환하여 서버에 전송
  // Future<bool> submitTags() async {
  //   if (state.tags.isEmpty) return false;

  //   state = state.copyWith(isLoading: true);
  //   try {
  //     // 1. 이름(String) -> ID(int) 변환
  //     final List<int> selectedTagIds = state.tags.map((name) {
  //       return _allServerTags.firstWhere((t) => t.tag == name).tagId;
  //     }).toList();

  //     // 2. 서버 전송
  //     await ref
  //         .read(challengeRepositoryProvider)
  //         .updateUserTags(selectedTagIds);

  //     state = state.copyWith(isLoading: false);
  //     return true;
  //   } catch (e) {
  //     debugPrint("🚨 태그 제출 실패: $e");
  //     state = state.copyWith(isLoading: false);
  //     return false;
  //   }
  // }

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

  //   // 서버에 최종 회원가입 요청 전송
  //   Future<bool> submitSignup() async {
  //     // 최종 안전장치: 태그가 유효하지 않으면 서버에 아예 요청을 보내지 않음
  //     if (!state.isTagsValid) {
  //       debugPrint("🚨 태그가 선택되지 않아 가입 요청을 중단합니다.");
  //       return false;
  //     }
  //     state = state.copyWith(isLoading: true);

  //     try {
  //       // 💡 이제 _dio 대신 리포지토리를 사용합니다!
  //       final repository = ref.read(challengeRepositoryProvider);

  //       await repository.submitSignup(
  //         nickname: state.nickname,
  //         bio: state.bio,
  //         tags: state.tags,
  //         profileImage: state.profileImage,
  //       );

  //       debugPrint("🎉 회원가입 서버 전송 성공!");
  //       return true;
  //     } on DioException catch (e) {
  //       debugPrint("🌐 가입 요청 에러: ${e.response?.data ?? e.message}");
  //       return false;
  //     } finally {
  //       state = state.copyWith(isLoading: false);
  //     }
  //   }

  //   // 회원가입 절차가 모두 성공적으로 끝나면 상태를 초기화합니다.
  //   void resetState() {
  //     state = SignupState(); // 모델을 초기 상태로 되돌림
  //     _allServerTags = []; // 캐시된 서버 태그 목록 비우기
  //     debugPrint("🧹 회원가입 상태 초기화 완료 (성공 화면)");
  //   }
  // }

  // 닉네임 중복 여부만 확인 (서버 저장 X)
  // 반환값: true (중복 발생/사용 불가), false (사용 가능)
  Future<bool> checkNicknameDuplicate(String nickname) async {
    try {
      final repository = ref.read(userRepositoryProvider);

      // 백엔드 명세: GET /api/users/nickname-availability/{nickname}
      // 리포지토리에 해당 API 호출 메서드가 구현되어 있다고 가정합니다.
      final String message = await repository.checkNicknameAvailability(
        nickname,
      );

      // 응답 메시지에 "존재합니다"가 포함되어 있으면 중복으로 판단
      if (message.contains("동일한 닉네임이 존재합니다")) {
        debugPrint("🚩 중복 닉네임 감지: $nickname");
        return true;
      }
      return false; // 사용 가능
    } catch (e) {
      debugPrint("🚨 닉네임 중복 확인 실패: $e");
      // 에러 발생 시 안전하게 중복으로 간주하거나 예외 처리
      return true;
    }
  }

  /// 모든 정보를 한꺼번에 서버에 저장 (최종 가입)
  Future<bool> submitSignup() async {
    if (!state.isTagsValid) return false;

    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(userRepositoryProvider);

      // 💡 여기서 실제 데이터 저장이 순차적으로 일어납니다.
      // 1️⃣ 닉네임 설정 (이때 DB에 처음으로 저장됨)
      await repository.updateNickname(state.nickname);

      // 2️⃣ 프로필 이미지 업로드
      if (state.profileImage != null) {
        await repository.uploadProfileImage(state.profileImage!);
      }

      // 3️⃣ 한 줄 소개 업데이트
      if (state.bio.isNotEmpty) {
        await repository.updateIntroduction(state.bio);
      }

      // 4️⃣ 태그 업데이트
      final List<int> selectedTagIds = state.tags.map((name) {
        return _allServerTags.firstWhere((t) => t.tag == name).tagId;
      }).toList();
      await repository.updateUserTags(selectedTagIds);

      debugPrint("🎉 모든 정보 저장 완료. 가입 성공!");
      return true;
    } catch (e) {
      debugPrint("🚨 가입 처리 중 오류: $e");
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void resetState() {
    state = SignupState(); // 모델을 초기 상태로 되돌림
    _allServerTags = []; // 캐시된 서버 태그 목록 비우기
    debugPrint("🧹 회원가입 상태 초기화 완료 (성공 화면)");
  }
}
