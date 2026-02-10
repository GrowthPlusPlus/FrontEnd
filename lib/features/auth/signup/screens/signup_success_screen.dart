// 최초 작성자 : 김채영
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../widgets/emoji_firework_widget.dart';
import 'package:haenaem/features/auth/signup/widgets/signup_progress.bar.dart';
import 'package:haenaem/features/main/screens/main_screen.dart';

// 회원가입 4단계를 모두 끝낸 후 띄우는 가입 성공 화면
class SignupSuccessScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SignupSuccessScreen({super.key, required this.onFinish});

  @override
  State<SignupSuccessScreen> createState() => _SignupSuccessScreenState();
}

class _SignupSuccessScreenState extends State<SignupSuccessScreen> {
  // 폭죽 애니메이션 관리 객체
  final EmojiFireWork _firework = EmojiFireWork(
    emojiAsset: const AssetImage('assets/images/illustrations/heart_icon.png'),
  );

  @override
  void initState() {
    super.initState();
    // 화면이 그려진 직후 폭죽 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoFirework();
    });
  }

  // 자동으로 폭죽을 여러 번 터뜨리는 비동기 함수
  void _startAutoFirework() async {
    for (int i = 0; i < 3; i++) {
      if (!mounted) return;
      setState(() {
        _firework.addFireworkWidget();
      });
      // 0.3초 간격으로 다음 폭죽 발사
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 텍스트 가독성을 확보하고 스택 구조를 통해 애니메이션을 최상단에 배치
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.0, -0.94),
            end: Alignment(1.14, 1.36),
            colors: [Color(0xFF6DB9E9), Color(0xFF25AE7C), Color(0xFF00A843)],
            // 색상이 변하는 지점 배치
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          // Stack으로 전체 구조를 잡아야 폭죽이 텍스트 위를 날아다님
          children: [
            // 배경 위 콘텐츠 레이어
            SafeArea(
              child: Column(
                children: [
                  // 커스텀 AppBar
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    child: Text(
                      '회원가입',
                      style: AppTypography.h3.copyWith(color: Colors.white),
                    ),
                  ),
                  // 진행률 바 배치
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: SignupProgressBar(
                      currentStep: 5,
                      totalSteps: 5,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white,
                    ),
                  ),

                  // 메인 콘텐츠 영역
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 36,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 3,
                        children: [
                          Text(
                            '가입을 해냈어요! 🎉\n당신의 첫 번째 성취를 축하합니다.',
                            style: AppTypography.h2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '멋진 챌린지들이 기다리고 있어요.\n함께 해낼 준비 됐나요?',
                            style: AppTypography.h3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 시작하기 버튼 (텍스트 커스텀 버튼)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: GestureDetector(
                      onTap: () {
                        // 만약 외부에서 넘겨준 추가 로직이 있다면 실행
                        // if (widget.onFinish != null) widget.onFinish!();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      behavior: HitTestBehavior.opaque, // 투명한 영역도 터치 가능하게
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        alignment: Alignment.center,

                        child: Text(
                          '시작하기',
                          style: AppTypography.h3.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 폭죽 레이어 (최상단에 위치시켜야 텍스트 위로 터짐)
            IgnorePointer(
              // 폭죽이 클릭을 방해하지 않도록 추가
              child: Stack(
                children: _firework.fireworkWidgets.values.map((widget) {
                  return Center(child: widget); // 화면 중앙에서 터지도록 설정
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
