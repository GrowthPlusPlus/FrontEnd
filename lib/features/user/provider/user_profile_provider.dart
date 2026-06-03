// 최초 작성자: 정승빈
// 프로필 조회, 수정, 이미지 업로드/삭제 로직 전담 (Fat UI 해결)
// 최초 작성자: 정승빈
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/user_repository.dart';
import 'package:haenaem/features/user/provider/user_provider.dart';
import '../../../shared/provider/tag_provider.dart';

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
      ref
          .read(currentUserProvider.notifier)
          .updateProfileImage(null); // 전역 상태 업데이트
      ref
          .read(myProfileProvider.notifier)
          .updateLocalDetail(profileUrl: null); // 로컬 업데이트

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
        ref
            .read(currentUserProvider.notifier)
            .updateNickname(newNickname); // 전역 상태 업데이트
      }

      // 2) 한 줄 소개 변경
      if (newIntro != currentIntro) {
        await userRepo.updateIntroduction(newIntro);
      }

      // 3) 프로필 이미지 변경
      String? finalProfileUrl;
      if (newImageFile != null) {
        await userRepo.uploadProfileImage(newImageFile);

        // 업로드 후 새 URL 가져와서 전역 상태 업데이트
        final updatedUserDetail = await userRepo.getMyProfile();
        finalProfileUrl = updatedUserDetail.user.profileUrl;
        ref
            .read(currentUserProvider.notifier)
            .updateProfileImage(updatedUserDetail.user.profileUrl);
      }

      // 4) 태그 업데이트
      final tagSuccess = await tagNotifier.updateInterestTags();
      if (!tagSuccess) {
        throw Exception('태그 수정 중 오류가 발생했습니다.');
      }

      // 내페이지 전역 상태 로컬 업데이트
      ref
          .read(myProfileProvider.notifier)
          .updateLocalDetail(
            nickname: newNickname,
            introduction: newIntro,
            tags: ref.read(tagProvider).tags,
            profileUrl: finalProfileUrl, // 이미지가 바뀌었다면 새 URL, 아니면 기존 유지
          );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow; // UI에서 예외 메시지를 띄우기 위해 에러를 위로 던짐
    }
  }
}
