// 최초 작성자 : 김채영
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/shared/models/user.dart';
import 'package:haenaem/shared/models/user_detail.dart';
import 'package:haenaem/features/user/data/user_repository.dart';

part 'user_provider.g.dart';
// 앱 전체에서 현재 로그인한 사용자의 정보를 관리하는 전역 상태 클래스

@Riverpod(keepAlive: true) // 앱이 켜져 있는 동안 데이터를 계속 유지
class CurrentUser extends _$CurrentUser {
  @override
  User? build() {
    return null;
  }

  // 로그인 시 호출
  void setUser(User user) {
    state = user;
  }

  // 로그아웃 시 호출
  void clearUser() {
    state = null;
  }

  // 닉네임만 업데이트
  void updateNickname(String nickname) {
    state = state?.copyWith(nickname: nickname);
  }

  // 프로필 이미지만 업데이트
  void updateProfileImage(String? profileUrl) {
    state = state?.copyWith(profileUrl: profileUrl);
  }
}

@riverpod
class MyProfile extends _$MyProfile {
  @override
  FutureOr<UserDetail> build() async {
    final userRepo = ref.read(userRepositoryProvider);
    final detail = await userRepo.getMyProfile();

    // ✨ [1. 초기 로드 시 자동 업데이트]
    // 프로필 상세를 가져오자마자 기본 정보(User)를 전역 상태에 꽂아줍니다.
    ref.read(currentUserProvider.notifier).setUser(detail.user);

    return detail;
  }

  // API 호출 없이 로컬 상세 정보만 업데이트
  void updateLocalDetail({
    String? introduction,
    List<String>? tags,
    String? nickname,
    String? profileUrl,
  }) {
    state.whenData((current) {
      // 새로운 유저 객체 생성
      final updatedUser = current.user.copyWith(
        nickname: nickname ?? current.user.nickname,
        profileUrl: profileUrl ?? current.user.profileUrl,
      );
      // 2. 업데이트된 User를 포함하여 UserDetail 전체 상태를 갱신합니다.
      state = AsyncData(
        current.copyWith(
          user: updatedUser,
          introduction: introduction ?? current.introduction,
          tags: tags ?? current.tags,
        ),
      );
    });
  }
}
