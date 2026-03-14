// 친구 목록 상태 및 편집 로직
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/social_repository.dart';
import '../../../shared/models/user.dart';

part 'friend_list_provider.g.dart';

@riverpod
class FriendList extends _$FriendList {
  @override
  Future<List<User>> build() async {
    // 초기 친구 목록 불러오기
    return ref.watch(socialRepositoryProvider).getFriendList();
  }

  // 친구 삭제 로직
  Future<void> removeFriend(String nickname) async {
    try {
      await ref.read(socialRepositoryProvider).deleteFriend(nickname);
      // 삭제 성공 시, 서버에서 목록을 다시 불러와서 UI 갱신
      ref.invalidateSelf();
    } catch (e) {
      // 에러 처리는 여기서 하거나, UI 단에서 잡을 수 있도록 던짐
      rethrow;
    }
  }
}
