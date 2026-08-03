// 최초 작성자: 정승빈

import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class ReportReasonTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isOtherOption;
  final VoidCallback onTap;
  final TextEditingController textController;

  const ReportReasonTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isOtherOption,
    required this.onTap,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appColors.gray5,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.b3.copyWith(
                          color: appColors.gray1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.b2.copyWith(
                          color: appColors.gray3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 커스텀 라디오 버튼 아이콘 처리
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? appColors.primaryAble : appColors.gray4,
                  size: 24,
                ),
              ],
            ),

            // '기타 (직접 입력)' 항목이 선택되었을 때만 노출되는 텍스트 입력창
            if (isOtherOption && isSelected) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: appColors.gray4),
                ),
                child: TextField(
                  controller: textController,
                  maxLines: 3,
                  style: AppTypography.b2.copyWith(
                    color: appColors.blackToWhite,
                  ),
                  decoration: InputDecoration(
                    hintText: '예: 챌린지 주제와 상관없는 사진을 반복적으로 올립니다.',
                    hintStyle: AppTypography.b2.copyWith(
                      color: appColors.gray3,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
