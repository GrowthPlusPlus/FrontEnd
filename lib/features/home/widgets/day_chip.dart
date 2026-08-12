import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final String status; // 'GRAY', 'NONE', 'RED', 'GREEN'을 받습니다.

  const DayChip({
    super.key,
    required this.date,
    this.isSelected = false,
    this.status = 'GRAY', // 기본값
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    Color gray2 = appColors.gray2;

    // 요일 레이블 매핑
    const weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];
    String label = weekdayLabels[date.weekday - 1];
    String day = date.day.toString();

    // 상태가 RED나 GREEN일 때는 배경색이 들어가므로 테두리를 지우고 글자를 흰색으로 변경
    final bool isColoredStatus = status == 'RED' || status == 'GREEN';
    final bool showBorder = isSelected && !isColoredStatus;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.b1.copyWith(color: appColors.blackToWhite),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: ShapeDecoration(
              color: getBackgroundColor(appColors),
              shape: RoundedRectangleBorder(
                // 오늘 날짜이면서 색상이 안 들어간 상태일 때만 테두리 적용
                side: showBorder
                    ? BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignOutside,
                        color: gray2,
                      )
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              day,
              style: TextStyle(
                color: isColoredStatus ? appColors.whiteToBlack : gray2,
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getBackgroundColor(AppColorsExtension appColors) {
    switch (status) {
      case 'RED':
        return appColors.notification;
      case 'GREEN':
        return appColors.primaryAble;
      case 'GRAY':
      case 'NONE':
      default:
        return appColors.gray5;
    }
  }
}
