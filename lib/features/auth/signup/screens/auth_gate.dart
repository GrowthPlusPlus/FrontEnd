// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import 'package:haenaem/features/main/screens/main_screen.dart';
import 'package:haenaem/features/auth/login/login_screen.dart';
import 'signup_main_screen.dart';
import 'package:haenaem/features/user/data/user_repository.dart';
import 'package:haenaem/shared/models/user_detail.dart';
import 'package:haenaem/features/user/provider/user_provider.dart';
import 'package:haenaem/features/notification/services/fcm_service.dart';

// 앱을 껐다 켰을 때 저장된 토큰을 확인
// 바로 홈으로 보낼지 로그인으로 보낼지 결정 (자동 로그인)
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: AuthService.getAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 1. 토큰이 있는 경우
        if (snapshot.hasData && snapshot.data != null) {
          // 💡 핵심: 서버에 내 프로필을 물어봐서 가입이 끝났는지 확인합니다.
          return FutureBuilder<UserDetail>(
            future: ref.read(userRepositoryProvider).getMyProfile(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // 프로필 정보가 있고, 특정 필드(예: 태그)가 비어있다면 가입 미완료로 간주
              final user = profileSnapshot.data;

              // 가입 미완료 판별 로직
              if (user == null) {
                debugPrint("⚠️ 가입 미완료 유저: 회원가입 화면으로 안내");
                return const SignupMainScreen();
              }

              // 성공적으로 정보를 가져왔다면 전역 Provider에 저장
              // 프레임 렌더링 후에 상태를 업데이트하도록 처리
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(currentUserProvider.notifier).setUser(user.user);
                // FCM 초기화 등 추가 작업
                ref.read(fcmServiceProvider).initialize();
              });

              return const MainScreen();
            },
          );
        }
        // 토큰이 없는 경우 (로그아웃 상태)
        return const LoginScreen();
      },
    );
  }
}
