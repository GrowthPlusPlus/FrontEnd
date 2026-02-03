// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import 'package:haenaem/features/main/screens/main_screen.dart';
import 'package:haenaem/features/auth/login/login_screen.dart';

// 앱을 껐다 켰을 때 저장된 토큰을 확인
// 바로 홈으로 보낼지 로그인으로 보낼지 결정 (자동 로그인)
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: AuthService.getAccessToken(), // 저장된 토큰 확인
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 토큰이 있다면 일단 자동 로그인 시도
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }

        // 토큰이 없다면 로그인 화면으로
        return const LoginScreen();
      },
    );
  }
}
