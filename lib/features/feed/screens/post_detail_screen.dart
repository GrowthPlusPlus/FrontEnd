// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 💡 기존 challenge_provider 대신 분리된 프로바이더들을 임포트합니다.
import 'package:haenaem/features/feed/provider/post_detail_provider.dart';
import 'package:haenaem/features/feed/provider/comment_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/feed/widgets/comment_item.dart';
import 'package:haenaem/features/feed/widgets/feed_post_card.dart'; // FeedPostCard 임포트
import 'package:haenaem/features/feed/widgets/comment_input_field.dart';
import 'package:haenaem/shared/models/post.dart';

class PostDetailScreen extends ConsumerWidget {
  final int postId;
  final Post? post;
  final dynamic feedProvider;

  const PostDetailScreen({
    super.key,
    required this.postId,
    this.post,
    this.feedProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상세 정보 및 댓글 구독
    final detailAsync = ref.watch(postDetailProvider(postId: postId));
    final commentsAsync = ref.watch(postCommentsProvider(postId: postId));

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
                        provider: feedProvider,
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
                                // 💡 분리한 위젯을 여기서 간편하게 호출합니다.
                                CommentItem(
                                  comment: comments[index],
                                  postId: postId,
                                  feedProvider: feedProvider,
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // 💡 분리된 입력창 위젯 호출!
              CommentInputField(postId: postId, feedProvider: feedProvider),
            ],
          );
        },
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
