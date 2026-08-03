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
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

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

          // 💡 [핵심 수정] 캘린더 빌더 추가
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, date, events) {
              return Center(
                // 👈 Center로 감싸야 늘어나지 않고 44.62 크기가 유지됩니다.
                child: Container(
                  width: 44.62,
                  height: 44.62,
                  decoration: ShapeDecoration(
                    color: appColors.selected,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${date.day}',
                    style: AppTypography.b1.copyWith(
                      color: appColors.primaryAble, // 해냄-green-primary-able
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            // 오늘 날짜도 정사각형 틀을 유지하고 싶다면 아래를 추가 (선택사항)
            todayBuilder: (context, date, events) {
              return Center(
                child: SizedBox(
                  width: 44.62,
                  height: 44.62,
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: AppTypography.b1.copyWith(
                        color: appColors.blackToWhite,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 상단 헤더 스타일 (디자인 유지)
          headerStyle: HeaderStyle(
            headerPadding: const EdgeInsets.only(top: 0, bottom: 5),
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTypography.h3.copyWith(
              color: appColors.blackToWhite,
            ),
            leftChevronIcon: _buildChevron(
              'assets/images/icons/tab_previous.svg',
              isFirstMonth ? appColors.gray3 : appColors.blackToWhite,
            ),
            rightChevronIcon: _buildChevron(
              'assets/images/icons/tab_next.svg',
              appColors.blackToWhite,
            ),
            leftChevronMargin: const EdgeInsets.only(left: 50),
            rightChevronMargin: const EdgeInsets.only(right: 50),
          ),

          // 날짜 스타일링 (디자인 유지)
          // 날짜 스타일링
          calendarStyle: CalendarStyle(
            // 💡 1. 평일(기본) 날짜 장식
            defaultDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
            ),
            // 💡 2. 주말 날짜 장식
            weekendDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
            ),
            // 💡 3. 비활성화된 날짜 장식 (과거 날짜 등)
            disabledDecoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
            ),

            disabledTextStyle: AppTypography.b1.copyWith(
              color: appColors.gray3,
            ),

            // 오늘 날짜 디자인
            todayDecoration: BoxDecoration(
              //color: Colors.transparent, // 오늘 강조를 빼고 싶다면 투명
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
            ),
            todayTextStyle: AppTypography.b1.copyWith(
              color: appColors.blackToWhite,
            ),

            // 선택된 날짜 디자인
            selectedDecoration: BoxDecoration(
              color: appColors.selected,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
            ),
            selectedTextStyle: AppTypography.b1.copyWith(
              color: appColors.primaryAble,
              fontWeight: FontWeight.bold,
            ),

            defaultTextStyle: AppTypography.b1.copyWith(
              color: appColors.blackToWhite,
            ),
            weekendTextStyle: AppTypography.b1.copyWith(
              color: appColors.blackToWhite,
            ),
            outsideTextStyle: AppTypography.b1.copyWith(color: appColors.gray3),
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
