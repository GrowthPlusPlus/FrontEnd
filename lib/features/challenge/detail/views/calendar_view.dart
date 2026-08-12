// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/provider/post_provider.dart';
import '../provider/calendar_share_provider.dart';
import '../provider/stats_provider.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/calendar_post_card.dart';
import '../widgets/calendar_share_preview.dart';
import 'package:haenaem/shared/widgets/confirm_dialog.dart';

class CalendarView extends ConsumerStatefulWidget {
  final int challengeId;
  final int streakCount;
  final ScrollController scrollController;
  final DateTime joinDate;

  const CalendarView({
    super.key,
    required this.challengeId,
    required this.streakCount,
    required this.scrollController,
    required this.joinDate,
  });

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late PageController _pageController;
  DateTime _focusedDay = DateTime.now();

  // 가입한 달의 1일 기준 (일자는 무시, 연-월만 비교용)
  DateTime get _joinedMonth =>
      DateTime(widget.joinDate.year, widget.joinDate.month);

  // 지금 보고 있는 달이 가입한 달인지 여부
  bool get _isAtJoinedMonth =>
      _focusedDay.year == _joinedMonth.year &&
      _focusedDay.month == _joinedMonth.month;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    int initialPage =
        (now.year - widget.joinDate.year) * 12 +
        (now.month - widget.joinDate.month);

