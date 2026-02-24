// 최초 작성자: 김채영

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:haenaem/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haenaem/features/main/screens/main_screen.dart';

import 'package:haenaem/features/auth/signup/screens/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // 플러터 엔진 초기화 확인
  WidgetsFlutterBinding.ensureInitialized();

  // 비동기 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 저장소 인스턴스 생성
  const storage = FlutterSecureStorage();

  // 저장된 토큰 읽기
  String? accessToken = await storage.read(key: 'accessToken');
  String? refreshToken = await storage.read(key: 'refreshToken');

  print("--------------------------------");
  print("🔑 [토큰 검사 결과]");
  print("Access Token: ${accessToken ?? '없음 (삭제됨)'}");
  print("Refresh Token: ${refreshToken ?? '없음 (삭제됨)'}");
  print("--------------------------------");

  // 한국어 날짜 데이터 로드
  await initializeDateFormatting('ko_KR', null);

  // 플러터 엔진과 바인딩 확인 (비동기 작업 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // 파이어베이스 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haenaem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // 로컬라이징 설정 (달력 한글화를 위해 필수)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      locale: const Locale('ko', 'KR'), // 앱 기본 언어를 한국어로 설정
      //home: const ChallengeCreatePage(),
      home: const AuthGate(),
      //home: const ChallengeCreateSuccessDialog(),
      //home: const MainScreen(),
      //home: const ChallengeCalendarScreen(),
      //home: const ChallengeVerificationPage(),
      //home: const FeedScreen(),
      //home: const MyPageScreen(),
      //home: const SocialScreen(),
    );
  }
}
