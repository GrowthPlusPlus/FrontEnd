// 최초 작성자 : 김채영
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';
import 'package:haenaem/shared/models/user.dart';

part 'user_provider.g.dart';

// 앱 전체에서 현재 로그인한 사용자의 정보를 관리하는 전역 상태 클래스

@Riverpod(keepAlive: true) // 앱이 켜져 있는 동안 데이터를 계속 유지
class CurrentUser extends _$CurrentUser {
  @override
  UserProfileModel? build() {
    return null; // 초기값은 로그인 전이므로 null
  }

  // 사용자 정보 업데이트 (로그인 시 호출)
  void setUser(UserProfileModel user) {
    state = user;
  }

  // 로그아웃 시 호출
  void clearUser() {
    state = null;
  }
}
