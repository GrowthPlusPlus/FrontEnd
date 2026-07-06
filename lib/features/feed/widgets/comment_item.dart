// 최초 작성자 : 정승빈 (분리 및 리팩토링)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/widgets/comment_popup_menu.dart';
import 'package:haenaem/features/feed/models/comment.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final int postId;
  final dynamic feedProvider;

  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
    this.feedProvider,
  });

  @override
  Widget build(BuildContext context) {
    String commentDate = DateFormat('yyyy.MM.dd HH:mm').format(comment.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 18,
            // 타입 안정성을 위해 as ImageProvider 추가
            backgroundImage:
                (comment.writer.profileUrl != null &&
                    comment.writer.profileUrl!.isNotEmpty)
                ? NetworkImage(comment.writer.profileUrl!) as ImageProvider
                : null,
            child:
                (comment.writer.profileUrl == null ||
                    comment.writer.profileUrl!.isEmpty)
                ? SvgPicture.asset(
                    'assets/images/icons/default_profile_icon.svg',
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // 댓글 내용 및 팝업 메뉴
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(comment.writer.nickname, style: AppTypography.b1),
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: CommentPopupMenu(
                        postId: postId,
                        comment: comment,
                        feedProvider: feedProvider,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.content, style: AppTypography.b2),
                const SizedBox(height: 4),
                Text(
                  commentDate,
                  style: AppTypography.c1.copyWith(color: AppColors.gray2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
