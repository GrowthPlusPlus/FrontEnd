// 최초 작성자: 정승빈
// '오늘', '어제', '1월 2일' 등을 표시하는 헤더
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class NotificationDateHeader extends StatelessWidget {
  final String dateText;

  const NotificationDateHeader({super.key, required this.dateText});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 4),
      child: Text(
        dateText,
        style: AppTypography.h3.copyWith(color: appColors.gray1),
      ),
    );
  }
}
