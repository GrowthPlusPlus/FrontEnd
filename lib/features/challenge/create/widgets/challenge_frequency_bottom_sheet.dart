// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/widgets/custom_bottom_sheet.dart';

// 챌린지 인증 빈도(매일, 주 N회 등)를 선택하는 바텀시트
class ChallengeFrequencyBottomSheet extends StatelessWidget {
  final String? selectedFrequency;
  final Function(String frequency) onFrequencySelected;

  const ChallengeFrequencyBottomSheet({
    super.key,
    this.selectedFrequency,
    required this.onFrequencySelected,
  });

  @override
  Widget build(BuildContext context) {
    // 선택지 리스트 정의
    final items = ["매일", "주 1회", "주 2회", "주 3회", "주 4회", "주 5회", "주 6회"];

    return CustomBottomSheet(
      title: "인증 빈도",
      heightFactor: 0.55,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedFrequency == item;

          return GestureDetector(
            onTap: () {
              onFrequencySelected(item);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.selected : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Text(
                item,
                style: AppTypography.b1.copyWith(
                  color: isSelected ? AppColors.primaryAble : AppColors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
