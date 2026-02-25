// 최초 작성자: 정승빈
// '챌린지 초대' 탭 화면
import 'package:flutter/material.dart';
import '../widgets/challenge_invite_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../provider/notification_provider.dart';
import '../../challenge/detail/screens/challenge_main_screen.dart';

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
            // 수락 콜백 연결
            onAccept: () async {
              await notifier.acceptInvite(invite.challengeId);

              if (context.mounted) {
                // 다이얼로그(showDialog) 대신 스낵바를 띄웁니다.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${invite.challengeTitle} 초대를 수락했습니다.'),
                    behavior: SnackBarBehavior.floating, // 화면 아래에 살짝 떠 있는 스타일
                    duration: const Duration(seconds: 3),
                    // ✨ 꿀팁: 스낵바 우측에 '이동' 버튼 추가
                    action: SnackBarAction(
                      label: '이동',
                      textColor: AppColors.primaryAble, // 앱 테마색 (초록)
                      onPressed: () {
                        // '이동'을 누르면 해당 챌린지 방으로 라우팅
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChallengeMainScreen(
                              challengeId: invite.challengeId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
            // 거절 콜백 연결
            onReject: () async {
              await notifier.rejectInvite(invite.challengeId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${invite.challengeTitle} 초대를 거절했습니다.'),
                    behavior: SnackBarBehavior.floating, // 화면 아래에 살짝 떠 있는 스타일
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
