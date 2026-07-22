// 최초 작성자 : 정승빈 (분리 및 리팩토링)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/feed/widgets/comment_popup_menu.dart';
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
      child: Column(
        mainAxisSize: MainAxisSize.min, // 💡 무한 루프 방지: 최소 크기만 확보
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1층: 프로필 이미지 + 닉네임 (세로 중앙 정렬) + 우측 팝업 메뉴
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // 💡 이름이 이미지 중간 위치에 오도록 설정
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 18,
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

              // 유저 닉네임
              Expanded(
                child: Text(
                  comment.writer.nickname,
                  style: AppTypography.b1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 우측 팝업 메뉴 (크기를 제한하여 레이아웃 루프 차단)
              SizedBox(
                width: 40,
                height: 40,
                child: CommentPopupMenu(
                  postId: postId,
                  comment: comment,
                  feedProvider: feedProvider,
                ),
              ),
            ],
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
                    if (comment.isEdited)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          '수정됨',
                          style: AppTypography.b2.copyWith(
                            color: AppColors.gray3,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
