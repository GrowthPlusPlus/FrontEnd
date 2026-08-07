// 최초 작성자: 정승빈
// 유저 목록 타일 템플릿

import 'package:flutter/material.dart';

import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/models/user.dart';
import 'package:haenaem/shared/widgets/user_profile_circle.dart';

class UserListTile extends StatelessWidget {
  final User user;
  final Widget? trailing; // 오른쪽 끝에 달릴 위젯 (버튼, 아이콘 등)
  final EdgeInsetsGeometry padding; // 위아래 여백 조정을 위해 추가

  const UserListTile({
    super.key,
    required this.user,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(vertical: 8), // 기본값 8
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          UserProfileCircle(imageUrl: user.profileUrl, size: 44),
          const SizedBox(width: 12),
          Expanded(
            // 오른쪽 위젯이 공간을 침범하지 않게 방어
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  style: AppTypography.b1.copyWith(
                    color: appColors.blackToWhite,
                  ),
                ),
                /*
                Text(
                  "해냄 메이트",
                  // TODO 추후 칭호 기능 연동 시 User 모델에서 받아오도록 수정
                  style: AppTypography.c1.copyWith(color: appColors.gray2),
                ),
                */
              ],
            ),
          ),
          // trailing으로 전달받은 위젯이 있으면 화면에 그려줌
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
