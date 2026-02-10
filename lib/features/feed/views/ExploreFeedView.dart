// 최초 작성자 : 강선욱 (수정: 통합 모델 CertificationPostModel 및 Riverpod 적용)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/feed/provider/feed_provider.dart';
import 'package:haenaem/features/feed/widgets/FeedPostCard.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart'; // CertificationPostModel 경로

class ExploreFeedView extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const ExploreFeedView({super.key, required this.scrollController});

  @override
  ConsumerState<ExploreFeedView> createState() => _ExploreFeedViewState();
}

class _ExploreFeedViewState extends ConsumerState<ExploreFeedView> {
  @override
  void initState() {
    super.initState();
    // 초기 로드
    Future.microtask(() {
      print("데이터 호출 시작!");
      ref.read(exploreFeedProvider.notifier).fetchFeeds();
    });

    // 스크롤 리스너 추가
    widget.scrollController.addListener(() {
      // 스크롤이 끝에서 200px 정도 남았을 때 다음 페이지 로드
      if (widget.scrollController.position.pixels >=
          widget.scrollController.position.maxScrollExtent - 200) {
        ref.read(exploreFeedProvider.notifier).loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(exploreFeedProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(exploreFeedProvider.notifier).fetchFeeds(),
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: feedState.posts.length + (feedState.isLastPage ? 0 : 1),
        itemBuilder: (context, index) {
          // 마지막 아이템 뒤에 로딩 인디케이터 표시
          if (index == feedState.posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return FeedPostCard(post: feedState.posts[index]);
        },
      ),
    );
  }
}
