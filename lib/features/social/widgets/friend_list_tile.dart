// 최초 작성자: 정승빈

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

import '../../../shared/models/user.dart';
import 'package:haenaem/shared/widgets/user_profile_circle.dart';

class FriendListTile extends StatelessWidget {
  final User user;

  const FriendListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          UserProfileCircle(imageUrl: user.profileUrl, size: 44),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.nickname,
                style: AppTypography.h3.copyWith(fontSize: 15),
              ),
              // 칭호를 보여주는 위젯
              Text(
                "해냄 메이트", // 추후 칭호 기능 추가 시 연동
                style: AppTypography.c1.copyWith(color: AppColors.gray2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
