import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/features/home/data/home_repository.dart';
import 'package:haenaem/features/home/models/home_response.dart';

part 'home_provider.g.dart';

@riverpod
class HomeNotifier extends _$HomeNotifier {
  @override
  FutureOr<HomeResponse> build() async {
    return ref
        .watch(homeRepositoryProvider)
        .getHomeData(_getFormattedDate(DateTime.now()));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(homeRepositoryProvider)
          .getHomeData(_getFormattedDate(DateTime.now())),
    );
  }

  // ♥️ 삭제할 거임 여기부터
  //✅ 인증 완료 시 서버 재조회 없이 로컬 상태만 즉시 갱신
  void markChallengeAsDone(int challengeId) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedChallenges = current.myChallenges.map((c) {
      if (c.challengeBase.id == challengeId) {
        return c.copyWith(isDone: true);
      }
      return c;
    }).toList();

    state = AsyncValue.data(
      HomeResponse(
        myChallenges: updatedChallenges,
        notificationNumber: current.notificationNumber,
      ),
    );
  }

  // ♥️ 여기까지

  String _getFormattedDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }
}
