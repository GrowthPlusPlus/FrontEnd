// 최초 작성자 : 강선욱 (수정: 통합 모델 CertificationPostModel 적용)
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/widgets/ChallengeFeedPopupMenu.dart'; // 주석 해제 대비 임포트

class FeedPostCard extends StatelessWidget {
  final CertificationPostModel post;
  final VoidCallback? onTap;

  const FeedPostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    // createdAt이 null일 경우를 대비한 처리
    String formattedDate = post.createdAt != null
        ? DateFormat('yyyy년 MM월 dd일 HH:mm').format(post.createdAt!)
        : "";

    return InkWell(
      onTap: onTap,
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
                  // Getter가 아닌 필드 직접 접근 시 Null 처리 필요
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
                      Text(
                        post.userName ?? '이름 없음', // Getter 활용 및 Null 처리
                        style: AppTypography.b1.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        post.challengeTitle,
                        style: AppTypography.c1.copyWith(
                          color: AppColors.gray2,
                        ),
                      ),
                    ],
                  ),
                ),
                // 팝업 메뉴 연결 (CertificationPostModel을 사용하므로 이제 에러가 없을 것입니다)
                ChallengeFeedPopupMenu(post: post),
              ],
            ),
          ),

          // 2. 본문 텍스트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  post.content,
                  style: AppTypography.b2.copyWith(color: AppColors.gray1),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),

          // 3. 이미지 (Getter 활용)
          if (post.hasImage && post.imageUrl != null)
            Image.network(
              post.imageUrl!, // Getter를 통해 첫 번째 이미지 URL을 가져옴
              width: double.infinity,
              height: 375,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: AppColors.gray5,
                child: const Icon(Icons.error),
              ),
            ),

          // 4. 하단 정보 (좋아요, 댓글, 날짜)
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 16),
            child: Row(
              children: [
                _buildIconInfo(
                  post.liked
                      ? 'assets/images/icons/like_filled_icon.svg'
                      : 'assets/images/icons/like_icon.svg',
                  post.likeCount.toString(), // Getter 활용
                  color: post.liked ? AppColors.notification : AppColors.gray2,
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
