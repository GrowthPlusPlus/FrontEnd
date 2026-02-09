// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 추가
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/create/screens/challenge_create_page.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/calendar/ChallengeCalendarScreen.dart';

class HomeScreen extends ConsumerWidget {
  // StatelessWidget -> ConsumerWidget 변경
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WidgetRef 추가
    // Riverpod 상태 구독
    final homeDataAsync = ref.watch(challengeHomeNotifierProvider);
    final todayStatus = ref.watch(todayTotalStatusProvider);

    // 1. 이번 주의 일요일 날짜 구하기
    DateTime now = DateTime.now();
    DateTime firstDayOfWeek = now.subtract(Duration(days: now.weekday % 7));

    // 2. 일~토까지의 DateTime 리스트 생성
    List<DateTime> weekDays = List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: homeDataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
          data: (data) => Stack(
            children: [
              // 메인 컨텐츠
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단 날짜 + 아이콘
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          getFormattedDate(), // 수정됨: 오늘 날짜를 함수에서 받아옴
                          style: AppTypography.h2.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const Spacer(),
                        // 알림 아이콘: API의 notificationNumber 활용 가능
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                'assets/images/icons/home_notice_icon.svg',
                                width: 24,
                                height: 24,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            if (data.notificationNumber > 0)
                              Positioned(
                                right: 8,
                                top: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: AppColors.notification,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${data.notificationNumber}',
                                    style: AppTypography.c1.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/images/icons/dots_vert_icon.svg',
                            width: 24,
                            height: 24,
                          ),
                          color: AppColors.black,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 주간 캘린더
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: Row(
                      children: weekDays.map((date) {
                        final isToday =
                            date.year == now.year &&
                            date.month == now.month &&
                            date.day == now.day;

                        return _DayChip(
                          date: date,
                          isSelected: isToday,
                          // 오늘인 경우에만 종합 상태를 전달하고, 다른 날은 기본 상태 전달
                          status: isToday
                              ? todayStatus
                              : ChallengeStatus.normal,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 챌린지 카드
                  // 사용자의 챌린지 정보를 받아와 챌린지 카드를 리스트로 렌더링
                  // [스크롤 영역] 챌린지 리스트만 Expanded로 감싸 독립적 스크롤 부여
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ref
                          .read(challengeHomeNotifierProvider.notifier)
                          .refresh(),
                      child: ChallengeListView(challenges: data.myChallenges),
                    ),
                  ),
                ],
              ),

              // 우하단 플로팅 + 버튼
              Positioned(
                right: 20,
                bottom: 30, // 하단바 위로 떠 있게
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChallengeCreatePage(),
                      ),
                    );
                  }, // 채팅방 생성 페이지 연결
                  backgroundColor: Colors.white,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 32, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 작성자: Gemini
  // 함수의 용도: 현재 날짜를 'yyyy. MM. dd' 형식의 문자열로 반환함
  String getFormattedDate() {
    DateTime now = DateTime.now();
    String year = now.year.toString();
    // 월과 일이 10보다 작을 경우 앞에 0을 붙여 두 자리로 맞춤 (예: 01, 05)
    String month = now.month.toString().padLeft(2, '0');
    String day = now.day.toString().padLeft(2, '0');

    return '$year. $month. $day';
  }
}

// 작성자: Gemini
// 클래스 용도: 날짜별 챌린지 수행 상태를 색상으로 표시하는 캘린더 칩
class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final ChallengeStatus status; // 추가됨

  const _DayChip({
    required this.date,
    this.isSelected = false,
    this.status = ChallengeStatus.normal,
  });

  @override
  Widget build(BuildContext context) {
    const Color black = AppColors.black;
    const Color gray2 = AppColors.gray2;

    // 요일 레이블 매핑
    const weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
    String label = weekdayLabels[date.weekday % 7];
    String day = date.day.toString();

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.b1.copyWith(
              fontFamily: 'Pretendard',
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // 요구사항에 따른 배경색 동적 변경
              color: getBackgroundColor(),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              day,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 14,
                color: isSelected && status != ChallengeStatus.normal
                    ? Colors.white
                    : gray2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 함수의 용도: 상태에 따른 캘린더 칩 배경색 결정
  Color getBackgroundColor() {
    if (!isSelected) return const Color(0xFFE0E2DC).withOpacity(0.5);

    switch (status) {
      case ChallengeStatus.urgent:
        return AppColors.notification; // 오늘 챌린지 중 Urgent가 하나라도 있음
      case ChallengeStatus.completed:
        return AppColors.primaryAble; // 오늘 모든 챌린지 완료
      case ChallengeStatus.normal:
      default:
        return AppColors.gray4; // 진행 중인 챌린지 있음
    }
  }
}

// 작성자: Gemini
// 클래스 용도: 사용자의 챌린지 목록을 리스트 형태로 렌더링하며, 데이터가 없을 시 안내 문구를 표시함
class ChallengeListView extends StatelessWidget {
  final List<ChallengeModel> challenges; // Challenge -> ChallengeModel 변경

  const ChallengeListView({super.key, required this.challenges});

  @override
  Widget build(BuildContext context) {
    // 데이터 유무에 따른 조건부 렌더링
    if (challenges.isEmpty) {
      return _buildEmptyState();
    }

    // ListView.builder를 사용하여 메모리 효율적인 리스트 렌더링
    return ListView.builder(
      // shrinkWrap: true와 NeverScrollableScrollPhysics를 제거합니다.
      // 이제 부모인 Expanded가 준 크기 내에서 스크롤이 발생합니다.
      padding: const EdgeInsets.only(bottom: 100), // 마지막 카드가 FAB에 가리지 않게 여백 추가
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return ChallengeCard(challenge: challenges[index]);
      },
    );
  }
}

