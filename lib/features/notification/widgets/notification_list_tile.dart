// '모두' 탭의 개별 알림 항목 (읽음/안읽음 배경색 처리)
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

// 임시 아이콘 타입을 위한 enum
enum NotiIconType { normal, success, fail }

class NotificationListTile extends StatelessWidget {
  final String message;
  final bool isRead;
  final NotiIconType iconType;

  const NotificationListTile({
    super.key,
    required this.message,
    this.isRead = true,
    this.iconType = NotiIconType.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      // isRead 값에 따라 배경색 분기 처리
      color: isRead ? Colors.white : AppColors.selected,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIconBox(),
          const SizedBox(width: 16),
          // 긴 텍스트가 화면을 넘어갈 때 줄바꿈되도록 Expanded 사용
          Expanded(
            child: Text(
              message,
              style: AppTypography.b2.copyWith(color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }

  // 아이콘 렌더링 영역 (추후 실제 에셋으로 변경)
  Widget _buildIconBox() {
    Color bgColor = AppColors.gray5; // 기본 회색 배경
    Widget iconWidget = const Icon(
      Icons.eco,
      color: Colors.white,
      size: 20,
    ); // 임시 아이콘

    if (iconType == NotiIconType.success) {
      bgColor = AppColors.blue; // 1월 2일 성공 아이콘 느낌
      iconWidget = const Icon(Icons.star, color: Colors.white, size: 20);
    } else if (iconType == NotiIconType.fail) {
      bgColor = AppColors.notification; // 빨간 X 마크 느낌
      iconWidget = const Icon(Icons.close, color: Colors.white, size: 20);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(child: iconWidget),
    );
  }
}
