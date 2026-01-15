// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';

// 화면 상단 진행률바
class SignupProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SignupProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final bool isCompleted = index < currentStep;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 4),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primaryAble : AppColors.gray4,
              borderRadius: BorderRadius.circular(1000),
            ),
          ),
        );
      }),
    );
  }
}