// 함수의 용도: 챌린지 데이터가 없을 때 표시할 안내 컨테이너를 생성함
// 반환 값: Padding 위젯
Widget _buildEmptyState() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.disable,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '+ 아이콘을 눌러 챌린지를 추가하거나\n'
        '피드에서 도전할 챌린지를 찾아보세요!',
        style: AppTypography.b1,
      ),
    ),
  );
}

// 작성자: Gemini
// 클래스 용도: 세로 점선을 그리기 위한 커스텀 페인터
class VerticalDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    // 캔버스의 중앙 X축 계산
    final double centerX = size.width / 2;
    final paint = Paint()
      ..color = AppColors
          .gray3 // 점선 색상 농도 조절
      ..strokeWidth = 1;

    while (startY < size.height) {
      // Offset의 X좌표를 centerX로 고정하여 직선도 유지
      canvas.drawLine(
        Offset(centerX, startY),
        Offset(centerX, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 작성자: Gemini
// 클래스 용도: 상세 요구사항(아이콘 위치, 점선, 조건별 문구, 연속 인증 불꽃)이 반영된 챌린지 카드
class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge; // Challenge -> ChallengeModel 변경

  ChallengeCard({super.key, required this.challenge});

  final Color colorSuccess = AppColors.success;
  final Color colorUrgent = AppColors.warning;
  final Color colorNormal = AppColors.gray5;

  @override
  Widget build(BuildContext context) {
    final status = challenge.getStatus();

    // 터치 이벤트
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeCalendarScreen(
              challengeId: challenge.challengeId, // 필수로 필요한 ID 전달
              challengeTitle: challenge.title, // 상단 앱바에 표시할 타이틀 전달
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: getCardColor(status),
            borderRadius: BorderRadius.circular(12),
          ),
          // 높이를 내부 자식 중 가장 큰 것에 맞춤 (점선 높이 확보용)
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 왼쪽: 정보 영역
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: AppTypography.b1.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 3. 연속 인증 시 불꽃 이모티콘 추가
                      buildSuccessDays(),

                      const SizedBox(height: 4),
                      // 2. Urgent 상태 시 경고 문구 분기 처리
                      buildBottomInfo(status),
                    ],
                  ),
                ),

                // 세로 점선
                SizedBox(
                  width: 40,
                  child: Center(
                    // CustomPaint를 중앙에 배치
                    child: CustomPaint(
                      size: const Size(1, double.infinity),
                      painter: VerticalDashPainter(),
                    ),
                  ),
                ),

                // 우측 중간에 위치하는 아이콘
                SizedBox(
                  width: 44, // 고정 영역 확보
                  child: Center(
                    child: buildStatusIcon(status), // 중앙 정렬된 아이콘
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 작성자: Gemini
  // 함수의 용도: 연속 인증 여부에 따라 불꽃 아이콘과 성공 일수 텍스트를 조합하여 반환함
  Widget buildSuccessDays() {
    return Row(
      mainAxisSize: MainAxisSize.min, // 필요한 만큼만 가로 공간 차지
      crossAxisAlignment: CrossAxisAlignment.center, // 아이콘과 글자 높이 맞춤
      children: [
        // 1. 조건부로 불꽃 SVG 위젯 표시 (API 구조에 따라 로직 보완 가능)
        // 현재 API에는 어제 성공 여부가 없으므로 2일 이상 진행 중이면 표시하는 등의 커스텀이 필요할 수 있습니다.
        if (challenge.duringDate >= 2 && challenge.isDoneToday)
          Padding(
            padding: const EdgeInsets.only(right: 4), // 아이콘과 텍스트 사이 간격
            child: SvgPicture.asset(
              'assets/images/icons/small_fire_icon.svg',
              width: 16,
              height: 16,
            ),
          ),

        // 2. 성공 일수 텍스트
        Text(
          '${challenge.duringDate}일째',
          style: AppTypography.b2.copyWith(
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  // 함수의 용도: 하단 정보 영역(그룹 현황 또는 경고 문구) 렌더링
  Widget buildBottomInfo(ChallengeStatus status) {
    if (status == ChallengeStatus.urgent) {
      return const Text(
        '오늘 챌린지를 하지 않으면 실패해요!',
        style: TextStyle(color: AppColors.notification, fontSize: 12),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/icons/mini_success_icon.svg',
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4), // 아이콘과 텍스트 사이 간격
        Text(
          '인증인원 ${challenge.participantNumber}/${challenge.maxParticipantNumber}',
          style: AppTypography.b2.copyWith(
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  // 함수의 용도: 상태별 아이콘 렌더링
  Widget buildStatusIcon(ChallengeStatus status) {
    if (status == ChallengeStatus.completed) {
      return SvgPicture.asset('assets/images/icons/success_icon.svg');
    } else if (status == ChallengeStatus.urgent) {
      return SvgPicture.asset('assets/images/icons/warning_icon.svg');
    }
    return const SizedBox(width: 24); // 일반 상태일 때 공간 유지
  }

  Color getCardColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.completed:
        return colorSuccess;
      case ChallengeStatus.urgent:
        return colorUrgent;
      case ChallengeStatus.normal:
        return colorNormal;
    }
  }
}
