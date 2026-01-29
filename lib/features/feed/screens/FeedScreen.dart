import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/feed/screens/ChallengeSearchScreen.dart';
import 'package:haenaem/features/feed/views/ExploreFeedView.dart';
import 'package:haenaem/features/feed/views/FriendFeedView.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

// 탭 애니메이션을 위한 SingleTickerProviderStateMixin 추가
class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  // 탭 제어와 스크롤 제어를 위한 컨트롤러 선언
  late TabController _tabController;
  final ScrollController _friendScrollController = ScrollController();
  final ScrollController _exploreScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // TabController 초기화
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // 컨트롤러 해제
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
        // 1. 중앙 타이틀: 피드
        title: Text(
          '피드',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
        // 2. 우측 검색 아이콘
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
        // 3. 탭바 구성
        bottom: TabBar(
          controller: _tabController, // 수동 제어를 위한 컨트롤러 연결
          // 선택된 탭 스타일 (이미지의 초록색 계열)
          labelColor: AppColors.primaryAble,
          unselectedLabelColor: AppColors.gray4,
          indicatorColor: AppColors.primaryAble,
          indicatorWeight: 1,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: AppTypography.b1,
          unselectedLabelStyle: AppTypography.b1,
          // 탭 클릭 이벤트 핸들러 추가
          onTap: (index) {
            // 현재 선택된 인덱스와 클릭된 인덱스가 같으면 스크롤 상단 이동
            if (_tabController.index == index) {
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
        controller: _tabController, // 컨트롤러 연결
        children: [
          // 각 뷰에 정의한 스크롤 컨트롤러 주입
          FriendFeedView(scrollController: _friendScrollController),
          ExploreFeedView(scrollController: _exploreScrollController), //
        ],
      ),
    );
  }
}
