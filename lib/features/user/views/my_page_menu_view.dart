// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../screens/settings/push_notification_settings_screen.dart'; // 4단계에서 경로 수정 예정
import '../screens/settings/withdrawal_screen.dart'; // 4단계에서 경로 수정 예정
import '../widgets/my_page_menu_item.dart';
// import '../widgets/logout_dialog.dart';
import 'package:haenaem/shared/widgets/select_dialog.dart';
import 'package:haenaem/main.dart';
import 'package:haenaem/features/notification/services/fcm_service.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';
import 'package:haenaem/features/auth/signup/screens/auth_gate.dart';

class MyPageMenuView extends ConsumerWidget {
  const MyPageMenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onTap: () async {
            final bool? shouldLogout = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => SelectDialog(
                title: '로그아웃',
                content: '로그아웃 하시겠습니까?',
                cancelText: '취소',
                confirmText: '로그아웃',
                onCancel: () => Navigator.of(context).pop(false),
                onConfirm: () async {
                  try {
                    try {
                      await ref.read(fcmServiceProvider).deleteFcmToken();
                    } catch (e) {
                      debugPrint('FCM 토큰 삭제 실패 (로그아웃은 계속 진행): $e');
                    }

                    await AuthService.logout();

                    if (context.mounted) {
                      AppRoot.restart(context);
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const AuthGate(),
                        ),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    debugPrint('로그아웃 처리 중 치명적 오류 발생: $e');
                  }
                },
              ),
            );

            if (shouldLogout == true) {
              try {
                // FCM 토큰 삭제 (이제 ref를 정상적으로 인식합니다!)
                try {
                  await ref.read(fcmServiceProvider).deleteFcmToken();
                } catch (e) {
                  debugPrint('FCM 토큰 삭제 실패 (로그아웃은 계속 진행): $e');
                }

                // 로그아웃 API 호출 및 로컬 데이터 삭제
                await AuthService.logout();

                // 안전하게 전역 앱 루트 초기화 및 AuthGate로 전환 (AppRoot 임포트 완료!)
                if (context.mounted) {
                  // AppRoot.restart(context);

                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthGate()),
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint('로그아웃 처리 중 치명적 오류 발생: $e');
              }
            }
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
