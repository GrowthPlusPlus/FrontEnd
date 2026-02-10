// 최초 작성자 : 김채영

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

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
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: AppColors.black,
      unselectedItemColor: AppColors.gray3,
      selectedLabelStyle: AppTypography.c2,
      unselectedLabelStyle: AppTypography.c2,
      onTap: onTap,
      items: [
        _buildNavItem('home_icon_off.svg', '홈'),
        _buildNavItem('graph_icon.svg', '통계'),
        _buildNavItem('feed_icon.svg', '피드'),
        _buildNavItem('friend_icon_off.svg', '친구'),
        _buildNavItem('user_icon.svg', '내 페이지'),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconName, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        'assets/images/icons/$iconName',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(AppColors.gray3, BlendMode.srcIn),
      ),
      activeIcon: SvgPicture.asset(
        'assets/images/icons/$iconName',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
      ),
      label: label,
    );
  }
}
