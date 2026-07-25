import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 추가
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/create/screens/challenge_create_screen.dart';
import '../../../shared/provider/home_provider.dart';
import 'package:haenaem/features/notification/screens/notification_main_screen.dart';
import 'package:haenaem/features/notification/provider/notification_provider.dart';
import 'package:haenaem/shared/models/home_challenge_card.dart';
import '../widgets/challenge_card.dart';
import '../widgets/day_chip.dart';
import 'package:haenaem/features/home/models/home_response.dart';

// 최초 작성자 : 강선욱
// 홈 화면 빌드 클래스
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeNotifierProvider);

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
          data: (data) {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 상단 바
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32,
                        right: 20,
                        top: 12,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Text(getFormattedDate(), style: AppTypography.h2),
                          const Spacer(),
                          // 알림 배지 (data.notificationNumber 사용)
                          _buildNotificationIcon(
                            context,
                            ref,
                            data.notificationNumber,
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
                          // 1. 날짜를 API와 동일한 포맷 'yyyy-MM-dd'로 변환
                          final dateString =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

                          // 2. weekStatus 배열에서 해당 날짜와 일치하는 상태 찾기
                          final matchedStatus = data.weekStatus
                              .firstWhere(
                                (ws) => ws.date == dateString,
                                orElse: () => const WeekStatus(
                                  date: '',
                                  status: 'GRAY',
                                ), // 없으면 기본값
                              )
                              .status;

                          debugPrint(
                            '📅 [Calendar Match] 날짜: $dateString | 오늘여부: $isToday | 부여된 상태: $matchedStatus',
                          );

                          return DayChip(
                            date: date,
                            isSelected: isToday,
                            status: matchedStatus, // 새로 받아온 상태값 전달
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 챌린지 리스트 (data.myChallenges 전달)
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () =>
                            ref.read(homeNotifierProvider.notifier).refresh(),
                        child: ChallengeListView(
                          challenges:
                              data.myChallenges, // getStatus 호출을 위해 모델 전달
                        ),
                      ),
                    ),
                  ],
                ),
                // Floating Action Button
                _buildFAB(context),
              ],
            );
          },
        ),
      ),
    );
  }

  // 알림 아이콘 빌더
  Widget _buildNotificationIcon(
    BuildContext context,
    WidgetRef ref,
    int count,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () async {
            // 💡 1. 들어가기 전에 뱃지 숫자를 확인합니다.
            // 0보다 크다면, 서버에서 '읽음' 처리될 것이 100% 확실하므로 새로고침을 예약해 둡니다.
            final hasUnreadInitially = count > 0;

            // 💡 2. await를 붙여서 알림 페이지(NotificationMainScreen)가 닫힐 때까지 기다립니다.
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationMainScreen(),
              ),
            );

            // 💡 3. 알림 페이지에서 뒤로가기(pop)를 눌러서 홈으로 돌아온 직후 실행됩니다!
            // 홈 화면 전체 데이터를 새로고침(refresh) 하여 뱃지 개수와 챌린지 목록을 최신화합니다.
            if (context.mounted) {
              // 💡 알림 페이지 안에서 '수락'이나 '거절'을 눌렀는지 확인
              final hasActionOccurred = ref.read(needsHomeRefreshProvider);

              // 처음 들어갈 때 안 읽은 알림이 있었거나 OR 안에서 챌린지 수락/거절을 했다면 새로고침!
              if (hasUnreadInitially || hasActionOccurred) {
                ref.read(homeNotifierProvider.notifier).refresh();

                // 스위치는 다시 꺼줍니다
                ref.read(needsHomeRefreshProvider.notifier).state = false;
              }
            }
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
  final List<HomeChallengeCard> challenges;

  const ChallengeListView({super.key, required this.challenges});

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return ChallengeCard(challenge: challenges[index]);
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
