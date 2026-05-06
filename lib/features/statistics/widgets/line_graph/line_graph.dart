// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/line_graph_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../statistics_card.dart';
import 'monthly_line_graph.dart';
import 'weekly_line_graph.dart';

// 나의 해냄 추이 꺾은선 그래프
class LineGraph extends ConsumerWidget {
  final bool isMonthly; // 현재 월간/주간 선택 상태
  final VoidCallback? onToggle; // 탭 전환 시 호출될 콜백 (상태 관리용)

  const LineGraph({
    super.key,
    this.isMonthly = true, // 기본값 월간
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 상태를 감시하여 상태가 바뀔 때마다 위젯이 다시 그려짐
    final isMonthly = ref.watch(graphTypeProvider);
    return StatisticsCard(
      title: "나의 해냄 추이",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              // 월간/주간 토글 버튼 영역
              _buildToggleButtons(ref, isMonthly), // ref와 isMonthly 전달
              const SizedBox(height: 20), // 버튼과 그래프 사이 간격
              // 범례 영역 (이번 달/주, 저번 달/주)
              _buildLegend(isMonthly),

              // ✅ 그래프 전환 로직 적용
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  key: ValueKey<bool>(isMonthly),
                  height: 184,
                  width: double.infinity,
                  child: const MonthlyLineGraph(
                    data: WeeklyGraphData(
                      thisMonth: [28, 15, 20, 25],
                      lastMonth: [10, 22, 17, 12],
                    ),
                  ),
                  // : const WeeklyLineGraph(
                  //     // ✅ 주간 그래프 추가
                  //     data: DailyGraphData(
                  //       thisWeek: [3, 5, 2, 8, 4, 6, 7],
                  //       lastWeek: [2, 4, 3, 5, 3, 5, 4],
                  //     ),
                  //   ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 범례 빌더: 상태에 따라 텍스트 변경
  Widget _buildLegend(bool isMonthly) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8, // 두 범례 사이의 간격
      children: [
        _buildLegendItem(
          iconPath: 'assets/images/icons/green_line_graph_icon.svg',
          label: isMonthly ? '이번 달' : '이번 주',
        ),
        _buildLegendItem(
          iconPath: 'assets/images/icons/gray_line_graph_icon.svg',
          label: isMonthly ? '저번 달' : '저번 주',
        ),
      ],
    );
  }

  // 범례 개별 아이템
  Widget _buildLegendItem({required String iconPath, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4, // 아이콘과 텍스트 사이 간격
      children: [
        SvgPicture.asset(iconPath, width: 16, height: 16),
        Text(
          label,
          style: AppTypography.b2.copyWith(
            color: AppColors.gray1,
          ), // 디자인의 apptypography가 프리텐다드가 아니라서 임시로 지정
        ),
      ],
    );
  }

  // 월간/주간 선택 버튼
  Widget _buildToggleButtons(WidgetRef ref, bool isMonthly) {
    return Container(
      width: double.infinity,
      height: 35.99,
      decoration: ShapeDecoration(
        color: AppColors.gray5, // 기본 배경
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      child: Row(
        children: [
          _buildTab(
            ref: ref,
            label: '월간',
            isSelected: isMonthly,
            onTap: () => ref.read(graphTypeProvider.notifier).state = true,
          ),
          _buildTab(
            ref: ref,
            label: '주간',
            isSelected: !isMonthly,
            onTap: () => ref.read(graphTypeProvider.notifier).state = false,
          ),
        ],
      ),
    );
  }

  // 개별 탭 버튼 구현
  Widget _buildTab({
    required WidgetRef ref,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap, // 탭 클릭 시 동작
        behavior: HitTestBehavior.opaque, // 빈 공간 클릭도 인식
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            // 선택 시 배경색 적용, 미선택 시 투명
            color: isSelected ? AppColors.primaryAble : Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.b2.copyWith(
              // 선택 시 흰색, 미선택 시 검은색
              color: isSelected ? Colors.white : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
