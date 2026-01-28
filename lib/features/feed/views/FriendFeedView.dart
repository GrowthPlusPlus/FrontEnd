import 'package:flutter/material.dart';
import 'package:haenaem/features/feed/widgets/FeedPostCard.dart'; // 위에서 만든 카드 경로
import 'package:haenaem/features/challenge/widgets/UserChallengeData.dart';
import 'package:haenaem/features/challenge/widgets/MockData.dart'; // 기존에 만든 가짜 데이터 활용

class FriendFeedView extends StatelessWidget {
  const FriendFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 모든 챌린지의 포스트를 하나의 리스트로 수집합니다.
    List<CertificationPost> allPosts = [];
    final challenges = MockData.getAllChallenges();

    for (var challenge in challenges) {
      allPosts.addAll(challenge.posts);
    }

    // 2. 최신 날짜 순으로 정렬합니다.
    allPosts.sort((a, b) => b.date.compareTo(a.date));

    // 3. 리스트가 비어있을 경우 예외 처리
    if (allPosts.isEmpty) {
      return const Center(child: Text('표시할 피드가 없습니다.'));
    }

    return ListView.builder(
      // 스크롤 성능 향상을 위해 적용
      padding: EdgeInsets.zero,
      itemCount: allPosts.length,
      itemBuilder: (context, index) {
        final post = allPosts[index];
        return FeedPostCard(
          post: post,
          onTap: () {
            // 상세 페이지로 이동 로직 (필요 시)
            print('${post.userName}의 ${post.content} 클릭됨');
          },
        );
      },
    );
  }
}
