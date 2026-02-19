/// 최초 작성자: 정승빈
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/challenge_repository.dart';
import '../model/user_model.dart';

part 'challenge_member_provider.g.dart';

// 입력을 받기 위한 파라미터 클래스 (선택 사항이지만 관리에 용이함)
class MemberFilter {
  final int challengeId;
  final int page;
  final String? nickname;

  MemberFilter({required this.challengeId, this.page = 0, this.nickname});

  // 객체 비교를 위해 hashCode, operator== 재정의가 필요할 수 있음 (equatable 패키지 추천)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberFilter &&
          runtimeType == other.runtimeType &&
          challengeId == other.challengeId &&
          page == other.page &&
          nickname == other.nickname;

  @override
  int get hashCode => Object.hash(challengeId, page, nickname);
}

@riverpod
Future<List<ChallengeMember>> challengeMembers(
  ChallengeMembersRef ref,
  MemberFilter filter, // int challengeId 대신 Filter 객체를 받음
) async {
  final repository = ref.watch(challengeRepositoryProvider);

  return repository.getChallengeMembers(
    filter.challengeId,
    page: filter.page,
    nickname: filter.nickname,
  );
}
