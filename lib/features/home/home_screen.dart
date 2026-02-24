// // 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 추가
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/create/screens/challenge_create_screen.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/detail/screens/challenge_main_screen.dart';
import 'package:haenaem/features/notification/screens/notificaion_main_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(challengeHomeNotifierProvider);
    final todayStatus = ref.watch(todayTotalStatusProvider);

    DateTime now = DateTime.now();
    DateTime firstDayOfWeek = now.subtract(Duration(days: now.weekday % 7));
    List<DateTime> weekDays = List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: homeDataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('데이터 에러: $err')),
          data: (data) => Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단 바
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(getFormattedDate(), style: AppTypography.h2),
                        const Spacer(),
                        // 알림 배지 (data.notificationNumber 사용)
                        _buildNotificationIcon(
                          context,
                          data.notificationNumber,
                        ),
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/images/icons/dots_vert_icon.svg',
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
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
                          status: isToday
                              ? todayStatus
                              : ChallengeStatus.normal,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 챌린지 리스트 (data.myChallenges 전달)
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ref
                          .read(challengeHomeNotifierProvider.notifier)
                          .refresh(),
                      child: ChallengeListView(
                        challenges:
                            data.myChallenges, // List<Map<String, dynamic>>
                        model: data, // getStatus 호출을 위해 모델 전달
                      ),
                    ),
                  ),
                ],
              ),
              // Floating Action Button
              _buildFAB(context),
            ],
          ),
        ),
      ),
    );
  }

  // 알림 아이콘 빌더
  Widget _buildNotificationIcon(BuildContext context, int count) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationMainScreen(),
              ),
            );
          },
          icon: SvgPicture.asset('assets/images/icons/home_notice_icon.svg'),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 3,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.notification,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: AppTypography.c1.copyWith(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  // FAB 빌더
  Widget _buildFAB(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 30,
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChallengeCreateScreen(),
          ),
        ),
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.green),
      ),
    );
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    return '${now.year}. ${now.month.toString().padLeft(2, '0')}. ${now.day.toString().padLeft(2, '0')}';
  }
}

// 챌린지 리스트 뷰
class ChallengeListView extends StatelessWidget {
  final List<Map<String, dynamic>> challenges;
  final ChallengeMainModel model; // 상태 계산 로직을 쓰기 위해 추가

  const ChallengeListView({
    super.key,
    required this.challenges,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return ChallengeCard(
          challenge: challenges[index],
          status: model.getStatus(index), // 모델의 헬퍼 함수 활용
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.gray5,
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
}

// 챌린지 카드
class ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final ChallengeStatus status;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeMainScreen(
              challengeId: challenge['challengeId'] ?? 0,
              challengeTitle: challenge['title'],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getCardColor(status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge['title'] ?? '',
                        style: AppTypography.b1.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildSuccessDays(),
                      const SizedBox(height: 4),
                      _buildBottomInfo(),
                    ],
                  ),
                ),
                _buildDivider(),
                SizedBox(width: 44, child: Center(child: _buildStatusIcon())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessDays() {
    final during = challenge['duringDate'] ?? 0;
    final isDone = challenge['doIt'] ?? false;
    return Row(
      children: [
        if (during >= 2 && isDone)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: SvgPicture.asset(
              'assets/images/icons/small_fire_icon.svg',
              width: 16,
              height: 16,
            ),
          ),
        Text('$during일째', style: AppTypography.b2.copyWith(fontSize: 14)),
      ],
    );
  }

  Widget _buildBottomInfo() {
    if (status == ChallengeStatus.urgent) {
      return const Text(
        '오늘 챌린지를 하지 않으면 실패해요!',
        style: TextStyle(color: AppColors.notification, fontSize: 12),
      );
    }
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/icons/mini_success_icon.svg',
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '인증인원 ${challenge['todaySuccessCount']}/${challenge['participantNumber']}',
          style: AppTypography.b2.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return SizedBox(
      width: 40,
      child: Center(
        child: CustomPaint(
          size: const Size(1, double.infinity),
          painter: VerticalDashPainter(),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (status == ChallengeStatus.completed)
      return SvgPicture.asset('assets/images/icons/success_icon.svg');
    if (status == ChallengeStatus.urgent)
      return SvgPicture.asset('assets/images/icons/warning_icon.svg');
    return const SizedBox(width: 24);
  }

  Color _getCardColor(ChallengeStatus status) {
    if (status == ChallengeStatus.completed) return AppColors.success;
    if (status == ChallengeStatus.urgent) return AppColors.warning;
    return AppColors.gray5;
  }
}

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

    // 테두리 결정 로직: 오늘(isSelected)이면서 실패 위기(urgent)가 아닐 때만 테두리 생성
    final bool showBorder = isSelected && status != ChallengeStatus.urgent;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.b1.copyWith(color: AppColors.black)),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            // 💡 제공된 코드의 패딩 반영
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: ShapeDecoration(
              // 💡 배경색: 오늘이 아니면 연회색, 오늘이면 상태에 따른 색상
              color: getBackgroundColor(),
              shape: RoundedRectangleBorder(
                // 💡 오늘 날짜일 때만 테두리(Outside) 적용
                side: showBorder
                    ? const BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignOutside,
                        color: gray2,
                      )
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              day,
              style: TextStyle(
                color: isSelected && status != ChallengeStatus.normal
                    ? Colors.white
                    : gray2,
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getBackgroundColor() {
    if (!isSelected) return AppColors.gray5;

    // 💡 오늘일 경우: 상태에 따른 강조색
    switch (status) {
      case ChallengeStatus.urgent:
        return AppColors.notification; // 실패 위기 (빨강)
      case ChallengeStatus.completed:
        return AppColors.primaryAble; // 완료 (초록)
      case ChallengeStatus.normal:
      default:
        return AppColors.gray5; // 미완료 상태인 오늘 (회색)
    }
  }
}
