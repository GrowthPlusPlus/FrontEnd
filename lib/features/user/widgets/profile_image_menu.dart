// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

// 프로필 사진 변경 or 삭제 메뉴
class ProfileImageMenu extends StatelessWidget {
  final VoidCallback onChangePressed;
  final VoidCallback onDeletePressed;

  const ProfileImageMenu({
    super.key,
    required this.onChangePressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: appColors.whiteToBlack,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: appColors.gray4),
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 프로필 사진 변경 버튼
          _buildMenuOption(
            appColors,
            iconPath: 'assets/images/icons/edit_icon.svg', // 예시 아이콘 경로
            label: '프로필 사진 변경',
            onTap: onChangePressed,
            showBorder: true,
          ),
          // 2. 프로필 사진 삭제 버튼
          _buildMenuOption(
            appColors,
            iconPath: 'assets/images/icons/small_trash_icon.svg', // 예시 아이콘 경로
            label: '프로필 사진 삭제',
            onTap: onDeletePressed,
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(
    AppColorsExtension appColors, {
    required String iconPath,
    required String label,
    required VoidCallback onTap,
    required bool showBorder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 206,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(bottom: BorderSide(width: 1, color: appColors.gray4))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 영역 (16x16)
            SizedBox(
              width: 16,
              height: 16,
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(
                  appColors.blackToWhite,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 텍스트 영역
            Text(
              label,
              style: AppTypography.b2.copyWith(color: appColors.blackToWhite),
            ),
          ],
        ),
      ),
    );
  }
}
