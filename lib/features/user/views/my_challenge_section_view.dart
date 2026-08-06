// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
//import '../../challenge/models/challenge_model.dart';
// import '../../challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/user/provider/my_challenge_provider.dart';
import '../screens/challenge/challenge_list_screen.dart';
import '../widgets/my_challenge_card.dart'; // 💡 공통 카드 위젯 추가 (위치가 widgets 내부일 경우 경로 주의)
import 'package:haenaem/features/user/models/my_page_challenge_card.dart';

// 내페이지 나의 챌린지 영역
class MyChallengeSectionView extends ConsumerStatefulWidget {
  const MyChallengeSectionView({super.key});

  @override
  ConsumerState<MyChallengeSectionView> createState() =>
      _MyChallengeSectionViewState();
}

enum MyPageTab { inProgress, success, fail }

class _MyChallengeSectionViewState
    extends ConsumerState<MyChallengeSectionView> {
  // 섹션 내부에서 탭 상태 관리
  MyPageTab selectedTab = MyPageTab.inProgress;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.gray4, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(appColors),
          Divider(height: 1, color: appColors.gray4),
          _buildChallengeListArea(appColors),
        ],
      ),
    );
  }

  // --- 헤더 영역 (제목 + 더보기 + 탭) ---
  Widget _buildHeader(AppColorsExtension appColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: appColors.gray5,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '나의 챌린지',
                style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
              ),
              _buildMoreButton(appColors),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusTabs(appColors),
        ],
      ),
    );
  }

  Widget _buildMoreButton(AppColorsExtension appColors) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChallengeListScreen()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('더보기', style: AppTypography.b1.copyWith(color: appColors.gray3)),
          SvgPicture.asset(
            'assets/images/icons/right_arrow_icon.svg',
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }

  // --- 탭 버튼 영역 ---
  Widget _buildStatusTabs(AppColorsExtension appColors) {
    return Row(
      children: [
        _buildTabButton(
          '진행중',
          MyPageTab.inProgress,
          'assets/images/icons/inprogress.svg',
          appColors,
        ),
        const SizedBox(width: 8),
        _buildTabButton(
          '완료',
          MyPageTab.success,
          'assets/images/icons/success_check.svg',
          appColors,
        ),
        const SizedBox(width: 8),
        _buildTabButton(
          '실패',
          MyPageTab.fail,
          'assets/images/icons/fail_circle.svg',
          appColors,
        ),
      ],
    );
  }

  Widget _buildTabButton(
    String label,
    MyPageTab tab,
    String svgPath,
    AppColorsExtension appColors,
  ) {
    final bool isSelected = selectedTab == tab;
    final Color activeColor = _getTabColor(tab, appColors);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : appColors.whiteToBlack,
            borderRadius: BorderRadius.circular(9),
            border: isSelected ? null : Border.all(color: appColors.gray4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  isSelected ? appColors.whiteToBlack : appColors.gray3,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.b2.copyWith(
                  color: isSelected ? appColors.whiteToBlack : appColors.gray3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTabColor(MyPageTab tab, AppColorsExtension appColors) {
    switch (tab) {
      case MyPageTab.inProgress:
        return AppColors.blue;
      case MyPageTab.success:
        return appColors.primaryAble;
      case MyPageTab.fail:
        return appColors.notification;
    }
  }

  // --- 챌린지 리스트 데이터 처리 영역 ---
  Widget _buildChallengeListArea(AppColorsExtension appColors) {
    final challengesAsync = _getChallengesProvider();

    return challengesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('데이터 로드 실패')),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Container(
            height: 100,
            alignment: Alignment.center,
            child: Text(
              '해당하는 챌린지가 없습니다.',
              style: TextStyle(color: appColors.gray2),
            ),
          );
        }
        return Column(
          children: list.asMap().entries.map((entry) {
            final isLast = entry.key == (list.length - 1);
            final challenge = entry.value;
            return Column(
              children: [
                MyChallengeCard(item: challenge),
                if (!isLast) Divider(height: 1, color: appColors.gray5),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  AsyncValue<List<MyPageChallengeCard>> _getChallengesProvider() {
    switch (selectedTab) {
      case MyPageTab.inProgress:
        // 💡 주의: 프로바이더 자체의 정의(challenge_provider.dart)도
        // MyPageChallengeCard를 반환하도록 수정되어 있어야 합니다.
        return ref.watch(myInProgressChallengesProvider(onlyTwo: true));
      case MyPageTab.success:
        return ref.watch(mySuccessChallengesProvider(onlyTwo: true));
      case MyPageTab.fail:
        return ref.watch(myFailedChallengesProvider(onlyTwo: true));
    }
  }
}
