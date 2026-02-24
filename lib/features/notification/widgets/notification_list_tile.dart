// 최초 작성자: 정승빈
// '모두' 탭의 개별 알림 항목 (읽음/안읽음 배경색 처리)
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum NotiIconType { normal, success, fail, profile }

class NotificationListTile extends StatelessWidget {
  final String message;
  final bool isRead;
  final NotiIconType iconType;
  final String? profileImageUrl;

  const NotificationListTile({
    super.key,
    required this.message,
    this.isRead = true,
    this.iconType = NotiIconType.normal,
    this.profileImageUrl,
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
              style: AppTypography.b1.copyWith(color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }

  // 아이콘 또는 프로필 이미지 렌더링 영역
  Widget _buildIconBox() {
    // 1. 프로필 타입일 경우 (친구 페이지 로직 적용)
    if (iconType == NotiIconType.profile) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.gray5,
          shape: BoxShape.circle,
          image: profileImageUrl != null && profileImageUrl!.startsWith('http')
              ? DecorationImage(
                  image: NetworkImage(profileImageUrl!),
                  fit: BoxFit.cover,
                )
              : (profileImageUrl != null
                    ? DecorationImage(
                        image: AssetImage(profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null),
        ),
        child: profileImageUrl == null
            ? Center(
                child: SvgPicture.asset(
                  'assets/images/icons/default_profile_icon.svg',
                  width: 40,
                ),
              )
            : null,
      );
    }

    // 2. 시스템 알림 (성공, 실패, 일반) 로직
    Color bgColor = AppColors.gray5;
    Widget iconWidget = const Icon(
      Icons.eco,
      color: Colors.white,
      size: 20,
    ); // 임시 일반 아이콘

    if (iconType == NotiIconType.success) {
      bgColor = AppColors.blue;
      iconWidget = const Icon(Icons.star, color: Colors.white, size: 20);
    } else if (iconType == NotiIconType.fail) {
      bgColor = AppColors.notification;
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
