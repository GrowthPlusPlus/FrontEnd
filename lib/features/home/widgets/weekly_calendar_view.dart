import 'package:flutter/material.dart';
import 'package:haenaem/features/home/models/home_response.dart';
import 'day_chip.dart';

// 최초 작성자: 강선욱
// 슬라이드 주간 캘린더 위젯

class WeeklyCalendarView extends StatefulWidget {
  final List<WeekStatus> weekStatusList;

  const WeeklyCalendarView({super.key, required this.weekStatusList});

  @override
  State<WeeklyCalendarView> createState() => _WeeklyCalendarViewState();
}

class _WeeklyCalendarViewState extends State<WeeklyCalendarView> {
  late PageController _pageController;
  late List<List<DateTime>> _weeksInMonth;

  @override
  void initState() {
    super.initState();
    _weeksInMonth = _generateWeeksFromMonthStartToCurrent();
    // 마지막 주차(이번 주)를 초기 페이지로 선택
    _pageController = PageController(
      initialPage: _weeksInMonth.isNotEmpty ? _weeksInMonth.length - 1 : 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 이달 1일부터 이번 주까지 주차별 7일 날짜 리스트 생성
  List<List<DateTime>> _generateWeeksFromMonthStartToCurrent() {
    DateTime now = DateTime.now();
    DateTime firstDayOfCurrentMonth = DateTime(now.year, now.month, 1);

    // 이달 1일이 속한 주의 일요일
    DateTime startOfFirstWeek = firstDayOfCurrentMonth.subtract(
      Duration(days: firstDayOfCurrentMonth.weekday - 1),
    );

    // 오늘이 속한 주의 일요일
    DateTime startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1));

    List<List<DateTime>> weeks = [];
    DateTime currentWeekStart = startOfFirstWeek;

    while (!currentWeekStart.isAfter(startOfCurrentWeek)) {
      List<DateTime> week = List.generate(
        7,
        (index) => currentWeekStart.add(Duration(days: index)),
      );
      weeks.add(week);
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }

    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return SizedBox(
      height: 72,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _weeksInMonth.length,
        itemBuilder: (context, pageIndex) {
          final weekDays = _weeksInMonth[pageIndex];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: weekDays.map((date) {
                final isToday =
                    date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;

                final dateString =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

                final matchedStatus = widget.weekStatusList
                    .firstWhere(
                      (ws) => ws.date == dateString,
                      orElse: () => const WeekStatus(date: '', status: 'GRAY'),
                    )
                    .status;

                return DayChip(
                  date: date,
                  isSelected: isToday,
                  status: matchedStatus,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
