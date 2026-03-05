// 최초 작성자 : 김채영
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../challenge/data/challenge_repository.dart';
import '../../challenge/model/challenge_model.dart';
import 'package:haenaem/features/user/model/user_model.dart';
import 'package:haenaem/features/user/data/user_repository.dart';
import 'package:flutter/foundation.dart';
import '../../auth/signup/models/signup_state.dart';

final tagProvider = NotifierProvider<TagNotifier, SignupState>(() {
  return TagNotifier();
});

class TagNotifier extends Notifier<SignupState> {
  List<ChallengeTagModel> _allServerTags = [];
  List<String> _initialTagNames = []; // 수정 전 초기 상태 저장용

  @override
  SignupState build() {
    return SignupState();
  }

  // 1. 초기 데이터 로드 (전체 태그 + 내 프로필 태그)
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(userRepositoryProvider);

      // 전체 태그와 내 프로필 동시 로드
      final results = await Future.wait([
        repository.getAllTags(),
        repository.getMyProfile(), // GET /api/users/me/profile
      ]);

      _allServerTags = results[0] as List<ChallengeTagModel>;
      final profile = results[1] as UserProfileModel; // 프로필 모델 가정

      _initialTagNames = List<String>.from(profile.tags);

      // 카테고리 분류 (채영님이 만든 로직 그대로)
      final Map<String, List<String>> grouped = {};
      for (var tagModel in _allServerTags) {
        final category = tagModel.tagCategory;
        if (!grouped.containsKey(category)) grouped[category] = [];
        grouped[category]!.add(tagModel.tag);
      }

      state = state.copyWith(
        categorizedTags: grouped,
        tags: _initialTagNames, // 현재 선택된 상태를 내 태그로 초기화
        isLoading: false,
      );
    } catch (e) {
      debugPrint("🚨 로드 실패: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  // 태그 토글 로직 (채영님 코드와 동일)
  void toggleTag(String tag) {
    final currentTags = List<String>.from(state.tags);
    if (currentTags.contains(tag)) {
      currentTags.remove(tag);
    } else if (currentTags.length < 6) {
      currentTags.add(tag);
    }
    state = state.copyWith(tags: currentTags);
  }

  // 태그 서버 전송
  Future<bool> updateInterestTags() async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(userRepositoryProvider);

      // (1) 추가된 태그 이름 추출
      final addedTagNames = state.tags
          .where((name) => !_initialTagNames.contains(name))
          .toList();
      // (2) 삭제된 태그 이름 추출
      final deletedTagNames = _initialTagNames
          .where((name) => !state.tags.contains(name))
          .toList();

      // (3) 이름을 ID로 변환
      final List<int> addedIds = addedTagNames
          .map<int>(
            (name) => _allServerTags.firstWhere((t) => t.tag == name).tagId,
          )
          .toList();

      final List<int> deletedIds = deletedTagNames
          .map<int>(
            (name) => _allServerTags.firstWhere((t) => t.tag == name).tagId,
          )
          .toList();

      // (4) API 호출
      if (addedIds.isNotEmpty) {
        await repository.addUserTags(addedIds); // POST /api/users/me/tags
      }
      if (deletedIds.isNotEmpty) {
        await repository.deleteUserTags(
          deletedIds,
        ); // DELETE /api/users/me/tags
      }

      // 성공 시 초기 상태 업데이트
      _initialTagNames = List<String>.from(state.tags);
      return true;
    } catch (e) {
      debugPrint("🚨 수정 실패: $e");
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
