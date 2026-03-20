import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/models/challenge_model.dart';

class DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isDone;
  final bool isWarning;

  const DayChip({
    super.key,
    required this.date,
    this.isSelected = false,
    this.isDone = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color gray2 = AppColors.gray2;

    // 요일 레이블 매핑
    const weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
    String label = weekdayLabels[date.weekday % 7];
    String day = date.day.toString();

    // 테두리 결정 로직
    final bool showBorder = isSelected && !isDone && !isWarning;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.b1.copyWith(color: AppColors.black)),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: ShapeDecoration(
              color: getBackgroundColor(),
              shape: RoundedRectangleBorder(
                // 💡 오늘 날짜일 때만 테두리(Outside) 적용
                side: showBorder
                    ? const BorderSide(
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
                color: isSelected && (isDone || isWarning)
                    ? Colors.white
                    : gray2,
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

  Color getBackgroundColor() {
    if (!isSelected) return AppColors.gray5;

    if (isWarning) return AppColors.notification;
    if (isDone) return AppColors.primaryAble;
    return AppColors.gray5;
  }
}
