// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 재사용 목적 - 입력 박스 (입력/선택 전환 가능)
class ChallengeInputBox extends StatelessWidget {
  final String hintText;
  final double height;
  final String? iconPath; // SVG 아이콘 경로
  final String? leadingIconPath; // 캘린더 svg
  final VoidCallback? onTap; // 클릭 시 동작
  final TextEditingController? controller; // 입력용 컨트롤러
  final Widget? tag; // 태그 넣기

  // 입력박스 안 색상 변경
  final Color? textColor;

  const ChallengeInputBox({
    super.key,
    required this.hintText,
    this.height = 48,
    this.iconPath,
    this.leadingIconPath,
    this.onTap,
    this.controller,
    this.textColor,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: appColors.whiteToBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: appColors.gray4, width: 1),
        ),
        // 박스 내부 내용물 배치
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center, // 아이콘 중앙 정렬
          children: [
            // 왼쪽 영역 (앞 아이콘 + 텍스트/입력필드)을 묶어서 Expanded로 확장
            Expanded(
              child: Row(
                children: [
                  // leadingIconPath가 있으면 표시
                  if (leadingIconPath != null) ...[
                    SvgPicture.asset(
                      leadingIconPath!,
                      width: 15,
                      height: 15,
                      colorFilter: ColorFilter.mode(
                        appColors.gray3,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    // onTap이 있으면 일반 Text(선택 모드), 없으면 TextField(입력 모드)
                    child:
                        tag ??
                        TextField(
                          controller: controller,
                          readOnly: onTap != null,

                          enabled: true,
                          onTap: onTap,
                          style: AppTypography.b2.copyWith(
                            color: appColors.blackToWhite,
                          ),

                          // 챌린지 설명 hintText 위로 올리기
                          textAlignVertical: height > 48
                              ? TextAlignVertical.top
                              : TextAlignVertical.center,
                          expands: height > 48,
                          maxLines: height > 48 ? null : 1,
                          minLines: height > 48 ? null : 1,

                          // ------------------------------------
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: AppTypography.b2.copyWith(
                              color: textColor ?? appColors.gray3,
                            ),
                            border: InputBorder.none,
                            isDense: true,

                            // 챌린지 설명 - 텍스트가 상단 테두리에 너무 붙지 않게 조정
                            contentPadding: height > 48
                                ? const EdgeInsets.symmetric(vertical: 12)
                                : EdgeInsets.zero,
                          ),
                        ),
                  ),

                  if (iconPath != null)
                    SvgPicture.asset(iconPath!, width: 20, height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
