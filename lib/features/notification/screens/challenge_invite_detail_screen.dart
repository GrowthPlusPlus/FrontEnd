// 최초 작성자: 정승빈
// 챌린지 초대 알림 카드를 눌렀을 때 보여지는 상세 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../challenge/provider/challenge_provider.dart';
import '../../challenge/detail/widgets/challenge_detail_content.dart';
import '../../../shared/widgets/bottom_action_button.dart';
import '../provider/notification_provider.dart';
import 'package:haenaem/features/feed/widgets/enter_confirm_dialog.dart';

class ChallengeInviteDetailScreen extends ConsumerWidget {
  final int challengeId;
  final String inviterName;
  final String? inviterProfileImageUrl;

  const ChallengeInviteDetailScreen({
    super.key,
    required this.challengeId,
    required this.inviterName,
    this.inviterProfileImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 기존 InformationView에서 쓰던 Provider를 똑같이 사용하여 상세 데이터를 불러옵니다.
    final challengeAsync = ref.watch(
      challengeDetailProvider(challengeId: challengeId),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg', // 기존 앱바 아이콘 통일
            width: 24,
          ),
        ),
        title: const Text('챌린지 상세정보', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: challengeAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryAble),
        ),
        error: (error, stack) {
          // 에러 메시지에 404 또는 NOT_FOUND가 포함되어 있는지 확인합니다.
          final errorString = error.toString();
          final isDeleted =
              errorString.contains('404') || errorString.contains('NOT_FOUND');

          return Center(
            child: Text(
              // 상황에 따라 다른 텍스트를 노출합니다.
              isDeleted
                  ? '이미 삭제되었거나\n존재하지 않는 챌린지입니다.'
                  : '데이터를 불러오지 못했습니다.\n잠시 후 다시 시도해주세요.',
              textAlign: TextAlign.center,
              style: AppTypography.b1.copyWith(color: AppColors.gray2),
            ),
          );
        },
        data: (challenge) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. [상단 고정] 초대자 프로필 영역 (디자인 시안 반영)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: Row(
                children: [
                  _buildProfileIcon(inviterProfileImageUrl),
                  const SizedBox(width: 8),
                  Text(
                    '$inviterName님의 초대',
                    style: AppTypography.b1.copyWith(color: AppColors.gray2),
                  ),
                ],
              ),
            ),

            // 2. [스크롤 영역] 기존 '챌린지 상세 콘텐츠' 100% 재활용!
            Expanded(
              child: ChallengeDetailContent(
                challenge: challenge,
                scrollController: ScrollController(),
                showTitle: true, // true로 두면 "토익 단어 매일..." 제목이 예쁘게 나옵니다.
              ),
            ),
          ],
        ),
      ),

      // 하단 버튼 - 초대 수락하기 (클릭 시 수락 API 호출 + 참여 완료 다이얼로그 띄우기)
      bottomNavigationBar: challengeAsync.maybeWhen(
        // 데이터 로드 성공 시에만 버튼 표시
        data: (challenge) => BottomActionButton(
          text: '초대 수락하기',
          backgroundColor: AppColors.primaryAble,
          textColor: Colors.white,
          onPressed: () async {
            // 💡 1. 다이얼로그에 넘겨줄 챌린지 제목을 가져옵니다.
            final challenge = ref
                .read(challengeDetailProvider(challengeId: challengeId))
                .value;

            try {
              // 💡 2. 알림 프로바이더의 '수락' 함수 호출
              await ref
                  .read(challengeInviteProvider.notifier)
                  .acceptInvite(challengeId);

              if (context.mounted) {
                // 💡 3. 상세 화면을 먼저 닫습니다 (다이얼로그 뒤에 남지 않도록)
                Navigator.pop(context);

                // 💡 4. 참여 완료 다이얼로그 띄우기!
                showDialog(
                  context: context,
                  builder: (context) => EnterConfirmDialog(
                    challengeId: challengeId,
                    challengeTitle: challenge?.title ?? '챌린지', // 제목 전달
                  ),
                );
              }
            } catch (e) {
              // 수락 실패 시 에러 메시지 띄우기
              if (context.mounted) {
                final errorMsg = e.toString().replaceAll('Exception: ', '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg),
                    backgroundColor: AppColors.black, // 에러 느낌을 주려면 변경 가능
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        ),
        // 로딩 중이거나 에러(404 등) 상태면 버튼을 아예 안 그림 -> 클릭 불가 -> 앱 터짐 방지
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  // 상단 프로필 이미지 렌더링 함수
  Widget _buildProfileIcon(String? imageUrl) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.gray5,
        shape: BoxShape.circle,
        image: imageUrl != null && imageUrl.startsWith('http')
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : (imageUrl != null
                  ? DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null),
      ),
      child: imageUrl == null
          ? Center(
              child: SvgPicture.asset(
                'assets/images/icons/default_profile_icon.svg',
                width: 40,
              ),
            )
          : null,
    );
  }
}
