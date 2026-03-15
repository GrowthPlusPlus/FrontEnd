// 최초 작성자: 정승빈
// 프로필 조회, 수정, 이미지 업로드/삭제 로직 전담 (Fat UI 해결)
// 최초 작성자: 정승빈
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/user_repository.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart'; // myProfileProvider 무효화를 위해
import 'tag_provider.dart';

part 'user_profile_provider.g.dart';

@riverpod
class UserProfile extends _$UserProfile {
  @override
  FutureOr<void> build() {
    // 초기 상태는 아무 작업도 하지 않은 상태
  }

  // 1. 프로필 이미지 즉시 삭제
  Future<void> deleteProfileImage() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(userRepositoryProvider).deleteProfileImage();
      ref.invalidate(myProfileProvider); // 마이페이지 프로필 상태 갱신
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // 2. 프로필 최종 저장 (닉네임, 한줄소개, 새 이미지, 태그)
  Future<void> updateProfile({
    required String currentNickname,
    required String newNickname,
    required String currentIntro,
    required String newIntro,
    File? newImageFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final tagNotifier = ref.read(tagProvider.notifier);

      // 1) 닉네임 변경
      if (newNickname != currentNickname) {
        await userRepo.updateNickname(newNickname);
      }

      // 2) 한 줄 소개 변경
      if (newIntro != currentIntro) {
        await userRepo.updateIntroduction(newIntro);
      }

      // 3) 프로필 이미지 변경
      if (newImageFile != null) {
        await userRepo.uploadProfileImage(newImageFile);
      }

      // 4) 태그 업데이트
      final tagSuccess = await tagNotifier.updateInterestTags();
      if (!tagSuccess) {
        throw Exception('태그 수정 중 오류가 발생했습니다.');
      }

      // 5) 성공 시 마이페이지 갱신
      ref.invalidate(myProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow; // UI에서 예외 메시지를 띄우기 위해 에러를 위로 던짐
    }
  }
}
