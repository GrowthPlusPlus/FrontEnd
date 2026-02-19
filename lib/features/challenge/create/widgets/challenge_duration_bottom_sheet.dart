// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/widgets/custom_bottom_sheet.dart';

// 챌린지 인증 기간(7일, 30일 등 또는 직접 입력)을 선택하는 바텀시트
class ChallengeDurationBottomSheet extends StatefulWidget {
  final String? initialDuration;
  final Function(String duration) onDurationSelected;

  const ChallengeDurationBottomSheet({
    super.key,
    this.initialDuration,
    required this.onDurationSelected,
  });

  @override
  State<ChallengeDurationBottomSheet> createState() =>
      _ChallengeDurationBottomSheetState();
}

class _ChallengeDurationBottomSheetState
    extends State<ChallengeDurationBottomSheet> {
  bool isCustomMode = false;
  bool isButtonEnabled = false;
  late TextEditingController customController;
  String? _tempSelectedDuration;

  @override
  void initState() {
    super.initState();
    customController = TextEditingController();
    _tempSelectedDuration = widget.initialDuration;

    // 초기값이 리스트에 없는 '일' 단위라면 직접 입력 모드로 시작
    if (widget.initialDuration != null &&
        ![
          "7일",
          "30일",
          "50일",
          "100일",
          "365일",
        ].contains(widget.initialDuration)) {
      isCustomMode = true;
      customController.text = widget.initialDuration!.replaceAll('일', '');
      isButtonEnabled = true;
    }
  }

  @override
  void dispose() {
    customController.dispose();
    super.dispose();
  }

  void _validate(String text) {
    final val = int.tryParse(text);
    setState(() {
      isButtonEnabled = val != null && val >= 1 && val <= 365;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      title: "인증 기간 선택",
      heightFactor: isCustomMode ? 0.80 : 0.55,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 기본 기간 리스트
            ...["7일", "30일", "50일", "100일", "365일"].map((item) {
              return _buildListItem(
                label: item,
                isSelected: _tempSelectedDuration == item && !isCustomMode,
                onTap: () {
                  setState(() => _tempSelectedDuration = item);
                  widget.onDurationSelected(item);
                  Navigator.pop(context);
                },
              );
            }),

            // 2. 직접 입력 섹션
            Container(
              width: double.infinity,
              color: isCustomMode ? AppColors.selected : Colors.transparent,
              child: Column(
                children: [
                  _buildListItem(
                    label: "직접 입력",
                    isSelected: isCustomMode,
                    onTap: () => setState(() => isCustomMode = true),
                  ),
                  if (isCustomMode) _buildCustomInputForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 직접 입력 폼 위젯
  Widget _buildCustomInputForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• 1일 이상의 기간을 입력해주세요\n• 1~365일까지 설정할 수 있습니다.',
            style: AppTypography.b2.copyWith(
              color: AppColors.gray2,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '인증 기간 (일)',
            style: AppTypography.c1.copyWith(color: AppColors.gray2),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.gray3, width: 0.75),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customController,
                    onChanged: _validate,
                    keyboardType: TextInputType.number,
                    style: AppTypography.b1,
                    decoration: InputDecoration(
                      hintText: "숫자를 입력하세요",
                      hintStyle: AppTypography.b1.copyWith(
                        color: AppColors.gray3,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Text(
                  '일',
                  style: AppTypography.b1.copyWith(color: AppColors.gray1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: isButtonEnabled
                ? () {
                    widget.onDurationSelected("${customController.text}일");
                    Navigator.pop(context);
                  }
                : null,
            child: Container(
              width: double.infinity,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isButtonEnabled
                    ? AppColors.primaryAble
                    : AppColors.disable,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '완료',
                style: AppTypography.b1.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 내부 리스트 아이템 빌더
  Widget _buildListItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        color: isSelected ? AppColors.selected : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.b1.copyWith(
            color: isSelected ? AppColors.primaryAble : AppColors.black,
          ),
        ),
      ),
    );
  }
}
