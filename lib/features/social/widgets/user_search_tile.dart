// 최초 작성자: 정승빈

import 'package:flutter/material.dart';

import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

import 'package:haenaem/features/social/models/user_search_card.dart';
import 'package:haenaem/shared/widgets/user_list_tile.dart';

class UserSearchTile extends StatelessWidget {
  final UserSearchCard searchCard;
  final VoidCallback onRequest;

  const UserSearchTile({
    super.key,
    required this.searchCard,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return UserListTile(
      user: searchCard.user,
      padding: const EdgeInsets.symmetric(vertical: 12), // 여기만 12
      trailing: _buildRequestButton(appColors),
    );
  }

  Widget _buildRequestButton(AppColorsExtension appColors) {
    // 1. 이미 친구인 경우 버튼을 숨김
    if (searchCard.state == FriendState.friend) {
      return const SizedBox.shrink();
    }

    // 2. 신청 대기 상태 확인
    final isRequested = searchCard.state == FriendState.pending;

    return GestureDetector(
      onTap: isRequested ? null : onRequest,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isRequested ? appColors.disable : appColors.primaryAble,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isRequested ? '신청됨' : '친구 신청',
          style: AppTypography.c1.copyWith(
            color: isRequested ? appColors.gray2 : appColors.whiteToBlack,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
