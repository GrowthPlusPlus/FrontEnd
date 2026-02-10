// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/feed/ChallengeFeedScreen.dart';
import 'package:haenaem/features/challenge/widgets/ChallengePopupMenu.dart';
import 'package:haenaem/features/challenge/widgets/UserChallengeData.dart';
import 'package:haenaem/features/challenge/widgets/MockData.dart';

class ChallengeCalendarScreen extends StatefulWidget {
  const ChallengeCalendarScreen({super.key});

  @override
  State<ChallengeCalendarScreen> createState() =>
      _ChallengeCalendarScreenState();
}

class _ChallengeCalendarScreenState extends State<ChallengeCalendarScreen> {
  // 1. 클래스 프로퍼티로 현재 보여줄 기준 날짜 선언
  DateTime _focusedDay = DateTime.now();

  // 2. 사용자 챌린지 데이터 선언
  // 아직 데이터가 없을 수 있으므로 late를 사용하여 initState에서 초기화
  late UserChallengeData challengeData;

  @override
  void initState() {
    super.initState();
    challengeData = MockData.getChallengeByName("매일 10분 러닝");
  }

  // 달 이동 로직
  void _onPrevMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<CertificationPost> filteredPosts = challengeData.getPostsByMonth(
      _focusedDay.year,
      _focusedDay.month,
    );

    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset(
              'assets/images/icons/arrow_left.svg',
              width: 24,
              height: 24,
            ),
          ),
          title: Text(
            challengeData.challengeName,
            style: AppTypography.h3.copyWith(color: AppColors.black),
          ),
          centerTitle: true,
          actions: [
            ChallengePopupMenu(
              // 실제 데이터에서 현재 유저가 방장인지 여부를 가져와서 전달
              isHost: challengeData.isHost,
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.primaryAble,
            unselectedLabelColor: AppColors.gray2,
            indicatorColor: AppColors.primaryAble,
            indicatorWeight: 1,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: AppTypography.b1.copyWith(color: AppColors.primaryAble),
            unselectedLabelStyle: AppTypography.b1.copyWith(
              color: AppColors.gray2,
            ),
            tabs: [
              const Tab(text: '소개'),
              const Tab(text: '내 현황'),
              const Tab(text: '멤버 현황'),
            ],
          ),
        ),

        // 하단 고정 - 인증하기 버튼
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: ElevatedButton(
              onPressed: () {},
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
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  _buildStatCard(
                    challengeData.totalCertCount.toString(),
                    '완료 일수',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    challengeData.continuousCertCount.toString(),
                    '연속 일수',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 년, 월
              _buildCalendarHeader(_focusedDay),
              const SizedBox(height: 20),
              // 요일
              _buildWeekdayHeader(),
              const SizedBox(height: 10),
              // 캘린더 그리드
              _buildCalendarGrid(_focusedDay, challengeData.posts),

              const SizedBox(height: 20),

              // 인증글 리스트 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '내 인증글',
                    style: AppTypography.b1.copyWith(color: AppColors.black),
                  ),
                  Text(
                    '총 ${filteredPosts.length}개',
                    style: AppTypography.c1.copyWith(color: AppColors.gray2),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (filteredPosts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    '이번 달 인증글이 없습니다.',
                    style: AppTypography.b2.copyWith(color: AppColors.gray2),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    return _buildCertCard(
                      context,
                      date: '${post.date.month}월 ${post.date.day}일',
                      content: post.content,
                      imageUrl: post.imageUrl,
                      post: post,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
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

  Widget _buildCalendarGrid(DateTime date, List<CertificationPost> posts) {
    final year = date.year;
    final month = date.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final int skipDays = firstDayOfMonth.weekday % 7;
    final int lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
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
        DateTime targetDate = DateTime(year, month, day);

        // 1. 해당 날짜의 인증글 찾기
        final postToday = challengeData.getPostByDay(targetDate);

        bool isCertified = postToday != null;
        bool isToday =
            today.year == year && today.month == month && today.day == day;

        // 스타일 설정 초기화
        Color bgColor = AppColors.gray5;
        BoxBorder? border;
        DecorationImage? bgImage; // 배경 이미지 변수 추가
        TextStyle textStyle = AppTypography.b2.copyWith(color: AppColors.gray2);

        // 2. 조건별 스타일 적용
        if (isCertified) {
          // 인증글이 있는 경우
          if (postToday.imageUrl != null && postToday.imageUrl!.isNotEmpty) {
            // 사진이 있는 경우: 배경 이미지 설정
            bgImage = DecorationImage(
              image: AssetImage(postToday.imageUrl!),
              fit: BoxFit.cover,
              // 사진 위 글자가 잘 보이도록 어둡게 처리 (선택사항)
              colorFilter: ColorFilter.mode(
                Colors.black.withAlpha(100),
                BlendMode.darken,
              ),
            );
          } else {
            // 사진이 없는 경우: 초록색 배경
            bgColor = AppColors.primaryAble;
          }
          textStyle = textStyle.copyWith(color: Colors.white);
        } else if (isToday) {
          // 인증글은 없지만 오늘인 날
          border = Border.all(color: AppColors.gray2, width: 1);
          bgColor = const Color(0xFFF2F2F2);
          textStyle = textStyle.copyWith(
            color: AppColors.gray2,
            fontWeight: FontWeight.w700,
          );
        }

        return GestureDetector(
          onTap: () {
            if (isCertified) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // postToday를 인자로 전달합니다.
                  builder: (context) => ChallengeFeedScreen(post: postToday),
                ),
              );
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: border,
              image: bgImage,
            ),
            child: Text('$day', style: textStyle),
          ),
        );
      },
    );
  }

  // 인증글 카드 빌더
  Widget _buildCertCard(
    BuildContext context, { // 1. Navigator 사용을 위한 context 추가
    required String date,
    required String content,
    String? imageUrl,
    required CertificationPost post, // 2. 이동할 때 넘겨줄 데이터 객체 추가
  }) {
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      // 3. 클릭 감지를 위한 GestureDetector 추가
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeFeedScreen(post: post),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 날짜 영역
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/icons/green_calendar.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryAble,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: AppTypography.c1.copyWith(
                    color: AppColors.primaryAble,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // 2. 내용 영역
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.gray4,
                        child: const Icon(
                          Icons.error_outline,
                          size: 20,
                          color: AppColors.gray2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // 3. 텍스트 영역
                Expanded(
                  child: Text(
                    content,
                    style: AppTypography.b2.copyWith(color: AppColors.gray1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
