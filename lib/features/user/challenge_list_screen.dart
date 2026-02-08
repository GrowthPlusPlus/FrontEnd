/// 최초 작성자: 정승빈
/// 작성일: 2026-02-03
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';

/// 클래스의 용도: 챌린지 목록을 진행중, 완료, 실패 탭으로 구분하여 보여주는 화면
class ChallengeListScreen extends ConsumerWidget {
  const ChallengeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 세 가지 API 모두 구독 (전체 목록을 위해 onlyTwo: false)
    final inProgressAsync = ref.watch(
      myInProgressChallengesProvider(onlyTwo: false),
    );
    final successAsync = ref.watch(mySuccessChallengesProvider(onlyTwo: false));
    final failedAsync = ref.watch(myFailedChallengesProvider(onlyTwo: false));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset(
              'assets/images/icons/arrow_left.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
          title: Text(
            '나의 챌린지',
            style: AppTypography.h3.copyWith(color: AppColors.black),
          ),
        ),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: Container(
                color: AppColors.gray5,
                child: TabBarView(
                  children: [
                    // 1. 진행중 탭
                    inProgressAsync.when(
                      data: (list) =>
                          _buildFilteredListView(list, "IN_PROGRESS"),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, __) => Center(child: Text('로드 실패: $err')),
                    ),
                    // 2. 완료 탭
                    successAsync.when(
                      data: (list) => _buildFilteredListView(list, "SUCCESS"),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, __) => Center(child: Text('로드 실패: $err')),
                    ),
                    // 3. 실패 탭
                    failedAsync.when(
                      data: (list) => _buildFilteredListView(list, "FAIL"),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, __) => Center(child: Text('로드 실패: $err')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray4, width: 1)),
      ),
      child: const TabBar(
        indicatorColor: AppColors.primaryAble,
        labelColor: AppColors.primaryAble,
        unselectedLabelColor: AppColors.gray2,
        tabs: [
          Tab(text: '진행중'),
          Tab(text: '완료'),
          Tab(text: '실패'),
        ],
      ),
    );
  }

  // 상태별 리스트 필터링 및 출력
  Widget _buildFilteredListView(
    List<ChallengeInProgressModel> list,
    String tabStatus,
  ) {
    final filtered = list.where((item) {
      final serverStatus = item.status.toUpperCase();
      return serverStatus == tabStatus ||
          (tabStatus == "FAIL" && serverStatus == "FAILED");
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('해당하는 챌린지가 없습니다.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildFullChallengeCard(filtered[index]),
    );
  }

  // 마이페이지와 디자인을 통일한 챌린지 카드
  Widget _buildFullChallengeCard(ChallengeInProgressModel item) {
    Color themeColor;
    String statusText;
    final serverStatus = item.status.toUpperCase();

    if (serverStatus == "SUCCESS") {
      themeColor = AppColors.primaryAble;
      statusText = '완료';
    } else if (serverStatus == "FAIL" || serverStatus == "FAILED") {
      themeColor = AppColors.notification;
      statusText = '실패';
    } else {
      themeColor = AppColors.blue;
      statusText = '진행중';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: AppTypography.b3.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: ShapeDecoration(
                            color: themeColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: AppTypography.c1.copyWith(color: themeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.dateInfo,
                      style: AppTypography.b2.copyWith(color: AppColors.gray2),
                    ),
                  ],
                ),
              ),
              // 오른쪽 영역 : 몇퍼 + 달성률 텍스트
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(item.progress * 100).toInt()}%',
                    style: AppTypography.h2.copyWith(color: themeColor),
                  ),
                  Text(
                    '달성률',
                    style: AppTypography.c1.copyWith(color: AppColors.gray2),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          // 하단 정보
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/icons/small_fire_icon.svg',
                width: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.duringDate}일째',
                style: AppTypography.b2.copyWith(color: AppColors.black),
              ),
              const SizedBox(width: 12),
              if (serverStatus == "IN_PROGRESS") ...[
                SvgPicture.asset(
                  'assets/images/icons/mini_success_icon.svg',
                  width: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  item.countInfo,
                  style: AppTypography.b2.copyWith(color: AppColors.black),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // 진행률 바
          LinearProgressIndicator(
            value: item.progress,
            backgroundColor: AppColors.gray5,
            color: themeColor,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
