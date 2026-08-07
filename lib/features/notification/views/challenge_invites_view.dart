// 최초 작성자: 정승빈
// '챌린지 초대' 탭 화면
import 'package:flutter/material.dart';
import '../widgets/challenge_invite_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../provider/notification_provider.dart';
import '../../challenge/detail/screens/challenge_main_screen.dart';
import 'package:haenaem/shared/widgets/animated_toast.dart';

class ChallengeInvitesView extends ConsumerWidget {
  const ChallengeInvitesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    // 데이터 감지
    final state = ref.watch(challengeInviteProvider);
    final notifier = ref.read(challengeInviteProvider.notifier);

    Widget content;

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: appColors.primaryAble),
      );
    } else if (state.invites.isEmpty) {
      return Center(
        child: Text(
          '받은 챌린지 초대가 없습니다.',
          style: TextStyle(color: appColors.gray2),
        ),
      );
    } else {
      content = RefreshIndicator(
        onRefresh: () => notifier.fetchInvites(),
        color: appColors.primaryAble,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 10, bottom: 40),
          itemCount: state.invites.length,
          itemBuilder: (context, index) {
            final invite = state.invites[index];

            return ChallengeInviteCard(
              inviteChallenge: invite,
              // 수락 콜백 연결
              onAccept: () async {
                try {
                  await notifier.acceptInvite(invite.challengeInfo.base.id);

                  ref.read(needsHomeRefreshProvider.notifier).state =
                      true; // 홈 화면 새로고침 필요 플래그 켜기

                  if (context.mounted) {
                    // 위젯이 살아있을 때 안전한 Navigator를 미리 변수로 캡처해 둡니다.
                    final safeNavigator = Navigator.of(context);

                    // 다이얼로그(showDialog) 대신 스낵바를 띄웁니다.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${invite.challengeInfo.base.title} 초대를 수락했습니다.',
                        ),
                        behavior:
                            SnackBarBehavior.floating, // 화면 아래에 살짝 떠 있는 스타일
                        duration: const Duration(seconds: 3),
                        // 스낵바 우측에 '이동' 버튼 추가
                        action: SnackBarAction(
                          label: '이동',
                          textColor: appColors.primaryAble, // 앱 테마색 (초록)
                          onPressed: () {
                            // '이동'을 누르면 해당 챌린지 방으로 라우팅
                            safeNavigator.push(
                              MaterialPageRoute(
                                builder: (context) => ChallengeMainScreen(
                                  challengeId: invite.challengeInfo.base.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  // 수락 실패 시 에러 메시지 띄우기
                  if (context.mounted) {
                    final errorMsg = e.toString().replaceAll('Exception: ', '');
                    displayToast(context, errorMsg);
                  }
                }
              },
              // 거절 콜백 연결
              onReject: () async {
                try {
                  await notifier.rejectInvite(invite.challengeInfo.base.id);

                  ref.read(needsHomeRefreshProvider.notifier).state =
                      true; // 홈 화면 새로고침 필요 플래그 켜기

                  if (context.mounted) {
                    displayToast(
                      context,
                      '${invite.challengeInfo.base.title} 초대를 거절했습니다.',
                    );
                  }
                } catch (e) {
                  // 거절 실패 시 에러 메시지 띄우기
                  if (context.mounted) {
                    final errorMsg = e.toString().replaceAll('Exception: ', '');
                    displayToast(context, errorMsg);
                  }
                }
              },
            );
          },
        ),
      );
    }
    return Container(color: appColors.gray5, child: content);
  }
}
