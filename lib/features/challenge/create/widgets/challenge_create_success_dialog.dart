// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/features/challenge/invite/widgets/challenge_invite_content.dart';

// 챌린지 생성 성공했을 경우 띄우는 작은 화면
class ChallengeCreateSuccessDialog extends StatelessWidget {
  final int challengeId; // 친구 초대 API 호출용
  final String challengeLink;

  const ChallengeCreateSuccessDialog({
    super.key,
    required this.challengeId, // 필수
    required this.challengeLink,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: const Alignment(0, -0.3),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        height: 700,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // 상단 그라데이션 헤더
            buildGradientHeader(),

            // 공통 초대 위젯 (여기서 검색, 리스트, 초대 로직 다 처리)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: ChallengeInviteContent(
                  // 공통 위젯 사용!
                  challengeId: challengeId,
                  challengeUrl: challengeLink,
                ),
              ),
            ),
            // 하단 닫기 버튼
            buildLaterButton(context),
          ],
        ),
      ),
    );
  }

  // 상단 그라데이션 헤더 위젯
  Widget buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF009951), Color(0xFF00C94D)],
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/icons/challenge_create_success_check.svg',
            width: 44,
            height: 44,
          ),
          const SizedBox(height: 12),
          Text(
            '챌린지 생성 완료!',
            style: AppTypography.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '친구들을 초대해서 함께 도전해보세요',
            style: AppTypography.b1.copyWith(
              color: Colors.white.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  // 나중에 초대하기 버튼
  Widget buildLaterButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '나중에 초대하기',
            style: AppTypography.b1.copyWith(color: AppColors.gray2),
          ),
        ),
      ),
    );
  }
}
