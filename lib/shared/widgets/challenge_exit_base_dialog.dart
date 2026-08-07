// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 멤버용/방장용 챌린지 나가기 공통 위젯
class ChallengeExitBaseDialog extends StatelessWidget {
  final String title;
  final String confirmButtonText;
  final VoidCallback? onConfirm;
  final Widget? content; // 중간에 들어갈 위임용 멤버 선택창 등
  final bool isConfirmEnabled; // 확인 버튼 활성화 여부

  const ChallengeExitBaseDialog({
    super.key,
    this.title = '챌린지를 나가시겠어요?',
    this.confirmButtonText = '나가기',
    this.onConfirm,
    this.content,
    this.isConfirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: appColors.whiteToBlack,
      // 다이얼로그 자체가 화면 끝에서 떨어지는 정도
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: 335,
        // [수정] 패딩을 24에서 16으로 변경하여 버튼이 끝에서 16px 떨어지게 함
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 이모지
            const Text('🥺', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            // 2. 제목
            Text(
              title,
              style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
            ),
            const SizedBox(height: 8),

            // 3. 경고 문구
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: SvgPicture.asset(
                    'assets/images/icons/tri_warning_icon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      appColors.notification,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '지금까지의 진행 상황이 모두 사라지며,\n복구할 수 없습니다.',
                    textAlign: TextAlign.center,
                    style: AppTypography.b3.copyWith(
                      color: appColors.notification,
                    ),
                  ),
                ),
              ],
            ),

            // 4. 추가 컨텐츠 (위임용 멤버 선택 등)
            if (content != null) ...[const SizedBox(height: 24), content!],

            const SizedBox(height: 30),

            // 5. 버튼 영역
            Row(
              children: [
                // 확인 버튼 (나가기 / 위임 후 나가기)
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isConfirmEnabled ? onConfirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.notification,
                        disabledBackgroundColor: const Color(0xFFDBAEAD),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        confirmButtonText,
                        style: AppTypography.b1.copyWith(
                          color: appColors.whiteToBlack,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 취소 버튼
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      // result에 false를 넣지 않고 그냥 pop 합니다. (null 반환)
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.gray5,
                        foregroundColor: appColors.gray2,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: AppTypography.b1.copyWith(
                          color: appColors.gray2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
