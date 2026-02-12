// 최초 작성자 : 강선욱
// 피드 인증글의 스타일을 정의한 클래스
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/features/challenge/feed/post_detail_screen.dart'; // 인증글 상세 불러오기
import 'package:intl/intl.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/widgets/ChallengeFeedPopupMenu.dart';

class FeedPostCard extends ConsumerWidget {
  final CertificationPostModel post;
  final VoidCallback? onTap;
  final dynamic provider; // 어떤 Provider(친구/둘러보기)인지 받음

  const FeedPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String formattedDate = post.createdAt != null
        ? DateFormat('yyyy년 MM월 dd일 HH:mm').format(post.createdAt!)
        : "";

    return InkWell(
      onTap:
          onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PostDetailScreen(post: post, feedProvider: provider),
              ),
            );
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 5, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      (post.userImageUrl != null &&
                          post.userImageUrl!.isNotEmpty)
                      ? NetworkImage(post.userImageUrl!) as ImageProvider
                      : null,
                  child:
                      (post.userImageUrl == null || post.userImageUrl!.isEmpty)
                      ? SvgPicture.asset(
                          'assets/images/icons/default_profile_icon.svg',
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName ?? '해냄', style: AppTypography.b1),
                      Text(
                        "명예 해냄 개발자",
                        style: AppTypography.c1.copyWith(
                          color: AppColors.gray2,
                        ),
                      ),
                    ],
                  ),
                ),
                ChallengeFeedPopupMenu(post: post),
              ],
            ),
          ),
          // 2. 텍스트 본문
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.challengeTitle} ${post.totalSuccessDays}일차',
                  style: AppTypography.b3.copyWith(color: AppColors.black),
                ),
                Text(
                  post.content,
                  style: AppTypography.b1.copyWith(color: AppColors.gray1),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          // 3. 이미지
          if (post.hasImage && post.imageUrl != null)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              height: 375,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: AppColors.gray5,
                child: const Icon(Icons.error),
              ),
            ),
          // 4. 하단 아이콘 정보
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    print("좋아요 버튼 클릭됨! ID: ${post.postId}");
                    if (provider != null) {
                      ref.read(provider.notifier).toggleLike(post.postId);
                    }
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        post.liked
                            ? 'assets/images/icons/like_filled_icon.svg'
                            : 'assets/images/icons/like_icon.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          post.liked ? AppColors.notification : AppColors.gray2,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.likeCount.toString(),
                        style: AppTypography.b2.copyWith(
                          color: post.liked
                              ? AppColors.notification
                              : AppColors.gray2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildIconInfo(
                  'assets/images/icons/comment_icon.svg',
                  post.commentNumber.toString(),
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

  Widget _buildIconInfo(
    String iconPath,
    String count, {
    Color color = AppColors.gray2,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Text(count, style: AppTypography.b2.copyWith(color: color)),
      ],
    );
  }
}
