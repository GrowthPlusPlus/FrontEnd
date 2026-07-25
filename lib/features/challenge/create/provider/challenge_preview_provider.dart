// 최초 작성자 : 김채영
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/challenge_preview_repository.dart';

part 'challenge_preview_provider.g.dart';

@riverpod
class ChallengePreviewNotifier extends _$ChallengePreviewNotifier {
  @override
  FutureOr<void> build() {}

  /// 챌린지 이름이 AI 사진 검증(CLIP)에 적합한 이름인지 안내용으로 확인
  /// true: AI가 자동으로 판별하기 쉬운 이름 / false: 어려운 이름 (둘 다 생성 진행에는 영향 없음)
  Future<bool> checkTitle(String title) async {
    final repo = ref.read(challengePreviewRepositoryProvider);
    return repo.checkPreview(title);
  }
}
