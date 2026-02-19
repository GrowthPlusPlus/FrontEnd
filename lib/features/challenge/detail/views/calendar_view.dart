// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:intl/intl.dart';

import 'package:haenaem/features/feed/screens/post_detail_screen.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';

class CalendarView extends ConsumerStatefulWidget {
  final int challengeId;
  final ScrollController scrollController;

  const CalendarView({
    super.key,
    required this.challengeId,
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
    final calendarDataAsync = ref.watch(
      challengeCalendarDataProvider(widget.challengeId),
    );

    final photosAsync = ref.watch(
      challengeCalendarPhotosProvider(
        challengeId: widget.challengeId,
        year: _focusedDay.year,
        month: _focusedDay.month,
      ),
    );

    final postsAsync = ref.watch(
      challengePostsProvider(
        challengeId: widget.challengeId,
        year: _focusedDay.year,
        month: _focusedDay.month,
      ),
    );

    // 2. UI 구성
    return calendarDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('에러 발생: $err')),
      data: (summaryData) => Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          controller: widget.scrollController,
          // 하단 버튼 높이만큼 여유 공간을 주어 마지막 리스트가 가려지지 않게 합니다.
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            children: [
              _buildStatCards(summaryData),
              const SizedBox(height: 20),
              _buildCalendarHeader(_focusedDay),
              const SizedBox(height: 10),
              _buildWeekdayHeader(),
              const SizedBox(height: 10),
              photosAsync.when(
                data: (photos) {
                  final allPosts = postsAsync.value ?? [];
                  return _buildCalendarGrid(_focusedDay, photos, allPosts);
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, s) => const Text('달력을 불러오지 못했습니다.'),
              ),
              const SizedBox(height: 20),
              _buildPostsHeader(postsAsync),
              const SizedBox(height: 16),
              postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) return _buildEmptyState();
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) =>
                        _buildCertCard(context, post: posts[index]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Text('인증글 로드 중 에러'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards(ChallengeCalendarModel data) {
    return Row(
      children: [
        _buildStatCard(data.totalSuccessDays.toString(), '완료 일수'),
        const SizedBox(width: 12),
        _buildStatCard(data.currentStreakDays.toString(), '연속 일수'),
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

  Widget _buildCalendarGrid(
    DateTime date,
    List<ChallengeCalendarPhoto> photos,
    List<CertificationPostModel> allPosts,
  ) {
    final int skipDays = DateTime(date.year, date.month, 1).weekday % 7;
    final int lastDayOfMonth = DateTime(date.year, date.month + 1, 0).day;
    final now = DateTime.now();

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: skipDays + lastDayOfMonth,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        if (index < skipDays) return const SizedBox();
        int day = index - skipDays + 1;
        final bool isToday =
            now.year == date.year && now.month == date.month && now.day == day;
        final String targetDateStr =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

        final photoData = photos.firstWhereOrNull(
          (p) => p.postDate == targetDateStr,
        );
        bool isCertified = photoData != null && photoData.postId != -1;

        final CertificationPostModel? fullPost = isCertified
            ? allPosts.firstWhereOrNull((p) => p.postId == photoData.postId) ??
                  allPosts.firstWhereOrNull((p) => p.postDate == targetDateStr)
            : null;

        return GestureDetector(
          onTap: (isCertified && fullPost != null)
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: fullPost),
                  ),
                )
              : null,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCertified
                  ? AppColors.primaryAble
                  : (isToday ? const Color(0x7FDFE1DC) : AppColors.gray5),
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(color: const Color(0xFF616161), width: 1)
                  : null,
              image: (isCertified && photoData.imageUrl != null)
                  ? DecorationImage(
                      image: NetworkImage(photoData.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                color: isCertified
                    ? Colors.white
                    : (isToday ? const Color(0xFF616161) : AppColors.gray2),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsHeader(
    AsyncValue<List<CertificationPostModel>> postsAsync,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('내 인증글', style: AppTypography.b1),
        postsAsync.maybeWhen(
          data: (posts) => Text(
            '총 ${posts.length}개',
            style: AppTypography.c1.copyWith(color: AppColors.gray2),
          ),
          orElse: () => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Text('이번 달 인증글이 없습니다.', style: TextStyle(color: AppColors.gray2)),
  );

  Widget _buildCertCard(
    BuildContext context, {
    required CertificationPostModel post,
  }) {
    final String formattedDate = post.createdAt != null
        ? DateFormat('M월 d일').format(post.createdAt!)
        : "";
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/icons/green_calendar.svg',
                        width: 12,
                        height: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: AppTypography.c1.copyWith(
                          color: AppColors.primaryAble,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.content,
                    style: AppTypography.b2.copyWith(color: AppColors.black),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
