// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';

// 소셜 로그인 로그인 화면
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // 스크롤 가능
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 160), // 상단 여백
                // 메인 타이틀 & 로고 영역
                SvgPicture.asset('assets/images/icons/sign_up_logo.svg'),
                const SizedBox(height: 26),
                Text(
                  "오늘의 '해냄'을 위해\n지금 시작해보세요",
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(color: Colors.black),
                ),

                const SizedBox(height: 120), // 중간 여백
                // 로그인 버튼들
                Text(
                  '간편하게 시작하기',
                  textAlign: TextAlign.center,
                  style: AppTypography.b2.copyWith(
                    color: const Color(0xFf6A7282),
                  ),
                ),
                const SizedBox(height: 10),

                // 버튼들 사이의 간격을 SizedBox로 조정 (버전 호환성)
                _buildSocialButton(
                  label: '카카오로 시작하기',
                  backgroundColor: const Color(0xFFFEE500),
                  textColor: Colors.black,
                  iconPath: 'assets/images/icons/kakao_logo.svg',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  label: '구글로 시작하기',
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF0A0A0A),
                  iconPath: 'assets/images/icons/google_logo.svg',
                  borderColor: const Color(0xFFD1D5DC),
                  onTap: () async {
                    // final idToken = await AuthService.signInWithGoogle();
                    // if (idToken != null) {
                    //   // TODO: 백엔드 API 호출하여 idToken 전달
                    //   print("백엔드로 보낼 토큰: $idToken");
                    // }
                  },
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  label: '네이버로 시작하기',
                  backgroundColor: const Color(0xFF03C75A),
                  textColor: Colors.white,
                  iconPath: 'assets/images/icons/naver_logo.svg',
                  onTap: () {},
                ),

                const SizedBox(height: 30),

                // 하단 안내 문구
                Text(
                  '계속 진행하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다',
                  textAlign: TextAlign.center,
                  style: AppTypography.b2.copyWith(
                    color: const Color(0xFF6A7282),
                  ),
                ),
                const SizedBox(height: 40), // 하단 여백
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 소셜 버튼 위젯
  Widget _buildSocialButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required String iconPath,
    required VoidCallback onTap,
    Color? borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: borderColor != null
                ? BorderSide(width: 2, color: borderColor)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 24, height: 24),
            const SizedBox(width: 12),
            Text(label, style: AppTypography.b1.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}
