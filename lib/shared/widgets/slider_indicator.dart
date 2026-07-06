// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';

class SliderIndicator extends StatelessWidget {
  /// 총 아이템(페이지) 개수
  final int count;

  /// 현재 활성화된 페이지의 인덱스
  final int currentIndex;

  /// 활성화되었을 때의 인디케이터 색상
  final Color activeColor;

  /// 비활성화되었을 때의 인디케이터 색상
  final Color inactiveColor;

  const SliderIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor = AppColors.primaryAble,
    this.inactiveColor = AppColors.disable,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isSelected = currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: isSelected ? 28.0 : 8.0,
          height: 8.0,
          decoration: ShapeDecoration(
            color: isSelected ? activeColor : inactiveColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }),
    );
  }
}
