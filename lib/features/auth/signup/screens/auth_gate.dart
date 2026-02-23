// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import 'package:haenaem/features/main/screens/main_screen.dart';
import 'package:haenaem/features/auth/login/login_screen.dart';
import 'signup_main_screen.dart';
import 'package:haenaem/features/challenge/data/challenge_repository.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
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
          return FutureBuilder<UserProfileModel>(
            future: ref.read(challengeRepositoryProvider).getMyProfile(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // 프로필 정보가 있고, 특정 필드(예: 태그)가 비어있다면 가입 미완료로 간주
              final profile = profileSnapshot.data;
              if (profile == null || profile.tags.isEmpty) {
                debugPrint("⚠️ 가입 미완료 유저 감지: 회원가입 화면으로 이동");
                return const SignupMainScreen(); // 닉네임 설정부터 다시!
              }

              // 가입 완료가 확인되어 메인으로 가기 전, FCM 토큰을 업데이트
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(fcmServiceProvider).updateFcmToken();
                ref.read(fcmServiceProvider).setTokenRefreshListener();
              });

              return const MainScreen(); // 모든 정보가 있을 때만 홈으로!
            },
          );
        }

        // 2. 토큰이 없는 경우
        return const LoginScreen();
      },
    );
  }
}
