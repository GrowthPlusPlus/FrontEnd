// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/widgets/DeleteConfirmDialog.dart';

class ChallengeFeedPopupMenu extends StatelessWidget {
  const ChallengeFeedPopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      popUpAnimationStyle: const AnimationStyle(
        duration: Duration.zero,
        reverseDuration: Duration.zero,
      ),
      icon: SvgPicture.asset(
        'assets/images/icons/dots_vert_icon.svg',
        width: 24,
        height: 24,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.gray4, width: 1),
      ),
      offset: const Offset(0, 40),

      // 아이템 빌더에서 조건부 리스트 생성
      itemBuilder: (BuildContext context) {
        return [
          _buildPopupItem('수정하기', 'assets/images/icons/edit_icon.svg', 'edit'),
          const PopupMenuDivider(height: 1),
          _buildPopupItem(
            '삭제하기',
            'assets/images/icons/small_trash_icon.svg',
            'delete',
            isDanger: true,
          ),
        ];
      },

      onSelected: (String value) => _handleMenuSelection(context, value),
    );
  }

  // 메뉴 아이템 위젯 생성 헬퍼
  PopupMenuItem<String> _buildPopupItem(
    String title,
    String iconPath,
    String value, {
    bool isDanger = false,
  }) {
    final Color itemColor = isDanger ? AppColors.notification : AppColors.black;

    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTypography.b2.copyWith(
              color: itemColor, // 텍스트 색상 변경
            ),
          ),
          const SizedBox(width: 25),
        ],
      ),
    );
  }

  // 메뉴 선택 핸들러
  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        // 수정하기 로직 호출
        break;
      case 'delete':
        // 삭제하기 컨펌 다이얼로그
        showDialog<bool>(
          context: context,
          barrierDismissible: false, // 배경 클릭 시 닫힘 방지 (선택 사항)
          builder: (context) => const DeleteConfirmDialog(),
        ).then((confirmed) {
          // 다이얼로그에서 '삭제하기'를 눌러 true가 반환된 경우
          if (confirmed == true) {
            print("삭제 완료");
          }
        });
        break;
    }
  }
}
