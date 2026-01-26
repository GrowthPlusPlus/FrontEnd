import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                  // 검색 기능 구현
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
          bottom: const TabBar(
            // 선택된 탭 스타일 (이미지의 초록색 계열)
            labelColor: AppColors.primaryAble,
            unselectedLabelColor: AppColors.gray4,
            indicatorColor: AppColors.primaryAble,
            indicatorWeight: 1,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: AppTypography.b1,
            unselectedLabelStyle: AppTypography.b1,
            tabs: [
              Tab(text: '친구'),
              Tab(text: '둘러보기'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('친구 피드 화면')),
            Center(child: Text('둘러보기 피드 화면')),
          ],
        ),
      ),
    );
  }
}
