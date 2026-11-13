/// 최초 작성자: 정승빈
library;

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// import '../../data/challenge_repository.dart';
import '../data/challenge_member_repository.dart';
import 'package:haenaem/shared/models/user.dart';
import 'package:haenaem/shared/provider/home_provider.dart';
import './challenge_delete_provider.dart';

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

  /// 🚀 방장 위임 및 탈퇴 (멤버 1명이면 자동 삭제 처리)
  Future<bool> delegateOwnerAuto({required int challengeId}) async {
    state = const AsyncValue.loading();

    try {
      final memberRepository = ref.read(challengeMemberRepositoryProvider);

      // 1. 현재 챌린지 멤버 목록 조회 (상태값 참조 또는 API 직접 확인)
      List<User> members = state.value ?? [];
      if (members.isEmpty) {
        members = await memberRepository.getChallengeMembers(challengeId);
      }

      // 2. 멤버가 1명 이하(본인뿐)인 경우 ➡️ ChallengeDeleteNotifier 사용해서 삭제 실행
      if (members.length <= 1) {
        // 작성하신 ChallengeDeleteNotifier 호출
        final isDeleted = await ref
            .read(challengeDeleteNotifierProvider.notifier)
            .removeChallenge(challengeId);

        if (isDeleted) {
          return true;
        } else {
          return false;
        }
      }

      // 3. 멤버가 2명 이상인 경우 ➡️ 방장 자동 위임 API 실행
      await memberRepository.delegateChallengeOwnerAuto(challengeId);

      // 홈 리스트 갱신
      ref.read(homeNotifierProvider.notifier).refresh();

      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
