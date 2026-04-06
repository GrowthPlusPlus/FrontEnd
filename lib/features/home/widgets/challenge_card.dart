import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

import 'package:haenaem/shared/models/home_challenge_card.dart';
import 'package:haenaem/features/challenge/detail/screens/challenge_main_screen.dart';

// 홈탭의 챌린지 카드
class ChallengeCard extends StatelessWidget {
  final HomeChallengeCard challenge;

  const ChallengeCard({super.key, required this.challenge});

  Color get _cardColor {
    if (challenge.isDone) return AppColors.success;
    if (challenge.warning) return AppColors.warning;
    return AppColors.gray5;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeMainScreen(
              challengeId: challenge.challengeBase.id,
              challengeTitle: challenge.challengeBase.title,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.challengeBase.title,
                        style: AppTypography.b1.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildFrequencyAndDDayInfo(),
                      const SizedBox(height: 4),
                      _buildStreakAndParticipantInfo(),

                      if (challenge.warning) ...[
                        const SizedBox(height: 4),
                        _buildWarningText(),
                      ],
                    ],
                  ),
                ),
                _buildDivider(),
                SizedBox(width: 44, child: Center(child: _buildStatusIcon())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyAndDDayInfo() {
    final frequencyText = challenge.weeklyFrequency == 7
        ? '매일'
        : '주 ${challenge.weeklyFrequency}회';
    final dDayText = challenge.dDay == 0 ? '오늘 종료' : '완료까지 D-${challenge.dDay}';
    return Text(
      '$frequencyText, $dDayText',
      style: AppTypography.b2.copyWith(fontSize: 14),
    );
  }

  Widget _buildStreakAndParticipantInfo() {
    if (challenge.warning) {
      return const Text(
        '오늘 챌린지를 하지 않으면 실패해요!',
        style: TextStyle(color: AppColors.notification, fontSize: 12),
      );
    }
    return Row(
      children: [
        // 스트릭 정보: streakCount > 0 && isDone일 때 불꽃 아이콘 표시
        if (challenge.streakCount > 0 && challenge.isDone)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: SvgPicture.asset(
              'assets/images/icons/small_fire_icon.svg',
              width: 16,
              height: 16,
            ),
          ),
        Text(
          '${challenge.streakCount}일째',
          style: AppTypography.b2.copyWith(fontSize: 14),
        ),
        const SizedBox(width: 12),
        // 인증인원 정보
        SvgPicture.asset(
          'assets/images/icons/mini_success_icon.svg',
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${challenge.successParticipantCount}/${challenge.participantCount}명',
          style: AppTypography.b2.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildWarningText() {
    return const Text(
      '오늘 챌린지를 하지 않으면 실패해요!',
      style: TextStyle(color: AppColors.notification, fontSize: 12),
    );
  }

  Widget _buildDivider() {
    return SizedBox(
      width: 40,
      child: Center(
        child: CustomPaint(
          size: const Size(1, double.infinity),
          painter: VerticalDashPainter(),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (challenge.isDone)
      return SvgPicture.asset('assets/images/icons/success_icon.svg');
    if (challenge.warning)
      return SvgPicture.asset('assets/images/icons/warning_icon.svg');
    return const SizedBox(width: 24);
  }
}

class VerticalDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    // 캔버스의 중앙 X축 계산
    final double centerX = size.width / 2;
    final paint = Paint()
      ..color = AppColors
          .gray3 // 점선 색상 농도 조절
      ..strokeWidth = 1;

    while (startY < size.height) {
      // Offset의 X좌표를 centerX로 고정하여 직선도 유지
      canvas.drawLine(
        Offset(centerX, startY),
        Offset(centerX, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
