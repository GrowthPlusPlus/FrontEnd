// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 사진 첨부 필수를 누를 경우 안내 박스
class AiNoticeBox extends StatelessWidget {
  const AiNoticeBox({super.key, this.autoVerifiable});

  // null: 아직 검사 전(또는 검사 실패), true/false: 검사 결과
  final bool? autoVerifiable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray4, width: 0.75),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 아이콘이 문구 상단에 맞게 정렬
        children: [
          SvgPicture.asset(
            'assets/images/icons/ai_notice.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.gray1,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '정확한 인증을 위해 AI 검증 단계를 거치게 됩니다.\n환경에 따라 인식이 지연되거나 재촬영이 필요할 수 있습니다.',
                  style: AppTypography.c1.copyWith(color: AppColors.gray1),
                ),
                if (autoVerifiable == false) ...[
                  const SizedBox(height: 4),
                  Text(
                    '현재 입력한 챌린지 이름은 AI가 자동으로 판별하기 어려운 주제예요. 인증 시 지연되거나 재촬영이 필요할 가능성이 높아요.',
                    style: AppTypography.c1.copyWith(
                      color: AppColors.primaryAble,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