    _focusedDay = now;
    _pageController = PageController(initialPage: initialPage);
  }

  // 달 이동 로직
  void _onPrevMonth() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onNextMonth() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 1. 공유 버튼 클릭 이벤트 핸들러
  Future<void> _handleShare() async {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    // 로딩 중 및 안내 문구 표시 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: appColors.whiteToBlack,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: appColors.primaryAble),
                const SizedBox(height: 16),
                Text(
                  '이미지를 생성하고 있습니다...\n(약 5~10초 정도 소요될 수 있습니다)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: appColors.blackToWhite,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final imageUrl = await ref
          .read(calendarShareNotifierProvider.notifier)
          .generateCalendarShareImage(
            challengeId: widget.challengeId,
            year: _focusedDay.year,
            month: _focusedDay.month,
          );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // 로딩 팝업 닫기

      if (imageUrl != null && imageUrl.isNotEmpty) {
        _showSharePreviewModal(imageUrl);
      } else {
        _showRetrySnackBar('이미지 생성 준비 중입니다. 다시 시도 버튼을 눌러주세요.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // 로딩 팝업 닫기
      _showRetrySnackBar('이미지 생성 시간이 지연되었습니다.');
    }
  }

  // 재시도 버튼이 포함된 스낵바
  void _showRetrySnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: '다시 시도',
          textColor: Colors.yellowAccent,
          onPressed: () {
            _handleShare(); // 바로 다시 시도
          },
        ),
      ),
    );
  }

  // 모달 위젯을 띄우는 함수
  void _showSharePreviewModal(String imageUrl) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75), // 어두운 백그라운드
      builder: (modalContext) {
        return CalendarSharePreview(
          imageUrl: imageUrl,
          onSave: () => _saveImageToGallery(imageUrl, modalContext),
          onShare: () => _shareToExternalApp(imageUrl),
        );
      },
    );
  }

  // 이미지 저장 액션
  Future<void> _saveImageToGallery(
    String imageUrl,
    BuildContext modalContext,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath =
          '${tempDir.path}/calendar_share_${DateTime.now().millisecondsSinceEpoch}.png';

      await Dio().download(imageUrl, savePath);
      await Gal.putImage(savePath);

      if (!mounted) return;

      showDialog(
        context: modalContext,
        builder: (dialogContext) => const ConfirmDialog(
          title: '저장 완료',
          content: '갤러리에 성공적으로 저장되었습니다!',
          buttonText: '확인',
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // 💡 에러 발생 시에도 ConfirmDialog로 표시
      showDialog(
        context: modalContext,
        builder: (dialogContext) => ConfirmDialog(
          title: '저장 실패',
          content: '이미지 저장 중 오류가 발생했습니다.\n($e)',
          buttonText: '확인',
        ),
      );
    }
  }

  // 외부 공유 액션 (OS Native Share Sheet)
  Future<void> _shareToExternalApp(String imageUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath =
          '${tempDir.path}/calendar_share_${DateTime.now().millisecondsSinceEpoch}.png';

      await Dio().download(imageUrl, savePath);
      await Share.shareXFiles([
        XFile(savePath),
      ], text: '내 챌린지 달성 기록을 확인해보세요! 🔥');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('공유 중 오류가 발생했습니다.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
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
      loading: () => Scaffold(
        backgroundColor: appColors.whiteToBlack,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(body: Center(child: Text('통계 로드 실패: $e'))),
      data: (stats) => postsAsync.when(
        loading: () => Scaffold(
          backgroundColor: appColors.whiteToBlack,
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => Scaffold(body: Center(child: Text('인증글 로드 실패: $e'))),
        data: (posts) {
          return Scaffold(
            backgroundColor: appColors.whiteToBlack,
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
                      appColors,
                    ),
                    const SizedBox(height: 20),
                    _buildCalendarHeader(_focusedDay, appColors),
                    const SizedBox(height: 10),
                    _buildWeekdayHeader(appColors),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 320, // 달력 높이에 맞춰 조정
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _focusedDay = DateTime(
                              widget.joinDate.year,
                              widget.joinDate.month + index,
                            );
                          });
                        },
                        // 가입 달부터 현재 달까지의 개수만큼만
                        itemCount:
                            (DateTime.now().year - widget.joinDate.year) * 12 +
                            (DateTime.now().month - widget.joinDate.month) +
                            1,
                        itemBuilder: (context, index) {
                          // index 0 = 가입 달 기준으로 날짜 계산
                          final monthDate = DateTime(
                            widget.joinDate.year,
                            widget.joinDate.month + index,
                          );

                          // 개별 달의 데이터를 Provider로 구독
                          return Consumer(
                            builder: (context, ref, child) {
                              final postsAsync = ref.watch(
                                monthlyChallengePostsProvider(
                                  challengeId: widget.challengeId,
                                  year: monthDate.year,
                                  month: monthDate.month,
                                ),
                              );

                              return postsAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (e, s) =>
                                    const Center(child: Text('에러')),
                                data: (posts) => CalendarGrid(
                                  focusedDay: monthDate,
                                  posts: posts,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildPostsHeaderForData(posts.length, appColors),
                    const SizedBox(height: 16),
                    posts.isEmpty
                        ? _buildEmptyState(appColors)
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

  Widget _buildStatCards(
    int totalSuccessDays,
    int currentStreakDays,
    AppColorsExtension appColors,
  ) {
    return Row(
      children: [
        _buildStatCard(totalSuccessDays.toString(), '완료 일수', appColors),
        const SizedBox(width: 12),
        _buildStatCard(currentStreakDays.toString(), '연속 일수', appColors),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    AppColorsExtension appColors,
  ) {
    final intValue = int.tryParse(value) ?? 0;
    final bool showFire = label == '연속 일수' && intValue > 0;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: appColors.gray5,
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
                  style: AppTypography.h1.copyWith(
                    color: appColors.blackToWhite,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: AppTypography.b2.copyWith(color: appColors.blackToWhite),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(DateTime date, AppColorsExtension appColors) {
    final now = DateTime.now();
    bool isFuture =
        date.year > now.year ||
        (date.year == now.year && date.month >= now.month);

    // 가입한 달 도달 여부 — 이 이상 이전으로 못 가게 막기
    bool isAtStart =
        date.year < _joinedMonth.year ||
        (date.year == _joinedMonth.year && date.month <= _joinedMonth.month);

    return Row(
      children: [
        const SizedBox(width: 48),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: isAtStart ? null : _onPrevMonth, // 가입 달이면 비활성화
              icon: SvgPicture.asset(
                'assets/images/icons/left_arrow_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isAtStart
                      ? appColors.gray3
                      : appColors.blackToWhite, // 색상도 비활성 표시
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              '${date.year}년 ${date.month}월',
              style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: isFuture ? null : _onNextMonth,
              icon: SvgPicture.asset(
                'assets/images/icons/right_arrow_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isFuture ? appColors.gray3 : appColors.blackToWhite,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: _handleShare,
          icon: SvgPicture.asset(
            'assets/images/icons/share_icon.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              appColors.blackToWhite,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(AppColorsExtension appColors) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map(
            (day) => Text(
              day,
              style: AppTypography.b3.copyWith(color: appColors.blackToWhite),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPostsHeaderForData(int count, AppColorsExtension appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('내 인증글', style: AppTypography.b1),
        Text(
          '총 $count개',
          style: AppTypography.b2.copyWith(color: appColors.gray2),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppColorsExtension appColors) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Text('이번 달 인증글이 없습니다.', style: TextStyle(color: appColors.gray2)),
  );
}
