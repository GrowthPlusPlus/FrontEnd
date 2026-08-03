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
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // 피그마 디자인에 맞춰 날짜 포맷 변경
    String commentDate = DateFormat('yyyy년 MM월 dd일 HH:mm').format(comment.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        // 💡 중요: 아바타와 텍스트가 모두 위쪽을 기준으로 정렬되도록 수정
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 좌측: 프로필 이미지
          CircleAvatar(
            radius: 20, // 40x40 크기
            backgroundImage:
                (comment.writer.profileUrl != null &&
                    comment.writer.profileUrl!.isNotEmpty)
                ? NetworkImage(comment.writer.profileUrl!) as ImageProvider
                : null,
            backgroundColor: appColors.gray5,
            child:
                (comment.writer.profileUrl == null ||
                    comment.writer.profileUrl!.isEmpty)
                ? SvgPicture.asset(
                    'assets/images/icons/default_profile_icon.svg',
                    width: 40,
                    height: 40,
                  )
                : null,
          ),

          const SizedBox(width: 10), // 피그마 spacing: 10 적용
          // 2. 우측: 닉네임, 내용, 날짜 (Expanded는 여기서 가로 공간만 차지하므로 안전함)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 💡 세로 무한 루프 에러 완전 차단
              children: [
                // 2-1. 상단 헤더: 닉네임 + 서브텍스트 + 팝업 메뉴
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            comment.writer.nickname,
                            style: AppTypography.b3.copyWith(
                              color: appColors.blackToWhite,
                            ),
                          ),
                          const SizedBox(height: 2), // 피그마 spacing: 6 적용
                          // 2-2. 본문 내용 (누락되었던 content 복구)
                          Text(
                            comment.content,
                            style: AppTypography.b2.copyWith(
                              color: appColors.blackToWhite,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 우측 팝업 메뉴
                    SizedBox(
                      child: CommentPopupMenu(
                        postId: postId,
                        comment: comment,
                        feedProvider: feedProvider,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8), // 내용과 날짜 사이 간격
                // 2-3. 하단 날짜
                Row(
                  children: [
                    Text(
                      commentDate,
                      style: AppTypography.c1.copyWith(
                        color: appColors.gray2,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(width: 20), // 날짜와 '수정됨' 사이 간격
                    if (comment.isEdited)
                      Text(
                        '수정됨',
                        style: AppTypography.c1.copyWith(
                          color: appColors.gray3,
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
