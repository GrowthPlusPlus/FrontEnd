// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/models/challenge_model.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/widgets/DeleteConfirmDialog.dart';
import 'edit_article_dialog.dart';

// 내 댓글이면 삭제/수정 + 다른 사람 댓글이면 신고 다이얼로그
class CommentPopupMenu extends ConsumerWidget {
  final int postId;
  final ChallengeComment comment;
  final dynamic feedProvider;

  const CommentPopupMenu({
    super.key,
    required this.postId,
    required this.comment,
    this.feedProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: SvgPicture.asset(
        'assets/images/icons/dots_vert_icon.svg',
        width: 24,
        height: 24,
      ),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.gray4, width: 1),
      ),
      color: Colors.white,
      itemBuilder: (context) {
        // 내 댓글인 경우 : 수정/삭제
        if (comment.mine) {
          return [
            _buildPopupItem(
              '수정하기',
              'assets/images/icons/edit_icon.svg',
              'edit',
            ),
            const PopupMenuDivider(height: 1),
            _buildPopupItem(
              '삭제하기',
              'assets/images/icons/small_trash_icon.svg',
              'delete',
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
              'complain',
              isDanger: true,
            ),
          ];
        }
      },
      onSelected: (value) => _handleMenuSelection(context, ref, value),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String title,
    String iconPath,
    String value, {
    bool isDanger = false,
  }) {
    final Color itemColor = isDanger ? AppColors.notification : AppColors.black;
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
  ) async {
    switch (value) {
      case 'edit':
        // 수정 다이얼로그 띄우기 (기존 내용 전달)
        final String? newContents = await showDialog<String>(
          context: context,
          builder: (context) =>
              EditArticleDialog(initialContent: comment.contents),
        );

        // 수정을 완료하고 텍스트를 입력했을 경우 API 호출
        if (newContents != null && newContents.trim().isNotEmpty) {
          //FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기!
          final success = await ref
              .read(articleCommentUpdateNotifierProvider.notifier)
              .editComment(
                postId: postId,
                commentId: comment.commentId,
                contents: newContents,
              );

          if (success && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("댓글이 수정되었습니다.")));
          }
          break;
        }
      case 'delete':
        final bool? confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const DeleteConfirmDialog(
            title: '댓글 삭제', // 댓글에 맞는 제목
            message: '작성하신 댓글을 삭제하시겠습니까?\n삭제된 댓글은 되돌릴 수 없습니다.',
          ),
        );
        FocusManager.instance.primaryFocus?.unfocus(); // 뜬금없이 나오는 키보드 문제 디버깅

        if (confirmed == true) {
          // 댓글 삭제 API 호출
          final success = await ref
              .read(articleCommentDeleteNotifierProvider.notifier)
              .removeComment(postId: postId, commentId: comment.commentId);

          if (success && context.mounted) {
            // 피드 화면 댓글 수 감소를 위해 필요한 코드
            if (feedProvider != null) {
              ref
                  .read(feedProvider.notifier)
                  .decrementCommentCountLocally(postId);
            }

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("댓글이 삭제되었습니다.")));
            // ref.invalidate는 이미 Notifier 내부에서 처리되므로
            // UI가 자동으로 업데이트된다.
          }
        }
        break;
      case 'complain':
        _showComplainDialog(context);
        break;
    }
  }

  // TODO: 나중에 따로 뺄까여
  // 신고 확인 다이얼로그
  void _showComplainDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신고하기'),
        content: const Text('이 댓글을 신고하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.gray2)),
          ),
          TextButton(
            onPressed: () {
              // TODO: 신고 API 연결 (현재는 스낵바만 표시)
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
            },
            child: const Text(
              '신고',
              style: TextStyle(color: AppColors.notification),
            ),
          ),
        ],
      ),
    );
  }
}
