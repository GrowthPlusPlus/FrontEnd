// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 하단 버튼 (만들기/완료 등 공용 사용)
class PlusButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool showShadow;

  const PlusButton({
    super.key,
    this.showShadow = true,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final bool isEnabled = onPressed != null;

    // 💡 라벨이 '완료'인 경우 플러스 아이콘을 숨기기 위한 조건
    final bool isCreateButton = label != "완료";

    return Container(
      decoration: BoxDecoration(
        color: appColors.whiteToBlack,
        boxShadow: showShadow
            ? [
                const BoxShadow(
                  color: Color(0x28000000),
                  blurRadius: 175.60,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      // 💡 SafeArea를 사용하여 안드로이드 시스템 바 영역을 보호합니다.
      child: SafeArea(
        top: false, // 하단만 보호하면 되므로 상단은 제외
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              height: 60,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: isEnabled ? appColors.primaryAble : appColors.disable,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 💡 '완료'가 아닐 때만 플러스 아이콘 표시
                  if (isCreateButton) ...[
                    SvgPicture.asset(
                      'assets/images/icons/plus.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        appColors.whiteToBlack,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: AppTypography.h3.copyWith(
                      color: appColors.whiteToBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
