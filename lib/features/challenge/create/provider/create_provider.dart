// 최초 작성자 : 강선욱
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/shared/models/challenge_base.dart';
import '../data/challenge_create_repository.dart';
import 'package:haenaem/shared/models/tag_model.dart';

part 'create_provider.g.dart'; // 파일명에 맞춰 변경

// 생성 상태(로딩/성공/에러)를 관리하는 Notifier
@riverpod
class ChallengeCreateNotifier extends _$ChallengeCreateNotifier {
  @override
  AsyncValue<ChallengeBase?> build() => const AsyncValue.data(null);

  Future<ChallengeBase?> create(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    // 비동기 실행 결과 가드
    final result = await AsyncValue.guard(
      () => ref.read(challengeCreateRepositoryProvider).createChallenge(data),
    );

    state = result;

    // 성공 시 ChallengeBase 객체를 반환하거나, 에러 시 null 반환
    return result.valueOrNull;
  }
}
