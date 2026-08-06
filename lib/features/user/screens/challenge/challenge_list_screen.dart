// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:haenaem/features/challenge/models/challenge_model.dart';
// import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/user/provider/my_challenge_provider.dart';
import '../../widgets/my_challenge_card.dart'; // 💡 공통 카드 위젯 추가
import 'package:haenaem/features/user/models/my_page_challenge_card.dart';

// 클래스의 용도: 챌린지 목록을 진행중, 완료, 실패 탭으로 구분하여 보여주는 화면
class ChallengeListScreen extends ConsumerWidget {
  const ChallengeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final inProgressAsync = ref.watch(
      myInProgressChallengesProvider(onlyTwo: false),
    );
    final successAsync = ref.watch(mySuccessChallengesProvider(onlyTwo: false));
    final failedAsync = ref.watch(myFailedChallengesProvider(onlyTwo: false));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: appColors.whiteToBlack,
        appBar: AppBar(
          backgroundColor: appColors.whiteToBlack,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset(
              'assets/images/icons/arrow_left.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                appColors.blackToWhite,
                BlendMode.srcIn,
              ),
            ),
          ),
          title: Text(
            '나의 챌린지',
            style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
          ),
        ),
        body: Column(
          children: [
            _buildTabBar(appColors),
            Expanded(
              child: Container(
                color: appColors.gray5,
                child: TabBarView(
                  children: [
                    inProgressAsync.when(
                      data: (list) => _buildFilteredListView(list),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, __) => Center(child: Text('로드 실패: $err')),
                    ),
                    successAsync.when(
                      data: (list) => _buildFilteredListView(list),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, __) => Center(child: Text('로드 실패: $err')),
                    ),
                    failedAsync.when(
                      data: (list) => _buildFilteredListView(list),
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

  Widget _buildTabBar(AppColorsExtension appColors) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.whiteToBlack,
        border: Border(bottom: BorderSide(color: appColors.gray4, width: 1)),
      ),
      child: TabBar(
        indicatorColor: appColors.primaryAble,
        labelColor: appColors.primaryAble,
        unselectedLabelColor: appColors.gray2,
        tabs: [
          Tab(text: '진행중'),
          Tab(text: '완료'),
          Tab(text: '실패'),
        ],
      ),
    );
  }

  Widget _buildFilteredListView(List<MyPageChallengeCard> list) {
    if (list.isEmpty) {
      return const Center(child: Text('해당하는 챌린지가 없습니다.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => MyChallengeCard(item: list[index]),
    );
  }
}
