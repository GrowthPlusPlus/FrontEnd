// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../challenge/models/challenge_model.dart';
import '../../challenge/provider/challenge_provider.dart';
import '../screens/challenge_list_screen.dart';

// 챌린지 로직 (탭 전환, 리스트 필터링, 카드 디자인)
class ChallengeSection extends ConsumerStatefulWidget {
  const ChallengeSection({super.key});

  @override
  ConsumerState<ChallengeSection> createState() => _ChallengeSectionState();
}

class _ChallengeSectionState extends ConsumerState<ChallengeSection> {
  // 섹션 내부에서 탭 상태 관리
  MyPageTab selectedTab = MyPageTab.inProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray4, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppColors.gray4),
          _buildChallengeListArea(),
        ],
      ),
    );
  }

  // --- 헤더 영역 (제목 + 더보기 + 탭) ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.gray5,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '나의 챌린지',
                style: AppTypography.h3.copyWith(color: Colors.black),
              ),
              _buildMoreButton(),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusTabs(),
        ],
      ),
    );
  }

  Widget _buildMoreButton() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChallengeListScreen()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('더보기', style: AppTypography.b1.copyWith(color: AppColors.gray3)),
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
  Widget _buildStatusTabs() {
    return Row(
      children: [
        _buildTabButton(
          '진행중',
          MyPageTab.inProgress,
          'assets/images/icons/inprogress.svg',
        ),
        const SizedBox(width: 8),
        _buildTabButton(
          '완료',
          MyPageTab.success,
          'assets/images/icons/success_check.svg',
        ),
        const SizedBox(width: 8),
        _buildTabButton(
          '실패',
          MyPageTab.fail,
          'assets/images/icons/fail_circle.svg',
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, MyPageTab tab, String svgPath) {
    final bool isSelected = selectedTab == tab;
    final Color activeColor = _getTabColor(tab);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: isSelected ? null : Border.all(color: AppColors.gray4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : AppColors.gray3,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.b2.copyWith(
                  color: isSelected ? Colors.white : AppColors.gray3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTabColor(MyPageTab tab) {
    switch (tab) {
      case MyPageTab.inProgress:
        return AppColors.blue;
      case MyPageTab.success:
        return AppColors.primaryAble;
      case MyPageTab.fail:
        return AppColors.notification;
    }
  }

  // --- 챌린지 리스트 데이터 처리 영역 ---
  Widget _buildChallengeListArea() {
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
            child: const Text(
              '해당하는 챌린지가 없습니다.',
              style: TextStyle(color: AppColors.gray2),
            ),
          );
        }
        return Column(
          children: list.asMap().entries.map((entry) {
            final isLast = entry.key == (list.length - 1);
            return Column(
              children: [
                _buildChallengeCard(entry.value),
                if (!isLast) Divider(height: 1, color: AppColors.gray5),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  AsyncValue<List<ChallengeInProgressModel>> _getChallengesProvider() {
    switch (selectedTab) {
      case MyPageTab.inProgress:
        return ref.watch(myInProgressChallengesProvider(onlyTwo: true));
      case MyPageTab.success:
        return ref.watch(mySuccessChallengesProvider(onlyTwo: true));
      case MyPageTab.fail:
        return ref.watch(myFailedChallengesProvider(onlyTwo: true));
    }
  }

  // --- 개별 챌린지 카드 UI ---
  Widget _buildChallengeCard(ChallengeInProgressModel item) {
    final serverStatus = item.status.toUpperCase();

    // 실패한 챌린지일 경우 전용 UI를 반환
    if (serverStatus == "FAIL" || serverStatus == "FAILED") {
      return _buildFailedChallengeCard(item);
    }

    // 완료 상태일 때
    if (serverStatus == "SUCCESS") {
      return _buildSuccessChallengeCard(item);
    }

    final Color themeColor = _getTabColor(selectedTab);

    String statusText = '진행중';
    if (serverStatus == "SUCCESS")
      statusText = '완료';
    else if (serverStatus == "FAIL" || serverStatus == "FAILED")
      statusText = '실패';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start, // 추가
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: AppTypography.b3.copyWith(
                              color: AppColors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 7.35),
                        _buildStatusBadge(statusText, themeColor),
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
              _buildProgressText(item.progress, themeColor),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(item, serverStatus),
          const SizedBox(height: 8),
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

  // 완료 전용 카드 UI
  Widget _buildSuccessChallengeCard(ChallengeInProgressModel item) {
    const Color successColor = AppColors.primaryAble;
    Color gray5 = AppColors.gray5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.69, color: gray5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽 정보 영역
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: AppTypography.b3.copyWith(
                              color: AppColors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 7.35),
                        _buildStatusBadge('완료', successColor),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // 완료일 데이터 바인딩
                    Text(
                      '완료일 ${item.endDate.replaceAll('-', '/')}',
                      style: AppTypography.b2.copyWith(color: AppColors.gray2),
                    ),
                    const SizedBox(height: 2),
                    // 총 진행 일수 + 불 아이콘
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/small_fire_icon.svg',
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '총 ${item.duringDate}일',
                          style: AppTypography.b2.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(item.progress * 100).toInt()}%',
                    textAlign: TextAlign.right,
                    style: AppTypography.h2.copyWith(color: successColor),
                  ),
                  Text(
                    '달성률',
                    textAlign: TextAlign.right,
                    style: AppTypography.c1.copyWith(color: AppColors.gray2),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 하단 게이지 바
          ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: LinearProgressIndicator(
              value: item.progress,
              minHeight: 4,
              backgroundColor: gray5,
              valueColor: const AlwaysStoppedAnimation<Color>(successColor),
            ),
          ),
        ],
      ),
    );
  }

  // 실패 전용 카드 UI
  Widget _buildFailedChallengeCard(ChallengeInProgressModel item) {
    const Color failColor = AppColors.notification;
    Color gray5 = AppColors.gray5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.69, color: gray5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 왼쪽 정보 영역
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: AppTypography.b3.copyWith(
                              color: AppColors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 7.35),
                        _buildStatusBadge('실패', failColor),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // 실패일 데이터 바인딩
                    Text(
                      '실패일 ${item.endDate.replaceAll('-', '/')}',
                      style: AppTypography.b2.copyWith(color: AppColors.gray2),
                    ),
                    const SizedBox(height: 2),
                    // 누적 진행일 데이터 바인딩
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/small_fire_icon.svg', // 불 아이콘 경로 확인 필요
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 2), // 아이콘과 텍스트 사이 간격 2
                        Text(
                          '최대 ${item.duringDate}일',
                          style: AppTypography.b2.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 2. 오른쪽 달성률 영역
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(item.progress * 100).toInt()}%',
                    textAlign: TextAlign.right,
                    style: AppTypography.h2.copyWith(
                      color: AppColors.notification,
                    ),
                  ),
                  Text(
                    '달성률',
                    textAlign: TextAlign.right,
                    style: AppTypography.c1.copyWith(color: AppColors.gray2),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 3. 하단 게이지 바 (Gauge)
          ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: LinearProgressIndicator(
              value: item.progress,
              minHeight: 4,
              backgroundColor: gray5,
              valueColor: const AlwaysStoppedAnimation<Color>(failColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: AppTypography.c1.copyWith(color: color)),
    );
  }

  Widget _buildProgressText(double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${(progress * 100).toInt()}%',
          style: AppTypography.h2.copyWith(color: color),
        ),
        Text('달성률', style: AppTypography.c1.copyWith(color: AppColors.gray2)),
      ],
    );
  }

  Widget _buildInfoRow(ChallengeInProgressModel item, String status) {
    return Row(
      children: [
        SvgPicture.asset('assets/images/icons/small_fire_icon.svg', width: 16),
        const SizedBox(width: 2),
        Text(
          '${item.duringDate}일째',
          style: AppTypography.b2.copyWith(color: AppColors.black),
        ),
        const SizedBox(width: 12),
        if (status == "IN_PROGRESS") ...[
          SvgPicture.asset(
            'assets/images/icons/mini_success_icon.svg',
            width: 16,
          ),
          const SizedBox(width: 2),
          Text(
            item.countInfo,
            style: AppTypography.b2.copyWith(color: AppColors.black),
          ),
        ],
      ],
    );
  }
}
