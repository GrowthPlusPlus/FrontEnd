// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../../../../shared/widgets/challenge_label.dart';
import 'challenge_select_button.dart';

// 챌린지 공개 범위(비공개, 공개, 친구 공개) 선택 섹션
class ChallengeVisibilitySelector extends StatelessWidget {
  final int selectedVisibility;
  final ValueChanged<int> onChanged;

  const ChallengeVisibilitySelector({
    super.key,
    required this.selectedVisibility,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChallengeLabel(label: '챌린지 공개 범위'),
        Row(
          children: [
            ChallengeSelectButton(
              label: "비공개",
              isSelected: selectedVisibility == 1,
              onTap: () => onChanged(1),
            ),
            const SizedBox(width: 10),
            ChallengeSelectButton(
              label: "공개",
              isSelected: selectedVisibility == 2,
              onTap: () => onChanged(2),
            ),
            const SizedBox(width: 10),
            ChallengeSelectButton(
              label: "친구 공개",
              isSelected: selectedVisibility == 3,
              onTap: () => onChanged(3),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '비공개, 친구 공개 시 챌린지 검색에서 제외됩니다.',
          style: AppTypography.c1.copyWith(color: appColors.gray2),
        ),
      ],
    );
  }
}
