// 최초 작성자: 김채영

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: Colors.white,

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
}
