// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

import 'package:haenaem/main.dart';
import 'package:haenaem/features/notification/services/fcm_service.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';
import 'package:haenaem/features/auth/signup/screens/auth_gate.dart';
import 'package:haenaem/features/notification/provider/push_notification_provider.dart';

class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 335,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(
              '로그아웃',
              style: AppTypography.h2.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '로그아웃 하시겠습니까?',
              style: AppTypography.b1.copyWith(color: AppColors.gray2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDialogButton(
                    context: context,
                    text: '취소',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDialogButton(
                    context: context,
                    text: '확인',
                    onTap: () async {
                      // 1. 다이얼로그 먼저 닫기 (선택 사항이지만 안전한 흐름을 위해 유지)
                      // Navigator.pop(context);

                      // 2. FCM 토큰 삭제 (알림 방지)
                      try {
                        await ref.read(fcmServiceProvider).deleteFcmToken();
                      } catch (e) {
                        debugPrint('FCM 토큰 삭제 실패 (로그아웃은 계속 진행): $e');
                      }

                      // 3. 로그아웃 API 호출 및 로컬 데이터 삭제
                      await AuthService.logout();

                      // 4. 화면 이동 (context가 유효한지 확인 후 실행)
                      if (context.mounted) {
                        AppRoot.restart(
                          context,
                        ); // ref.invalidate(pushNotificationProvider) 등을 전부 대체

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
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 다이얼로그 내 공통 버튼 빌드용 내부 위젯
  Widget _buildDialogButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDFE1DC).withAlpha(127),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTypography.b1.copyWith(
              color: AppColors.gray2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
