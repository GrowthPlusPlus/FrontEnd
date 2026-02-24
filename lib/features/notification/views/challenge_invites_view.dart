// 최초 작성자: 정승빈
// '챌린지 초대' 탭 화면
import 'package:flutter/material.dart';
import '../widgets/challenge_invite_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../provider/notification_provider.dart';

class ChallengeInvitesView extends ConsumerWidget {
  const ChallengeInvitesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 데이터 감지
    final state = ref.watch(challengeInviteProvider);
    final notifier = ref.read(challengeInviteProvider.notifier);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAble),
      );
    }

    if (state.invites.isEmpty) {
      return const Center(child: Text('받은 챌린지 초대가 없습니다.'));
    }

    return RefreshIndicator(
      onRefresh: () => notifier.fetchInvites(),
      color: AppColors.primaryAble,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 40),
        itemCount: state.invites.length,
        itemBuilder: (context, index) {
          final invite = state.invites[index];

          return ChallengeInviteCard(
            challengeId: invite.challengeId,
            inviterName: invite.inviterNickname,
            inviterProfileImageUrl: invite.inviterProfileImageUrl,
            challengeName: invite.challengeTitle,
            participantCount: invite.participantCount,
            dDay: 'D-${invite.remainingDays}',
            labels: invite.tags,
            // 수락/거절 콜백 연결
            onAccept: () => notifier.acceptInvite(invite.challengeId),
            onReject: () => notifier.rejectInvite(invite.challengeId),
          );
        },
      ),
    );
  }
}
