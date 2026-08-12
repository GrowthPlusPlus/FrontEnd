// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 하단 내비게이션바 (홈, 통계, 피드, 친구, 내 페이지)
class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      decoration: BoxDecoration(
        // 상단에만 외곽선 추가
        border: Border(
          top: BorderSide(
            color: appColors.gray5, // 원하는 테두리 색상으로 변경 가능
            width: 1.0, // 테두리 두께 설정
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: appColors.whiteToBlack,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: appColors.blackToWhite,
        unselectedItemColor: appColors.gray3,
        selectedLabelStyle: AppTypography.c1,
        unselectedLabelStyle: AppTypography.c1,
        onTap: onTap,
        items: [
          _buildNavItem('home_icon_off.svg', '홈', appColors),
          _buildNavItem('graph_icon.svg', '통계', appColors),
          _buildNavItem('feed_icon.svg', '피드', appColors),
          _buildNavItem('friend_icon_off.svg', '친구', appColors),
          _buildNavItem('user_icon.svg', '내 페이지', appColors),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    String iconName,
    String label,
    AppColorsExtension appColors,
  ) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        'assets/images/icons/$iconName',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(appColors.gray3, BlendMode.srcIn),
      ),
      activeIcon: SvgPicture.asset(
        'assets/images/icons/$iconName',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(appColors.blackToWhite, BlendMode.srcIn),
      ),
      label: label,
    );
  }
}
