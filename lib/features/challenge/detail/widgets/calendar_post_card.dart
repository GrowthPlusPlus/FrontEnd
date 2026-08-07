import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/detail/models/calendar_post.dart';
import 'package:haenaem/features/feed/screens/post_detail_screen.dart';
import 'package:intl/intl.dart';

// 최초 작성자 : 강선욱
// 캘린지 인증글 카드 위젯
// - 인증글 사진, 날짜, 내용을 표시
// - 탭 시 포스트 상세 화면으로 이동
class CalendarPostCard extends StatelessWidget {
  final CalendarPost post;

  const CalendarPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final String formattedDate = DateFormat(
      'M월 d일',
    ).format(DateTime.parse(post.postDate));

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PostDetailScreen(postId: post.postId),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: appColors.whiteToBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: appColors.gray4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/icons/green_calendar.svg',
                        width: 12,
                        height: 12,
                        colorFilter: ColorFilter.mode(
                          appColors.primaryAble,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: AppTypography.c1.copyWith(
                          color: appColors.primaryAble,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.content,
                    style: AppTypography.b2.copyWith(
                      color: appColors.blackToWhite,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
