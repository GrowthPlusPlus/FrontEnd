// 최초 작성자 : 강선욱
// 피드 화면 클래스 앱 바와 탭 바의 구조를 담당
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/feed/screens/challenge_search_screen.dart';
import '../provider/feed_provider.dart';
import 'package:haenaem/features/feed/views/share_feed_view.dart';
import 'package:haenaem/shared/widgets/custom_tab_bar.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _friendScrollController = ScrollController();
  final ScrollController _exploreScrollController = ScrollController();

  @override
  void dispose() {
    _friendScrollController.dispose();
    _exploreScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: AppBar(
        backgroundColor: appColors.whiteToBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '피드',
          style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(
                      name: ChallengeSearchScreen.routeName,
                    ),
                    builder: (context) => const ChallengeSearchScreen(),
                  ),
                );
              },
              icon: SvgPicture.asset(
                'assets/images/icons/search_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  appColors.blackToWhite,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomTabBar(
        tabs: const ['친구', '둘러보기'],
        scrollControllers: [_friendScrollController, _exploreScrollController],
        children: [
          ShareFeedView(
            scrollController: _friendScrollController,
            provider: friendFeedProvider,
            emptyMessage: "아직 등록된 친구의 피드가 없어요.",
          ),
          ShareFeedView(
            scrollController: _exploreScrollController,
            provider: exploreFeedProvider,
            emptyMessage: "둘러볼 수 있는 피드가 없습니다.",
          ),
        ],
      ),
    );
  }
}
