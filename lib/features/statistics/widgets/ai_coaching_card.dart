// 최초 작성자: 김채영

import 'package:flutter/material.dart';
import '../models/ai_coaching_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/core/theme/app_colors.dart';

// AI 코칭 카드 위젯
class AiCoachingCard extends StatelessWidget {
  final AiCoachingCardModel data;

  const AiCoachingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    const borderWidth = 4.0;
    const outerRadius = 12.0;
    const innerRadius = outerRadius - borderWidth;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(borderWidth),
      decoration: ShapeDecoration(
        gradient: aiCoachingCardBorderGradient,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(outerRadius),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: appColors.whiteToBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(innerRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(emoji: data.type.emoji, title: data.title),
            const SizedBox(height: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < data.bullets.length; i++) ...[
                  if (i != 0) const SizedBox(height: 20),
                  _BulletText(text: data.bullets[i]),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String emoji;
  final String title;

  const _CardHeader({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '$emoji $title',
            style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
          ),
        ),
        const SizedBox(width: 8),
        SvgPicture.asset('assets/images/icons/ai_analysis_badge.svg'),
      ],
    );
  }
}

/// 불릿(•) + 본문 텍스트 한 줄
class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText({required this.text});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, right: 10),
          child: SizedBox(
            width: 4,
            height: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTypography.b1.copyWith(color: appColors.blackToWhite),
          ),
        ),
      ],
    );
  }
}
