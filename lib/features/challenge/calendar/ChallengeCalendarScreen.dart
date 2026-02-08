// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:intl/intl.dart';

import 'package:haenaem/features/challenge/verification/screens/challenge_verification_screen.dart';
import 'package:haenaem/features/challenge/feed/ChallengeFeedScreen.dart';
import 'package:haenaem/features/challenge/widgets/ChallengePopupMenu.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_create_success_dialog.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';

class ChallengeCalendarScreen extends ConsumerStatefulWidget {
  final int challengeId;
  final String? challengeTitle;
  final bool isJustCreated;
  final ChallengeCreateResponse? createdData;

  const ChallengeCalendarScreen({
    super.key,
    required this.challengeId,
    this.challengeTitle,
    this.isJustCreated = false, // 기본값은 false
    this.createdData,
  });

  @override
  ConsumerState<ChallengeCalendarScreen> createState() =>
      _ChallengeCalendarScreenState();
}

class _ChallengeCalendarScreenState
    extends ConsumerState<ChallengeCalendarScreen> {
  // 1. 클래스 프로퍼티로 현재 보여줄 기준 날짜 선언
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    // 챌린지 생성 직후라면 생성 성공 다이얼로그 실행
    if (widget.isJustCreated && widget.createdData != null) {
      // 프레임이 그려진 직후에 다이얼로그를 띄우기 위해 postFrameCallback 사용
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierColor: const Color(0x7F1A1D1B),
          builder: (context) => ChallengeCreateSuccessDialog(
            challengeLink: widget.createdData!.challengeLink,
            friends: widget.createdData!.friends,
          ),
        );
      });
    }
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
    final calendarDataAsync = ref.watch(
      challengeCalendarDataProvider(widget.challengeId),
    );

    // 달력 그리드용 가벼운 사진 데이터
    final photosAsync = ref.watch(
      challengeCalendarPhotosProvider(
        challengeId: widget.challengeId,
        year: _focusedDay.year,
        month: _focusedDay.month,
      ),
    );

    // 하단 상세 인증글 목록 데이터
    final postsAsync = ref.watch(
      challengePostsProvider(
        challengeId: widget.challengeId,
        year: _focusedDay.year,
        month: _focusedDay.month,
      ),
    );
    return calendarDataAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('에러 발생: $err'))),
      data: (summaryData) => DefaultTabController(
        length: 3,
        initialIndex: 1, // '내 현황' 탭 시작
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(summaryData.challengeOwner),
          // 탭에 따라 다른 화면을 보여주려면 TabBarView를 사용해야 합니다.
          // 현재는 모든 탭에서 공통으로 달력이 보이도록 설정되어 있습니다.
          body: TabBarView(
            children: [
              const Center(child: Text("소개 화면 (준비 중)")), // 탭 0: 소개
              _buildMyStatusView(
                summaryData,
                photosAsync,
                postsAsync,
              ), // 탭 1: 내 현황
              const Center(child: Text("멤버 현황 화면 (준비 중)")), // 탭 2: 멤버 현황
            ],
          ),
          bottomNavigationBar: _buildBottomButton(context),
        ),
      ),
    );
  }

  // 기존 body 내용을 별도 위젯으로 분리 (내 현황 탭 전용)
  Widget _buildMyStatusView(
    ChallengeCalendarModel summaryData,
    AsyncValue<List<ChallengeCalendarPhoto>> photosAsync,
    AsyncValue<List<CertificationPostModel>> postsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          _buildStatCards(summaryData),
          const SizedBox(height: 20),
          _buildCalendarHeader(_focusedDay),
          const SizedBox(height: 20),
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
    );
  }

  PreferredSizeWidget _buildAppBar(bool isHost) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: SvgPicture.asset('assets/images/icons/arrow_left.svg', width: 24),
      ),
      title: Text(widget.challengeTitle ?? "챌린지 현황", style: AppTypography.h3),
      centerTitle: true,
      actions: [
        ChallengePopupMenu(isHost: isHost, challengeId: widget.challengeId),
      ],

      bottom: TabBar(
        labelColor: AppColors.primaryAble,
        unselectedLabelColor: AppColors.gray2,
        indicatorColor: AppColors.primaryAble,
        indicatorWeight: 1,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTypography.b1.copyWith(
          color: AppColors.primaryAble,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: AppTypography.b1.copyWith(color: AppColors.gray2),
        tabs: [
          const Tab(text: '소개'),
          const Tab(text: '내 현황'),
          const Tab(text: '멤버 현황'),
        ],
      ),
    );
  }

  // 인증하기 버튼 분리
  Widget _buildBottomButton(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChallengeVerificationPage(challengeId: widget.challengeId),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAble,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,
          ),
          child: Text(
            '인증하기',
            style: AppTypography.h3.copyWith(color: Colors.white),
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

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Text('이번 달 인증글이 없습니다.', style: TextStyle(color: AppColors.gray2)),
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
                  const SizedBox(width: 4), // 아이콘과 숫자 사이 간격
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

  // 매개변수로 날짜를 받도록 수정
  Widget _buildCalendarHeader(DateTime date) {
    final now = DateTime.now();

    // 미래 날짜인지 확인하는 로직
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
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              '${date.year}년 ${date.month}월',
              style: AppTypography.b1.copyWith(color: AppColors.black),
            ),
            const SizedBox(width: 20),
            // 다음 달 버튼 (미래라면 회색 및 클릭 방지)
            IconButton(
              onPressed: isFuture ? null : _onNextMonth, // 미래면 null을 넣어 비활성화
              icon: SvgPicture.asset(
                'assets/images/icons/right_arrow_icon.svg',
                width: 24,
                height: 24,
                // 미래면 회색, 아니면 검은색
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
            colorFilter: const ColorFilter.mode(
              AppColors.black,
              BlendMode.srcIn,
            ),
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
    List<CertificationPostModel> allPosts, // 상세 정보 리스트
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

        // 오늘 날짜 여부
        final bool isToday =
            now.year == date.year && now.month == date.month && now.day == day;

        // 서버 날짜 형식과 비교
        final String targetDateStr =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

        // photos 리스트에서 해당 날짜 찾기
        final photoData = photos.firstWhereOrNull(
          (p) => p.postDate == targetDateStr,
        );

        bool isCertified = photoData != null && photoData.postId != -1;

        // 클릭 시 넘겨줄 상세 포스트를 posts 리스트에서 찾기
        final CertificationPostModel? fullPost = isCertified
            ? allPosts.firstWhereOrNull((p) => p.postId == photoData.postId) ??
                  allPosts.firstWhereOrNull((p) => p.postDate == targetDateStr)
            : null;

        return GestureDetector(
          onTap: (isCertified && fullPost != null)
              ? () => _navigateToFeed(fullPost)
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

  // 중복 코드 방지를 위한 네비게이션 헬퍼
  void _navigateToFeed(CertificationPostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChallengeFeedScreen(post: post)),
    );
  }

  // 인증글 카드 빌더
  Widget _buildCertCard(
    BuildContext context, {
    required CertificationPostModel post,
  }) {
    // mm월 dd일
    final String formattedDate = post.createdAt != null
        ? DateFormat('M월 d일').format(post.createdAt!)
        : "";
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChallengeFeedScreen(post: post)),
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
            // 1. 이미지 영역 (왼쪽)
            if (post.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.gray5,
                    child: const Icon(
                      Icons.error_outline,
                      color: AppColors.gray3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // 캘린더 + mm월 dd일
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                  const SizedBox(height: 4), // 날짜와 내용 사이 간격
                  // 인증 내용
                  Text(
                    post.content,
                    style: AppTypography.b2.copyWith(color: AppColors.black),
                    maxLines: 3, // 내용이 너무 길어질 경우 3줄까지만 표시
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
