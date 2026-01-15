// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/auth/signup/widgets/signup_progress.bar.dart';
import 'nickname_setup_screen.dart';
import 'profile_image_screen.dart';
import 'bio_setup_screen.dart';
import 'tag_screen.dart';
import 'signup_success_screen.dart';

// 회원가입 메인 컨테이너 + 흐름 제어
class SignupMainScreen extends StatefulWidget {
  const SignupMainScreen({super.key});

  @override
  State<SignupMainScreen> createState() => _SignupMainScreenState();
}

class _SignupMainScreenState extends State<SignupMainScreen> {
  final PageController _pageController =
      PageController(); // 각 가입 단계 화면의 전환을 제어하는 컨트롤러
  int _currentStep = 1; // 1단계부터 시작
  final int _totalSteps = 4; // 닉네임, 이미지, 소개, 태그 총 4단계

  // 다음 가입 단계로 이동하는 함수
  void _nextPage() {
    // 다음 페이지로 넘어가기 전 현재 활성화된 키보드를 닫기
    FocusScope.of(context).unfocus();

    // 마지막 단계 이후에는 성공 화면으로 이동
    if (_currentStep <= _totalSteps) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 단계 완료 시 로직 (예: 서버 전송)
    }
  }

  // 이전 가입 단계로 돌아가는 함수
  void _prevPage() {
    // 뒤로 갈 때 키보드 닫기
    FocusScope.of(context).unfocus();

    if (_currentStep > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 1단계에서 뒤로가기 클릭 시 회원가입 프로세스 종료
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 성공 화면인지 확인
    bool isSuccessStep = _currentStep == 5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isSuccessStep
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.black),
                onPressed: _prevPage,
              ),
              title: Text(
                '회원가입',
                style: AppTypography.h3.copyWith(color: AppColors.black),
              ),
              centerTitle: true,
            ),
      body: Column(
        children: [
          if (!isSuccessStep)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: SignupProgressBar(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                ),
              ),
            ),
          // 각 단계별 화면
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // 스와이프 차단
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index + 1; // 인덱스를 단계 번호로 변환
                });
              },
              children: [
                NicknameSetupScreen(onNext: _nextPage), // 1단계
                ProfileImageScreen(onNext: _nextPage), // 2단계
                BioSetupScreen(onNext: _nextPage), // 3단계
                TagScreen(onNext: _nextPage), // 4단계
                SignupSuccessScreen(
                  // 가입 완료
                  onFinish: () {
                    print("완료!");
                    // 가입 완료 후 메인 홈으로 이동 (예시)
                    // Navigator.pushNamedAndRemoveUntil(
                    //   context,
                    //   '/home',
                    //   (route) => false,
                    // );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
