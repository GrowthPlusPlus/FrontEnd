// 최초 작성자: 강선욱
// 피드 화면의 탭 화면을 담당하는 클래스
// 스크롤 구조와 리스트 렌더링 담당
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../provider/feed_provider.dart';
import 'package:haenaem/features/feed/widgets/feed_post_card.dart';
// import 'package:haenaem/features/feed/models/feed_model.dart';

class ShareFeedView extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final FeedNotifierProvider provider;
  final String emptyMessage;

  const ShareFeedView({
    super.key,
    required this.scrollController,
    required this.provider,
    required this.emptyMessage,
  });

  @override
  ConsumerState<ShareFeedView> createState() => _ShareFeedViewState();
}

class _ShareFeedViewState extends ConsumerState<ShareFeedView>
    with AutomaticKeepAliveClientMixin {
  // [추가] 이 값이 true여야 탭을 이동해도 메모리에서 위젯을 삭제하지 않습니다.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final currentState = ref.read(widget.provider);

      if (currentState.posts.isEmpty) {
        ref.read(widget.provider.notifier).fetchFeeds();
      }
    });

    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final state = ref.read(widget.provider);

    if (state.isLoading || state.isLastPage) return;

    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent - 200) {
      ref.read(widget.provider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    super.build(context);

    final feedState = ref.watch(widget.provider);

    // 초기 로딩 상태
    if (feedState.isLoading && feedState.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 데이터가 없는 상태
    if (feedState.posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(widget.provider.notifier).fetchFeeds(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Text(
                widget.emptyMessage,
                style: AppTypography.b1.copyWith(color: appColors.gray4),
              ),
            ),
          ],
        ),
      );
    }

    // 리스트 렌더링
    return RefreshIndicator(
      onRefresh: () => ref.read(widget.provider.notifier).fetchFeeds(),
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: feedState.posts.length + (feedState.isLastPage ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == feedState.posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: FeedPostCard(
              key: ValueKey(
                '${feedState.posts[index].id}_${feedState.posts[index].isLiked}_${feedState.posts[index].likeCount}_${feedState.posts[index].commentCount}',
              ),
              post: feedState.posts[index],
              provider: widget.provider,
            ),
          );
        },
      ),
    );
  }
}
