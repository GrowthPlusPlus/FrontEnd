// 최초 작성자: 김채영

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light, // 다크모드 판별을 위해 필요
    // 스피너랑 커서 우리 앱 초록색으로 변경
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryAble,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryAble,
      selectionHandleColor: AppColors.primaryAble,
      selectionColor: AppColors.primaryAble.withValues(alpha: 0.3),
    ),

    // 상단 AppBar 테마 설정
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white, // 스크롤 시 색상 변함 방지
      elevation: 0,
      //scrolledUnderElevation: 0,     // 스크롤 시 그림자 생김 방지
      centerTitle: true,
    ),

    // 하단 NavigationBar 테마 설정
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
    ),

    // 하단 BottomNavigationBar 테마 설정 (Legacy 방식)
    // NavigationBar가 아닌 BottomNavigationBar를 쓸 경우를 대비
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
  );

  // 🖤 다크모드 기본 골격
  // TODO: 화면 점검하면서 색상값 다듬기
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: const Color(0xFF121212),
    brightness: Brightness.dark,

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryAble,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryAble,
      selectionHandleColor: AppColors.primaryAble,
      selectionColor: AppColors.primaryAble.withValues(alpha: 0.3),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      surfaceTintColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      surfaceTintColor: Color(0xFF1E1E1E),
      elevation: 0,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
  );
}
