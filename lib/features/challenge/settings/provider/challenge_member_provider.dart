/// 최초 작성자: 정승빈
library;

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// import '../../data/challenge_repository.dart';
import '../data/challenge_member_repository.dart';
import 'package:haenaem/shared/models/user.dart';

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
class ChallengeMembers extends _$ChallengeMembers {
  @override
  Future<List<User>> build(MemberFilter filter) async {
    // repository를 감시(watch)하여 멤버 목록을 받아옵니다.
    final repository = ref.watch(challengeMemberRepositoryProvider);
    return repository.getChallengeMembers(
      filter.challengeId,
      page: filter.page,
      nickname: filter.nickname,
    );
  }

  /// 🚀 새로 추가된 방장 위임 API 호출 메소드
  /// 성공하면 true, 실패하면 false를 반환하여 UI에서 분기 처리할 수 있게 합니다.
  Future<bool> delegateOwnerAuto({required int challengeId}) async {
    // 변경 작업이 일어나는 동안 UI에 로딩 상태를 알리기 위해 state를 loading으로 전환합니다.
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(challengeMemberRepositoryProvider);

      // 1. Repository의 API 호출 실행
      await repository.delegateChallengeOwnerAuto(challengeId);

      // 2. 위임이 성공했다면 멤버 리스트를 새로고침(invalidate) 해줍니다.
      ref.invalidateSelf();

      debugPrint('✅ [Provider] 방장 위임 성공 및 리스트 새로고침 완료');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] 방장 위임 실패: $e');
      // 에러가 발생하면 기존 상태에 에러를 얹어줍니다.
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
