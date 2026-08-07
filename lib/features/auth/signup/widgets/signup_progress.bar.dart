// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';

// 화면 상단 진행률바
class SignupProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final Color? inactiveColor;

  const SignupProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Row(
      children: List.generate(totalSteps, (index) {
        final bool isCompleted = index < currentStep;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 4),
            decoration: BoxDecoration(
              // 지정된 색상이 없으면 기본 테마 색상 사용
              color: isCompleted
                  ? (activeColor ?? appColors.primaryAble)
                  : (inactiveColor ?? appColors.gray4),
              borderRadius: BorderRadius.circular(1000),
            ),
          ),
        );
      }),
    );
  }
}
