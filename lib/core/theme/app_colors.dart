// 최초 작성자: 김채영

import 'package:flutter/material.dart';

class AppColors {
  static const Color white = Color(0xFFFAFAFA);
  static const Color black = Color(0xFF1b1d1b);

  // Grayscale
  static const Color gray1 = Color(0xFF444444);
  static const Color gray2 = Color(0xFF616161);
  static const Color gray3 = Color(0xFF8c8c8c);
  static const Color gray4 = Color(0xFFD9D9D9);
  static const Color gray5 = Color(0x80E0E2DC);

  // Green - primary
  static const Color primaryAble = Color(0xff009951);
  static const Color selected = Color(0xffe8f5e9);
  static const Color disable = Color(0xffd9e0d7);

  // Mainlist
  static const success = Color(0x7fbbf4bd);
  static const warning = Color(0x7fffd6c8);

  static const Color fire = Color(0xFFFB7039);
  static const Color notification = Color(0xffD11E1B);
  static const Color blue = Color(0xff4589FF);
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color blackToWhite;
  final Color whiteToBlack;
  final Color gray1;
  final Color gray2;
  final Color gray3;
  final Color gray4;
  final Color gray5;
  final Color primaryAble;
  final Color selected;
  final Color disable;
  final Color success;
  final Color warning;
  final Color notification;

  const AppColorsExtension({
    required this.blackToWhite,
    required this.whiteToBlack,
    required this.gray1,
    required this.gray2,
    required this.gray3,
    required this.gray4,
    required this.gray5,
    required this.primaryAble,
    required this.selected,
    required this.disable,
    required this.success,
    required this.warning,
    required this.notification,
  });

  // 라이트 모드 매핑
  factory AppColorsExtension.light() {
    return const AppColorsExtension(
      blackToWhite: AppColors.black,
      whiteToBlack: AppColors.white,
      gray1: AppColors.gray1,
      gray2: AppColors.gray2,
      gray3: AppColors.gray3,
      gray4: AppColors.gray4,
      gray5: AppColors.gray5,
      primaryAble: AppColors.primaryAble,
      selected: AppColors.selected,
      disable: AppColors.disable,
      success: AppColors.success,
      warning: AppColors.warning,
      notification: AppColors.notification,
    );
  }

  // 다크 모드 매핑 (요청하신 계획안 적용)
  factory AppColorsExtension.dark() {
    return const AppColorsExtension(
      blackToWhite: AppColors.white, // black -> white
      whiteToBlack: AppColors.black, // white -> black
      gray1: AppColors.gray4, // gray1 -> gray4
      gray2: AppColors.gray4, // gray2 -> gray4
      gray3: AppColors.gray3, // gray3 변경없음
      gray4: AppColors.gray2, // gray4 -> gray2
      gray5: Color(0xFF2A2A2A), // gray5 -> d-gray5
      primaryAble: Color(0xFF0EBC6A), // primarygreen -> d-primarygreen
      selected: Color(0xFF264F36), // selected -> d-selected
      disable: Color(0xFF697C73), // disable -> d-disable
      success: Color(0xFF1A3A1E), // success -> d-success
      warning: Color(0xFF3A2522), // warning -> d-warning
      notification: Color(0xFFEE4750), // notification -> d-notification
    );
  }

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? blackToWhite,
    Color? whiteToBlack,
    Color? gray1,
    Color? gray2,
    Color? gray3,
    Color? gray4,
    Color? gray5,
    Color? primaryAble,
    Color? selected,
    Color? disable,
    Color? success,
    Color? warning,
    Color? notification,
  }) {
    return AppColorsExtension(
      blackToWhite: blackToWhite ?? this.blackToWhite,
      whiteToBlack: whiteToBlack ?? this.whiteToBlack,
      gray1: gray1 ?? this.gray1,
      gray2: gray2 ?? this.gray2,
      gray3: gray3 ?? this.gray3,
      gray4: gray4 ?? this.gray4,
      gray5: gray5 ?? this.gray5,
      primaryAble: primaryAble ?? this.primaryAble,
      selected: selected ?? this.selected,
      disable: disable ?? this.disable,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      notification: notification ?? this.notification,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      blackToWhite: Color.lerp(blackToWhite, other.blackToWhite, t)!,
      whiteToBlack: Color.lerp(whiteToBlack, other.whiteToBlack, t)!,
      gray1: Color.lerp(gray1, other.gray1, t)!,
      gray2: Color.lerp(gray2, other.gray2, t)!,
      gray3: Color.lerp(gray3, other.gray3, t)!,
      gray4: Color.lerp(gray4, other.gray4, t)!,
      gray5: Color.lerp(gray5, other.gray5, t)!,
      primaryAble: Color.lerp(primaryAble, other.primaryAble, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      disable: Color.lerp(disable, other.disable, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      notification: Color.lerp(notification, other.notification, t)!,
    );
  }
}
