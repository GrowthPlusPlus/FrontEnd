// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/widgets/comment_popup_menu.dart';
import 'package:haenaem/features/feed/widgets/feed_post_card.dart'; // FeedPostCard 임포트

class PostDetailScreen extends ConsumerStatefulWidget {
  final CertificationPostModel post;
  final dynamic feedProvider;
  const PostDetailScreen({super.key, required this.post, this.feedProvider});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
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
    // 상세 정보 및 댓글 데이터 구독
    final detailAsync = ref.watch(
      articleDetailProvider(postId: widget.post.postId),
    );
    final commentsAsync = ref.watch(
      articleCommentsProvider(postId: widget.post.postId),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '피드',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러올 수 없습니다: $err')),
        data: (latestPost) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 리팩토링 포인트: FeedPostCard 재사용 ---
                      FeedPostCard(
                        post: latestPost,
                        provider: widget.feedProvider,
                        onTap: () {}, // 상세 페이지 내에서는 클릭 시 아무 동작 안 함
                      ),

                      const Divider(thickness: 1, height: 1),

                      // --- 댓글 리스트 영역 ---
                      commentsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, stack) => const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text('댓글 로드 실패')),
                        ),
                        data: (comments) {
                          if (comments.isEmpty) return _buildEmptyComments();
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) =>
                                _buildCommentItem(comments[index]),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // 키보드에 가려지지 않도록 처리된 댓글 입력창
              _buildCommentInputField(),
            ],
          );
        },
      ),
    );
  }

  // 댓글 입력창 (기존 로직 유지)
  Widget _buildCommentInputField() {
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
                fillColor: AppColors.gray5, // 연한 회색 배경
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
            onTap: _isButtonActive ? _handleCommentSubmit : null,
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

  Future<void> _handleCommentSubmit() async {
    final contents = _commentController.text.trim();
    final success = await ref
        .read(articleCommentCreateNotifierProvider.notifier)
        .addComment(postId: widget.post.postId, contents: contents);

    if (success && mounted) {
      if (widget.feedProvider != null) {
        ref
            .read(widget.feedProvider.notifier)
            .incrementCommentCountLocally(widget.post.postId);
      }
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Widget _buildCommentItem(ChallengeComment comment) {
    final DateTime? displayDate = comment.updatedAt ?? comment.createdAt;
    String commentDate = "";
    if (displayDate != null) {
      commentDate = DateFormat('yyyy.MM.dd HH:mm').format(displayDate);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage:
                (comment.userPicture != null && comment.userPicture!.isNotEmpty)
                ? NetworkImage(comment.userPicture!)
                : null,
            child: (comment.userPicture == null || comment.userPicture!.isEmpty)
                ? SvgPicture.asset(
                    'assets/images/icons/default_profile_icon.svg',
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(comment.userNickname, style: AppTypography.b1),
                    CommentPopupMenu(
                      postId: widget.post.postId,
                      comment: comment,
                      feedProvider: widget.feedProvider,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.contents, style: AppTypography.b2),
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

  Widget _buildEmptyComments() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text('첫 댓글을 남겨보세요!', style: TextStyle(color: AppColors.gray2)),
      ),
    );
  }
}
