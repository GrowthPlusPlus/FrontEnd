// 최초 작성자 : 강선욱
// 피드 화면 클래스 앱 바와 탭 바의 구조를 담당
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/feed/screens/challenge_search_screen.dart';
import 'package:haenaem/features/feed/provider/feed_provider.dart';
import 'package:haenaem/features/feed/views/share_feed_view.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _friendScrollController = ScrollController();
  final ScrollController _exploreScrollController = ScrollController();
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _previousIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendScrollController.dispose();
    _exploreScrollController.dispose();
    super.dispose();
  }

  // 최상단 이동 애니메이션 함수
  void _scrollToTop(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '피드',
          style: AppTypography.h3.copyWith(color: AppColors.black),
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
                    builder: (context) => const ChallengeSearchScreen(),
                  ),
                );
              },
              icon: SvgPicture.asset(
                'assets/images/icons/search_icon.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryAble,
          unselectedLabelColor: AppColors.gray4,
          indicatorColor: AppColors.primaryAble,
          indicatorWeight: 1,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: AppTypography.b1,
          unselectedLabelStyle: AppTypography.b1,
          onTap: (index) {
            if (_previousIndex == index) {
              if (index == 0) {
                _scrollToTop(_friendScrollController);
              } else {
                _scrollToTop(_exploreScrollController);
              }
            }
          },
          tabs: const [
            Tab(text: '친구'),
            Tab(text: '둘러보기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 탭별로 다른 Provider와 컨트롤러를 주입
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
