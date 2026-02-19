// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:haenaem/shared/widgets/custom_bottom_sheet.dart';

// 챌린지 시작일을 선택하기 위한 달력 바텀시트
class ChallengeCalendarBottomSheet extends StatefulWidget {
  final DateTime initialFocusedDay;
  final DateTime? initialSelectedDay;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const ChallengeCalendarBottomSheet({
    super.key,
    required this.initialFocusedDay,
    this.initialSelectedDay,
    required this.onDaySelected,
  });

  @override
  State<ChallengeCalendarBottomSheet> createState() =>
      _ChallengeCalendarBottomSheetState();
}

class _ChallengeCalendarBottomSheetState
    extends State<ChallengeCalendarBottomSheet> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay;
    _selectedDay = widget.initialSelectedDay;
  }

  @override
  Widget build(BuildContext context) {
    bool isFirstMonth =
        _focusedDay.year == _today.year && _focusedDay.month == _today.month;

    return CustomBottomSheet(
      title: "챌린지 시작일",
      heightFactor: 0.59,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime(_today.year, _today.month, 1),
          lastDay: DateTime(_today.year + 5, 12, 31),
          focusedDay: _focusedDay,
          rowHeight: 45,
          daysOfWeekHeight: 33,

          // 상단 헤더 스타일 (디자인 유지)
          headerStyle: HeaderStyle(
            headerPadding: const EdgeInsets.only(top: 0, bottom: 5),
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTypography.h3.copyWith(color: AppColors.black),
            leftChevronIcon: _buildChevron(
              'assets/images/icons/tab_previous.svg',
              isFirstMonth ? AppColors.gray3 : AppColors.black,
            ),
            rightChevronIcon: _buildChevron(
              'assets/images/icons/tab_next.svg',
              AppColors.black,
            ),
            leftChevronMargin: const EdgeInsets.only(left: 50),
            rightChevronMargin: const EdgeInsets.only(right: 50),
          ),

          // 날짜 스타일링 (디자인 유지)
          calendarStyle: CalendarStyle(
            disabledTextStyle: AppTypography.b1.copyWith(
              color: AppColors.gray3,
            ),
            todayDecoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.rectangle,
            ),
            todayTextStyle: AppTypography.b1.copyWith(color: AppColors.black),
            selectedDecoration: BoxDecoration(
              color: AppColors.selected,
              borderRadius: BorderRadius.circular(8),
            ),
            selectedTextStyle: AppTypography.b1.copyWith(
              color: AppColors.primaryAble,
            ),
            defaultTextStyle: AppTypography.b1.copyWith(color: AppColors.black),
            weekendTextStyle: AppTypography.b1.copyWith(color: AppColors.black),
            outsideTextStyle: AppTypography.b1.copyWith(color: AppColors.gray3),
          ),

          // 과거 날짜 선택 차단
          enabledDayPredicate: (day) =>
              !day.isBefore(DateTime(_today.year, _today.month, _today.day)),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

          onPageChanged: (focusedDay) =>
              setState(() => _focusedDay = focusedDay),

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            // 💡 부모에게 선택된 날짜 전달
            widget.onDaySelected(selectedDay, focusedDay);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildChevron(String path, Color color) {
    return SvgPicture.asset(
      path,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
