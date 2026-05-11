// 최초 작성자 : 정승빈 (분리 및 리팩토링)
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/feed/provider/comment_provider.dart';

class CommentInputField extends ConsumerStatefulWidget {
  final int postId;
  final dynamic feedProvider;

  const CommentInputField({super.key, required this.postId, this.feedProvider});

  @override
  ConsumerState<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends ConsumerState<CommentInputField> {
  final TextEditingController _commentController = TextEditingController();
  bool _isButtonActive = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _isButtonActive = _commentController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 키보드가 올라왔을 때 하단 여백 자동 조절
    final double systemBottomPadding =
        MediaQuery.of(context).viewInsets.bottom > 0
        ? 10
        : MediaQuery.of(context).padding.bottom + 10;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: systemBottomPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '댓글을 입력하세요...',
                hintStyle: AppTypography.b2.copyWith(color: AppColors.gray3),
                filled: true,
                fillColor: AppColors.gray5,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isButtonActive
                ? () async {
                    final contents = _commentController.text.trim();
                    // 💡 API 호출
                    final success = await ref
                        .read(commentCreateNotifierProvider.notifier)
                        .addComment(postId: widget.postId, contents: contents);

                    if (success && mounted) {
                      // 리스트 업데이트
                      if (widget.feedProvider != null) {
                        // 피드 화면에서 댓글 수 업데이트를 위해 필요한 코드
                        ref
                            .read(widget.feedProvider.notifier)
                            .incrementCommentCountLocally(widget.postId);
                      }
                      // 입력창 초기화
                      _commentController.clear();
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('댓글이 작성되었습니다.')),
                      );
                    }
                  }
                : null,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: _isButtonActive
                  ? AppColors.primaryAble
                  : AppColors.disable,
              child: SvgPicture.asset(
                'assets/images/icons/comment_upload_icon.svg',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
