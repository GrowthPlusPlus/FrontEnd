// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'next_button.dart';

// 회원 가입의 모든 단계에서 공통으로 사용하는 기본 레이아웃 위젯
// 타이틀 + 서브타이틀 + 다음 버튼
class SignupPageLayout extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget child;
  final String buttonText;
  final bool isButtonEnabled;
  final VoidCallback onNext;

  const SignupPageLayout({
    super.key,
    required this.title,
    required this.subTitle,
    required this.child,
    required this.isButtonEnabled,
    required this.onNext,
    this.buttonText = '다음', // 기본값은 다음
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 콘텐츠 영역 (스크롤 가능)
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타이틀 + 서브타이틀
                Text(
                  title,
                  style: AppTypography.h2.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  subTitle,
                  style: AppTypography.b1.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 42),
                child, // 단계별 본문 콘텐츠
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),

        // 하단 고정 버튼 영역 (Floating 효과)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withAlpha(0),
                  Colors.white.withAlpha(0),
                  Colors.white.withAlpha(0),
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  12,
                ), // 바닥에서 12 띄움
                child: NextButton(
                  text: buttonText,
                  isEnabled: isButtonEnabled,
                  onPressed: onNext,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
