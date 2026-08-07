// 최초 작성자: 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/feed/provider/feed_provider.dart';
import 'package:haenaem/features/feed/views/share_feed_view.dart';
import 'package:haenaem/core/theme/app_colors.dart';

class MemberView extends ConsumerStatefulWidget {
  final int challengeId;
  final ScrollController scrollController;

  const MemberView({
    super.key,
    required this.challengeId,
    required this.scrollController,
  });

  @override
  ConsumerState<MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends ConsumerState<MemberView> {
  @override
  void initState() {
    super.initState();
    // 💡 화면이 로드될 때 해당 챌린지의 멤버 피드 데이터를 불러옵니다.
    Future.microtask(() {
      ref.read(memberFeedProvider(widget.challengeId).notifier).fetchFeeds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // challengeId별로 독립적인 상태를 가진 프로바이더를 참조합니다.
    final provider = memberFeedProvider(widget.challengeId);

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      body: ShareFeedView(
        scrollController: widget.scrollController,
        provider: provider,
        emptyMessage: "아직 멤버들의 인증글이 없습니다.\n첫 인증을 남겨보세요!",
      ),
    );
  }
}
