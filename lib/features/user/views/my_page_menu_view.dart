// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../screens/push_notification_settings_screen.dart'; // 4단계에서 경로 수정 예정
import '../screens/withdrawal_screen.dart'; // 4단계에서 경로 수정 예정
import '../widgets/my_page_menu_item.dart';
import '../widgets/logout_dialog.dart';

class MyPageMenuView extends StatelessWidget {
  const MyPageMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyPageMenuItem(
          title: '푸시 알림 설정',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PushNotificationSettingsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        MyPageMenuItem(
          title: '로그아웃',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const LogoutDialog(),
            );
          },
        ),
        const SizedBox(height: 10),
        MyPageMenuItem(
          title: '회원 탈퇴',
          textColor: AppColors.notification,
          showArrow: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WithdrawalScreen()),
            );
          },
        ),
      ],
    );
  }
}
