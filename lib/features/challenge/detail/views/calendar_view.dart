// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/post_provider.dart';
import '../provider/stats_provider.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/calendar_post_card.dart';

class CalendarView extends ConsumerStatefulWidget {
  final int challengeId;
  final int streakCount;
  final ScrollController scrollController;

  const CalendarView({
    super.key,
    required this.challengeId,
    required this.streakCount,
    required this.scrollController,
  });

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  // 달 이동 로직
  void _onPrevMonth() => setState(
    () => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1),
  );
  void _onNextMonth() => setState(
    () => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1),
  );

  @override
  Widget build(BuildContext context) {
    // 1. 데이터 구독
    final statsAsync = ref.watch(challengeStatsProvider(widget.challengeId));

    final postsProvider = monthlyChallengePostsProvider(
      challengeId: widget.challengeId,
      year: _focusedDay.year,
      month: _focusedDay.month,
    );

    final postsAsync = ref.watch(postsProvider);

    // 2. 통합 로딩/에러/데이터 처리
    return statsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(body: Center(child: Text('통계 로드 실패: $e'))),
      data: (stats) => postsAsync.when(
        loading: () => const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => Scaffold(body: Center(child: Text('인증글 로드 실패: $e'))),
        data: (posts) {
          return Scaffold(
            backgroundColor: Colors.white,
            // [추가] 당겨서 새로고침 위젯
            body: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(challengeStatsProvider(widget.challengeId));
                ref.invalidate(postsProvider);

                // 두 데이터가 로드될 때까지 대기
                await Future.wait([
                  ref.read(challengeStatsProvider(widget.challengeId).future),
                  ref.read(postsProvider.future),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Column(
                  children: [
                    _buildStatCards(
                      stats.totalSuccessDays,
                      stats.currentStreakDays,
                    ),
                    const SizedBox(height: 20),
                    _buildCalendarHeader(_focusedDay),
                    const SizedBox(height: 10),
                    _buildWeekdayHeader(),
                    const SizedBox(height: 10),
                    CalendarGrid(focusedDay: _focusedDay, posts: posts),
                    const SizedBox(height: 20),
                    _buildPostsHeaderForData(posts.length),
                    const SizedBox(height: 16),
                    posts.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: posts.length,
                            itemBuilder: (context, index) =>
                                CalendarPostCard(post: posts[index]),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards(int totalSuccessDays, int currentStreakDays) {
    return Row(
      children: [
        _buildStatCard(totalSuccessDays.toString(), '완료 일수'),
        const SizedBox(width: 12),
        _buildStatCard(currentStreakDays.toString(), '연속 일수'),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    final intValue = int.tryParse(value) ?? 0;
    final bool showFire = label == '연속 일수' && intValue > 0;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.gray5,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showFire) ...[
                  SvgPicture.asset(
                    'assets/images/icons/big_fire_icon.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.black, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(DateTime date) {
    final now = DateTime.now();
    bool isFuture =
        date.year > now.year ||
        (date.year == now.year && date.month >= now.month);

    return Row(
      children: [
        const SizedBox(width: 48),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _onPrevMonth,
              icon: SvgPicture.asset(
                'assets/images/icons/left_arrow_icon.svg',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              '${date.year}년 ${date.month}월',
              style: AppTypography.b1.copyWith(color: AppColors.black),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: isFuture ? null : _onNextMonth,
              icon: SvgPicture.asset(
                'assets/images/icons/right_arrow_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isFuture ? AppColors.gray3 : AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            'assets/images/icons/share_icon.svg',
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map(
            (day) => Text(
              day,
              style: AppTypography.b1.copyWith(color: AppColors.black),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPostsHeaderForData(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('내 인증글', style: AppTypography.b1),
        Text(
          '총 $count개',
          style: AppTypography.c1.copyWith(color: AppColors.gray2),
        ),
      ],
    );
  }

  Widget _buildEmptyState() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Text('이번 달 인증글이 없습니다.', style: TextStyle(color: AppColors.gray2)),
  );
}
