// 최초 작성자: 정승빈

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

import '../../../shared/models/user.dart';
import 'package:haenaem/shared/widgets/user_profile_circle.dart';

class FriendEditTile extends StatelessWidget {
  final User user;
  final VoidCallback onDeleteTap;

  const FriendEditTile({
    super.key,
    required this.user,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          UserProfileCircle(imageUrl: user.profileUrl, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  style: AppTypography.h3.copyWith(fontSize: 15),
                ),
                Text(
                  "해냄 메이트", // 추후 칭호 연동
                  style: AppTypography.c1.copyWith(color: AppColors.gray2),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDeleteTap,
            icon: SvgPicture.asset(
              'assets/images/icons/big_trash_icon.svg',
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.notification,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
