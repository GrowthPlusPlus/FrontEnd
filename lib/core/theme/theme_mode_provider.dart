// 최초 작성자: 김채영
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// 라이트/다크 모드 관리하는 클래스
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // 기본값: 시스템 설정을 따라감
    // (저장/복원 기능은 나중에 필요할 때 추가)
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
