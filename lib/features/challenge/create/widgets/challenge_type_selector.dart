// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import '../../../../shared/widgets/challenge_label.dart';
import 'challenge_select_button.dart';
import 'ai_notice_box.dart';

// 챌린지 인증 방식(사진 필수/체크 자유) 선택 섹션 및 안내 박스 표시
class ChallengeTypeSelector extends StatelessWidget {
  final int selectedType;
  final ValueChanged<int> onChanged;
  final bool? autoVerifiable;
  final bool isCheckingPreview;

  const ChallengeTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.autoVerifiable,
    this.isCheckingPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChallengeLabel(label: '챌린지 인증 방식'),
        Row(
          children: [
            ChallengeSelectButton(
              label: "사진 첨부 필수",
              isSelected: selectedType == 1,
              onTap: () => onChanged(1),
            ),
            const SizedBox(width: 10),
            ChallengeSelectButton(
              label: "체크(사진 첨부 자유)",
              isSelected: selectedType == 2,
              onTap: () => onChanged(2),
            ),
          ],
        ),

        // 선택된 타입이 1(사진 필수)일 때만 AI 안내 박스 표시
        if (selectedType == 1) ...[
          const SizedBox(height: 12),
          AiNoticeBox(
            autoVerifiable: autoVerifiable,
            isCheckingPreview: isCheckingPreview,
          ),
        ],
      ],
    );
  }
}
