// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter/cupertino.dart';

// 챌린지 알림 설정 다이얼로그
class NotificationSettingsDialog extends StatefulWidget {
  const NotificationSettingsDialog({super.key});

  @override
  State<NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends State<NotificationSettingsDialog> {
  // 스위치 상태 변수들
  bool allNotifications = true;
  bool dailyReminder = true;
  bool mateReaction = true;
  bool mateVerification = true;
  String selectedTime = "오후 9시";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. 헤더 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(width: 1, color: AppColors.gray4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '알림 설정',
                  style: AppTypography.h3.copyWith(color: AppColors.black),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      'assets/images/icons/close_icon.svg',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. 설정 리스트 및 버튼 영역
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                _buildSwitchRow(
                  "전체 알림",
                  "모든 알림 받기",
                  allNotifications,
                  (val) => setState(() {
                    allNotifications = val;
                    dailyReminder = val;
                    mateReaction = val;
                    mateVerification = val;
                  }),
                ),
                _buildDailyReminderSection(),
                _buildSwitchRow(
                  "메이트 반응 소식",
                  "다른 참여자들이 내 인증글에 반응 시 알림",
                  mateReaction,
                  (val) => setState(() {
                    mateReaction = val;
                    if (!val) {
                      allNotifications = false;
                    } else if (dailyReminder && mateVerification) {
                      allNotifications = true;
                    }
                  }),
                ),
                _buildSwitchRow(
                  "메이트 인증 소식",
                  "다른 참여자들이 인증 완료 시 알림",
                  mateVerification,
                  (val) => setState(() {
                    mateVerification = val;
                    if (!val) {
                      allNotifications = false;
                    } else if (dailyReminder && mateReaction) {
                      allNotifications = true;
                    }
                  }),
                ),
                const SizedBox(height: 24),

                // 완료 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAble,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool>? onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.b1.copyWith(color: AppColors.black),
                ),
                Text(
                  subtitle,
                  style: AppTypography.b2.copyWith(color: AppColors.gray2),
                ),
              ],
            ),
          ),

          // 스위치 영역: 이미지와 동일한 초록색 테마 적용
          Transform.scale(
            scale: 0.8,
            alignment: Alignment.centerRight,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.primaryAble,
              activeThumbColor: Colors.white,
              inactiveTrackColor: AppColors.disable, // 이미지와 유사한 연회색
              inactiveThumbColor: Colors.white,

              // 테두리 제거
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),

              // 비활성화 시에도 버튼 크기가 작아지지 않도록 설정
              thumbIcon: WidgetStateProperty.all(
                const Icon(null),
              ), // 아이콘 공간 강제 확보
              thumbColor: const WidgetStatePropertyAll(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 상단 스위치 행
        _buildSwitchRow(
          "일일 리마인더",
          "매일 $selectedTime 알림",
          dailyReminder,
          (val) => setState(() {
            dailyReminder = val;
            if (!val) {
              allNotifications = false;
            } else if (mateReaction && mateVerification) {
              allNotifications = true;
            }
          }),
        ),

        // 2. 리마인더가 활성화되었을 때만 드롭다운 표시
        if (dailyReminder && allNotifications)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: GestureDetector(
              onTap: () => _showTimePicker(context), // 터치 시 피커 호출
              child: Container(
                width: double.infinity,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.gray5,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedTime, style: AppTypography.b2),
                    SvgPicture.asset(
                      'assets/images/icons/big_down_arrow.svg',
                      colorFilter: const ColorFilter.mode(
                        AppColors.gray2,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showTimePicker(BuildContext context) {
    final List<String> hours = List.generate(12, (i) => "${i + 1}시");
    String currentPeriod = selectedTime.contains("오후") ? "오후" : "오전";
    String currentHour = selectedTime.split(' ').last;
    int initialHourIndex = hours.indexOf(currentHour);
    if (initialHourIndex == -1) initialHourIndex = 8;

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(100), // 기존 투명도 유지
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 다이얼로그 전체 곡률 유지
          ),
          actionsAlignment: MainAxisAlignment.center,
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            0,
          ), // 하단 여백 제거하여 버튼 밀착
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. 오전/오후 선택용 애니메이션 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildAnimatedPeriodSelector(
                    currentPeriod,
                    (newPeriod) =>
                        setDialogState(() => currentPeriod = newPeriod),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. 시간 선택 휠
                SizedBox(
                  height: 150, // 휠의 높이를 원하는 만큼 고정 (너무 늘어나지 않음)
                  child: Stack(
                    children: [
                      // 중앙 하이라이트 바
                      Center(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.gray4.withAlpha(100),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: initialHourIndex,
                        ),
                        onSelectedItemChanged: (index) =>
                            setDialogState(() => currentHour = hours[index]),
                        selectionOverlay: const SizedBox.shrink(),
                        children: hours
                            .map(
                              (h) => Center(
                                child: Text(h, style: AppTypography.b1),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ), // 하단과 좌우 여백 설정
                  child: TextButton(
                    onPressed: () {
                      setState(
                        () => selectedTime = "$currentPeriod $currentHour",
                      );
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.primaryAble,
                      minimumSize: const Size(double.infinity, 52),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "완료",
                      style: AppTypography.b1.copyWith(
                        color: AppColors.primaryAble,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPeriodSelector(
    String currentPeriod,
    Function(String) onPeriodChanged,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4), // 테두리와 내부 버튼 사이의 여백
      decoration: BoxDecoration(
        color: AppColors.gray4, // 배경색 (이미지 b77188의 연회색)
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 전체 너비의 절반에서 패딩(4)을 뺀 값이 움직이는 배경의 너비가 됩니다.
          double width = constraints.maxWidth / 2;

          return Stack(
            children: [
              // 1. 배경에서 움직이는 흰색 하이라이트 박스
              AnimatedAlign(
                duration: const Duration(milliseconds: 250), // 애니메이션 속도
                curve: Curves.easeInOut, // 부드러운 가속도 곡선
                alignment: currentPeriod == "오전"
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: width - 4, // 좌우 여백을 고려한 너비
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20), // 미세한 그림자 효과
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. 상단 텍스트 레이어 (오전, 오후)
              Row(
                children: ["오전", "오후"].map((p) {
                  bool isSelected = currentPeriod == p;
                  return Expanded(
                    child: GestureDetector(
                      // 투명한 영역을 클릭해도 인식되도록 설정
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onPeriodChanged(p),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: AppTypography.b2.copyWith(
                            color: isSelected ? Colors.black : AppColors.gray2,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          child: Text(p),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
