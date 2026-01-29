import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/widgets/UserChallengeData.dart';
import 'package:haenaem/features/challenge/widgets/ChallengeFeedPopupMenu.dart';

class FeedPostCard extends StatelessWidget {
  final CertificationPost post;
  final VoidCallback? onTap;

  const FeedPostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy년 MM월 dd일 HH:mm').format(post.date);

    return InkWell(
      onTap: onTap, // 카드 클릭 시 상세 페이지 이동 등을 위해 추가
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더 (프로필 정보)
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 5, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: SvgPicture.asset(
                    'assets/images/icons/default_profile_icon.svg',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName ?? 'Growth',
                        style: AppTypography.b1.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        '초보 모험가',
                        style: AppTypography.c1.copyWith(
                          color: AppColors.gray2,
                        ),
                      ),
                    ],
                  ),
                ),
                const ChallengeFeedPopupMenu(),
              ],
            ),
          ),

          // 2. 본문 텍스트
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Text(
          //     post.content,
          //     style: AppTypography.b2.copyWith(color: AppColors.gray1),
          //     maxLines: 3, // 피드 목록이므로 너무 길면 생략
          //     overflow: TextOverflow.ellipsis,
          //   ),
          // ),
          // const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                // 인증글 본문 데이터 반영
                Text(
                  post.content,
                  style: AppTypography.b2.copyWith(color: AppColors.gray1),
                  maxLines: 3, // 피드 목록이므로 너무 길면 생략
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),

          // 3. 이미지
          if (post.hasImage && post.imageUrl != null)
            Image.asset(
              post.imageUrl!,
              width: double.infinity,
              height: 375,
              fit: BoxFit.cover,
            ),

          // 4. 하단 정보 (좋아요, 댓글, 날짜)
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 16),
            child: Row(
              children: [
                _buildIconInfo(
                  'assets/images/icons/like_icon.svg',
                  post.likeCount.toString(),
                ),
                const SizedBox(width: 16),
                _buildIconInfo(
                  'assets/images/icons/comment_icon.svg',
                  post.comments.length.toString(),
                ),
                const Spacer(),
                Text(
                  formattedDate,
                  style: AppTypography.b2.copyWith(color: AppColors.gray2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconInfo(String iconPath, String count) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(AppColors.gray2, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Text(count, style: AppTypography.b2.copyWith(color: AppColors.gray2)),
      ],
    );
  }
}
