// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 다음 버튼 스타일
class NextButton extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const NextButton({
    super.key,
    required this.text,
    required this.isEnabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Material(
      color: isEnabled ? appColors.primaryAble : appColors.disable,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          height: 56,
          alignment: Alignment.center,
          child: Text(
            text,
            style: AppTypography.h3.copyWith(color: appColors.whiteToBlack),
          ),
        ),
      ),
    );
  }
}
