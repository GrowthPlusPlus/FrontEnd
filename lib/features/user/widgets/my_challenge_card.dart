// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
//import '../../challenge/models/challenge_model.dart';
import '../models/my_page_challenge_card.dart';

// 내페이지 나의 챌린지의 챌린지 리스트에 속하는 챌린지 카드 위젯
// mypage challenge card 모델을 데이터로 받아서 화면에 그린다
class MyChallengeCard extends StatelessWidget {
  final MyPageChallengeCard item;

  const MyChallengeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // 상태별 테마 설정
    Color themeColor;
    String statusText;
    bool showBorder = item.status != ChallengeStatus.inProgress;

    switch (item.status) {
      case ChallengeStatus.success:
        themeColor = appColors.primaryAble;
        statusText = '완료';
        break;
      case ChallengeStatus.fail:
        themeColor = appColors.notification;
        statusText = '실패';
        break;
      case ChallengeStatus.inProgress:
      default:
        themeColor = AppColors.blue;
        statusText = '진행중';
        break;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: appColors.whiteToBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(width: 0.69, color: appColors.gray5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.challengeInfo.challengeBase.title,
                            style: AppTypography.b3.copyWith(
                              color: appColors.blackToWhite,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 7.35),
                        _buildStatusBadge(statusText, themeColor),
                      ],
                    ),
                    // ✅ 날짜 형식 수정
                    Text(
                      item.status == ChallengeStatus.inProgress
                          ? '주 ${item.challengeInfo.weeklyFrequency}회, 완료까지 D-${item.challengeInfo.dDay}'
                          : '$statusText일 ${item.failedDate?.toString().substring(0, 10).replaceAll('-', '/') ?? ''}',
                      style: AppTypography.b2.copyWith(color: appColors.gray2),
                    ),
                    // ✅ 스트리크/멤버 정보를 Column 안으로 이동
                    _buildDetailInfoRow(themeColor, appColors),
                  ],
                ),
              ),
              _buildProgressText(item.rate, themeColor, appColors),
            ],
          ),
          const SizedBox(height: 8),
          _buildGaugeBar(item.rate, themeColor, appColors),
        ],
      ),
    );
  }

  // --- 하단 상세 정보 (스트리크 + 멤버 참여도) ---
  Widget _buildDetailInfoRow(Color themeColor, AppColorsExtension appColors) {
    final info = item.challengeInfo;
    return Row(
      children: [
        // ✅ ChallengeCard와 동일한 조건 적용
        if (info.streakCount > 0 && info.isDone)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: SvgPicture.asset(
              'assets/images/icons/small_fire_icon.svg',
              width: 14,
            ),
          ),
        Text(
          '${info.streakCount}일째', // ✅ currentStreak 매핑
          style: AppTypography.b2.copyWith(color: appColors.blackToWhite),
        ),
        const SizedBox(width: 12),
        SvgPicture.asset(
          'assets/images/icons/mini_success_icon.svg',
          width: 16,
        ),
        const SizedBox(width: 4),
        // 예: 3/5명 인증 완료
        Text(
          '${info.successParticipantCount}/${info.participantCount}명',
          style: AppTypography.b2.copyWith(color: appColors.blackToWhite),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: AppTypography.c1.copyWith(color: color)),
    );
  }

  Widget _buildProgressText(
    double progress,
    Color color,
    AppColorsExtension appColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${progress.toInt()}%',
          style: AppTypography.h2.copyWith(color: color),
        ),
        Text('달성률', style: AppTypography.c1.copyWith(color: appColors.gray2)),
      ],
    );
  }

  Widget _buildGaugeBar(
    double progress,
    Color color,
    AppColorsExtension appColors,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: LinearProgressIndicator(
        value: (progress / 100).clamp(0.0, 1.0),
        minHeight: 4,
        backgroundColor: appColors.gray5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
