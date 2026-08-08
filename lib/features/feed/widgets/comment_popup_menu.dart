// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
//import 'package:haenaem/features/challenge/models/challenge_model.dart';
//import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/feed/models/comment.dart';
import 'package:haenaem/features/feed/provider/comment_provider.dart';
import 'package:haenaem/features/feed/widgets/feed_post_card.dart';
import 'package:haenaem/shared/widgets/select_dialog.dart';
import '../provider/feed_provider.dart';
import 'edit_article_dialog.dart';
import 'package:haenaem/features/report/screens/report_screen.dart';
import 'package:haenaem/features/report/provider/report_provider.dart';
import 'package:haenaem/shared/widgets/animated_toast.dart';

// 내 댓글이면 삭제/수정 + 다른 사람 댓글이면 신고 다이얼로그
class CommentPopupMenu extends ConsumerWidget {
  final int postId;
  final Comment comment;
  final dynamic feedProvider;

  const CommentPopupMenu({
    super.key,
    required this.postId,
    required this.comment,
    this.feedProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return PopupMenuButton<String>(
      child: SvgPicture.asset(
        'assets/images/icons/dots_vert_icon.svg',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(appColors.gray3, BlendMode.srcIn),
      ),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: appColors.gray4, width: 1),
      ),
      color: appColors.whiteToBlack,
      itemBuilder: (context) {
        // 내 댓글인 경우 : 수정/삭제
        if (comment.isMine) {
          return [
            _buildPopupItem(
              '수정하기',
              'assets/images/icons/edit_icon.svg',
              'edit',
              appColors,
            ),
            const PopupMenuDivider(height: 1),
            _buildPopupItem(
              '삭제하기',
              'assets/images/icons/small_trash_icon.svg',
              'delete',
              appColors,
              isDanger: true,
            ),
          ];
        }
        // 다른 사람의 댓글인 경우: 신고
        else {
          return [
            _buildPopupItem(
              '신고하기',
              'assets/images/icons/complaint.svg',
              'report',
              appColors,
              isDanger: true,
            ),
          ];
        }
      },
      onSelected: (value) =>
          _handleMenuSelection(context, ref, value, appColors),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String title,
    String iconPath,
    String value,
    AppColorsExtension appColors, {
    bool isDanger = false,
  }) {
    final Color itemColor = isDanger
        ? appColors.notification
        : appColors.blackToWhite;
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20,
            colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Text(title, style: AppTypography.b2.copyWith(color: itemColor)),
          const SizedBox(width: 25),
        ],
      ),
    );
  }

  void _handleMenuSelection(
    BuildContext context,
    WidgetRef ref,
    String value,
    AppColorsExtension appColors,
  ) async {
    switch (value) {
      case 'edit':
        // 수정 다이얼로그 띄우기 (기존 내용 전달)
        final String? newContents = await showDialog<String>(
          context: context,
          builder: (context) =>
              EditArticleDialog(initialContent: comment.content),
        );

        // 수정을 완료하고 텍스트를 입력했을 경우 API 호출
        if (newContents != null && newContents.trim().isNotEmpty) {
          //FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기!
          final success = await ref
              .read(commentUpdateNotifierProvider.notifier)
              .editComment(
                postId: postId,
                commentId: comment.id,
                contents: newContents,
              );

          if (success && context.mounted) {
            displayToast(context, "댓글이 수정되었습니다.");
          }
          break;
        }
      case 'delete':
        final bool? confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => SelectDialog(
            title: '댓글을 삭제하시겠습니까?',
            content: '작성하신 댓글을 삭제하시겠습니까?\n삭제된 댓글은 되돌릴 수 없습니다.',
            confirmText: '삭제',
            confirmTextColor: appColors.notification,
            cancelText: '취소',
            onCancel: () {
              Navigator.of(context).pop(true);
            },
            onConfirm: () async {
              try {
                // 💡 삭제 시도
                final success = await ref
                    .read(commentDeleteNotifierProvider.notifier)
                    .removeComment(postId: postId, commentId: comment.id);

                if (success && context.mounted) {
                  displayToast(context, "댓글이 삭제되었습니다.");
                }
              } catch (e) {
                // 💡 서버의 에러 메시지(PAST_POST_CANNOT_DELETE) 예외 처리 유지
                String errorMessage = "삭제에 실패했습니다.";

                if (context.mounted) {
                  displayToast(context, errorMessage);
                }
              }
            },
          ),
        );

        // 뜬금없이 나오는 키보드 문제 디버깅용 유지
        FocusManager.instance.primaryFocus?.unfocus();

        if (confirmed == true) {
          // 댓글 삭제 API 호출
          final success = await ref
              .read(commentDeleteNotifierProvider.notifier)
              .removeComment(postId: postId, commentId: comment.id);

          if (success && context.mounted) {
            if (feedProvider != null) {
              ref
                  .read(feedProvider.notifier)
                  .decrementCommentCountLocally(postId);
            }

            displayToast(context, "댓글이 삭제되었습니다.");
          }
        }
        break;
      case 'report':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(
              targetType: ReportTargetType.comment, // 댓글 타입
              targetId: comment.id, // 댓글 ID
            ),
          ),
        );
        break;
    }
  }

  //   // TODO: 나중에 따로 뺄까여
  //   // 신고 확인 다이얼로그
  //   void _showComplainDialog(BuildContext context) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('신고하기'),
  //         content: const Text('이 댓글을 신고하시겠습니까?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('취소', style: TextStyle(color: AppColors.gray2)),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // TODO: 신고 API 연결 (현재는 스낵바만 표시)
  //               Navigator.pop(context);
  //               ScaffoldMessenger.of(
  //                 context,
  //               ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
  //             },
  //             child: const Text(
  //               '신고',
  //               style: TextStyle(color: AppColors.notification),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
}
