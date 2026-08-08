// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/auth/signup/widgets/signup_progress.bar.dart';

import '../providers/signup_provider.dart';
import 'nickname_setup_screen.dart';
import 'profile_image_screen.dart';
import 'bio_setup_screen.dart';
import 'tag_screen.dart';
import 'signup_success_screen.dart';

// 회원가입 전체 흐름을 제어하는 메인 컨테이너
class SignupMainScreen extends ConsumerStatefulWidget {
  const SignupMainScreen({super.key});

  @override
  ConsumerState<SignupMainScreen> createState() => _SignupMainScreenState();
}

class _SignupMainScreenState extends ConsumerState<SignupMainScreen> {
  late final PageController _pageController;
  int _currentStep = 1;
  static const int _totalSteps = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 각 단계별 화면 구성 리스트
  List<Widget> get _pages => [
    NicknameSetupScreen(onNext: _nextPage),
    ProfileImageScreen(onNext: _nextPage),
    BioSetupScreen(onNext: _nextPage),
    TagScreen(onNext: _nextPage),
    SignupSuccessScreen(onFinish: () => debugPrint("회원가입 프로세스 종료")),
  ];

  // 다음 단계로 이동
  void _nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 이전 단계로 이동
  void _prevPage() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final bool isSuccessStep = _currentStep == _totalSteps;
    final bool isLoading = ref.watch(signupProvider).isLoading;

    return PopScope(
      canPop: false, // 시스템 뒤로가기 제어
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _prevPage();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: isSuccessStep ? null : appColors.whiteToBlack,
            appBar: _buildAppBar(isSuccessStep, appColors),
            body: Column(
              children: [
                if (!isSuccessStep) _buildProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) =>
                        setState(() => _currentStep = index + 1),
                    children: _pages,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // 상단 앱바 구성
  PreferredSizeWidget? _buildAppBar(
    bool isSuccessStep,
    AppColorsExtension appColors,
  ) {
    if (isSuccessStep) return null;
    return AppBar(
      backgroundColor: appColors.whiteToBlack,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: appColors.blackToWhite),
        onPressed: _prevPage,
      ),
      title: Text(
        '회원가입',
        style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
      ),
      centerTitle: true,
    );
  }

  // 진행률 바 구성
  Widget _buildProgressBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: SignupProgressBar(
          currentStep: _currentStep,
          totalSteps: _totalSteps,
        ),
      ),
    );
  }

  // 로딩 오버레이 구성
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAble),
      ),
    );
  }
}
