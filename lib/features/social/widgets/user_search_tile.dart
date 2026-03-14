// 최초 작성자: 정승빈

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

import 'package:haenaem/features/social/models/user_search_card.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _buildProfileCircle(searchCard.user.profileUrl, 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  searchCard.user.nickname,
                  style: AppTypography.h3.copyWith(fontSize: 15),
                ),
                Text(
                  "해냄 메이트", // 추후 칭호 기능 추가 시 연동
                  style: AppTypography.c1.copyWith(color: AppColors.gray2),
                ),
              ],
            ),
          ),
          _buildRequestButton(),
        ],
      ),
    );
  }

  Widget _buildRequestButton() {
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
          color: isRequested ? AppColors.disable : AppColors.primaryAble,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isRequested ? '신청됨' : '친구 신청',
          style: AppTypography.c1.copyWith(
            color: isRequested ? AppColors.gray2 : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCircle(String? imageUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0x7FDFE1DC),
        shape: BoxShape.circle,
        image: imageUrl != null && imageUrl.startsWith('http')
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : (imageUrl != null
                  ? DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null),
      ),
      child: imageUrl == null
          ? Center(
              child: SvgPicture.asset(
                'assets/images/icons/default_profile_icon.svg',
                width: size,
              ),
            )
          : null,
    );
  }
}
