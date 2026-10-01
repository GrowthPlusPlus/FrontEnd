// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 사진 첨부 필수를 누를 경우 안내 박스
class AiNoticeBox extends StatelessWidget {
  const AiNoticeBox({
    super.key,
    this.autoVerifiable,
    this.isCheckingPreview = false,
  });

  // null: 아직 검사 전(또는 검사 실패), true/false: 검사 결과
  final bool? autoVerifiable;

  final bool isCheckingPreview; // true면 현재 AI 이름 검사가 진행 중 (스피너 표시)

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: appColors.whiteToBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appColors.gray4, width: 0.75),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 아이콘이 문구 상단에 맞게 정렬
        children: [
          SvgPicture.asset(
            'assets/images/icons/ai_notice.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(appColors.gray1, BlendMode.srcIn),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '정확한 인증을 위해 AI 검증 단계를 거치게 됩니다.\n환경에 따라 인식이 지연되거나 재촬영이 필요할 수 있습니다.',
                  style: AppTypography.c1.copyWith(color: appColors.gray1),
                ),
                // 검사 중일 때: 스피너 + 안내 문구
                if (isCheckingPreview) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: appColors.primaryAble,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '챌린지 이름을 확인하고 있어요...',
                        style: AppTypography.c1.copyWith(
                          color: appColors.gray1,
                        ),
                      ),
                    ],
                  ),
                ] else if (autoVerifiable == false) ...[
                  // 검사 중이 아닐 때만 결과 문구 표시 (실패 → 재입력 유도)
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SvgPicture.asset(
                          'assets/images/icons/warning.svg',
                          width: 14,
                          height: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '현재 챌린지 이름으로는 AI 사진 인증이 어려워요.\n챌린지 이름을 다시 입력해주세요.',
                          style: AppTypography.c1.copyWith(
                            color: appColors.notification,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (autoVerifiable == true) ...[
                  // 검사 성공 시 안내 문구
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SvgPicture.asset(
                          'assets/images/icons/success_check.svg',
                          width: 14,
                          height: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '현재 입력한 챌린지 이름은 AI가 자동으로 판별하기 쉬운 주제예요. 인증이 원활하게 진행될 거예요.',
                          style: AppTypography.c1.copyWith(
                            color: appColors.primaryAble,
                          ),
                        ),
                      ),
                    ],
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
