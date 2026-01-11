// 최초 작성자: 김채영

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/features/challenge/create/challenge_create_page.dart';

void main() async {
  // 2. 비동기 초기화를 위해 반드시 추가
  WidgetsFlutterBinding.ensureInitialized();

  // 3. 한국어 날짜 데이터 로드
  await initializeDateFormatting('ko_KR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growth++',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryAble,
        scaffoldBackgroundColor: Colors.white,
      ),

      // 4. 로컬라이징 설정 (달력 한글화를 위해 필수)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      locale: const Locale('ko', 'KR'), // 앱 기본 언어를 한국어로 설정

      home: const ChallengeCreatePage(),
    );
  }
}
