// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class DelegateDialog extends StatefulWidget {
  const DelegateDialog({super.key});

  @override
  State<DelegateDialog> createState() => _DelegateDialogState();
}

class _DelegateDialogState extends State<DelegateDialog> {
  // 선택된 멤버를 저장 (null이면 미선택 상태)
  String? selectedMember;

  @override
  Widget build(BuildContext context) {
    // 멤버 선택 여부에 따른 활성화 상태 체크
    bool isActivated = selectedMember != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- 헤더 섹션 ---
            _buildHeader(),
            const SizedBox(height: 20),

            // --- 멤버 선택 섹션 ---
            _buildMemberSelector(),
            const SizedBox(height: 20),

            // --- 하단 버튼 섹션 ---
            _buildActionButtons(context, isActivated),
          ],
        ),
      ),
    );
  }

  // 다이얼로그 제목 및 설명
  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Text(
          '챌린지장 위임',
          textAlign: TextAlign.center,
          style: AppTypography.h3.copyWith(
            color: AppColors.black,
          ), // 20pt, SemiBold
        ),
        const SizedBox(height: 8),
        Text(
          '챌린지장 권한을 넘길 멤버를 선택해주세요',
          textAlign: TextAlign.center,
          style: AppTypography.b1.copyWith(color: AppColors.gray2),
        ),
      ],
    );
  }

  // 멤버 선택 박스
  Widget _buildMemberSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '위임할 멤버',
          style: AppTypography.b1.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // TODO: 멤버 리스트 시트나 팝업 호출 로직
            // 여기서는 테스트를 위해 클릭 시 임의의 멤버가 선택되도록 함
            setState(() {
              selectedMember = "성장하는 개발자";
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: ShapeDecoration(
              color: AppColors.gray5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMember ?? '멤버를 선택하세요',
                  style: AppTypography.b2.copyWith(
                    color: selectedMember == null
                        ? AppColors.gray2
                        : AppColors.black,
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/icons/big_down_arrow.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray2,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 취소 및 위임 버튼
  Widget _buildActionButtons(BuildContext context, bool isActivated) {
    return Row(
      children: [
        // 취소 버튼
        Expanded(
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: ShapeDecoration(
                color: AppColors.gray5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  '취소',
                  style: AppTypography.b1.copyWith(color: AppColors.gray2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // 위임 후 나가기 버튼
        Expanded(
          child: InkWell(
            onTap: isActivated
                ? () {
                    // TODO: 위임 API 호출 및 나가기 로직
                    Navigator.pop(context, true);
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: ShapeDecoration(
                // 활성화 여부에 따라 색상 변경
                color: isActivated
                    ? AppColors.notification
                    : const Color(0xFFDBAEAD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  '위임 후 나가기',
                  style: AppTypography.b1.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
