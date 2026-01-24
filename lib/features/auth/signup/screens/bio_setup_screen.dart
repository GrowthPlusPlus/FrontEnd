// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../widgets/signup_page_layout.dart';

// 한줄소개 화면
class BioSetupScreen extends StatefulWidget {
  final VoidCallback onNext;

  const BioSetupScreen({super.key, required this.onNext});

  @override
  State<BioSetupScreen> createState() => _BioSetupScreenState();
}

// 한 줄 소개 설정 화면의 상태 관리 클래스
class _BioSetupScreenState extends State<BioSetupScreen> {
  final TextEditingController _bioController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    // 텍스트 입력 시마다 버튼 상태와 글자 수를 업데이트하기 위해 리스너 등록
    _bioController.addListener(_validateInput);
  }

  void _validateInput() {
    final text = _bioController.text;
    setState(() {
      // 한 글자라도 입력되면 다음 버튼 활성화
      _isButtonEnabled = text.isNotEmpty && text.length <= 50;
    });
  }

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 화면 이탈 시 컨트롤러 해제
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 사용자가 한 글자라도 입력했는지 여부를 판단하여 버튼 문구 결정
    final String dynamicButtonText = _bioController.text.isEmpty
        ? '건너뛰기'
        : '다음';
    return SignupPageLayout(
      title: '한 줄 소개를\n입력해주세요',
      subTitle: '나의 도전이나 다짐을 한 줄로 적어주세요\n(공백 포함 최대 50자)',
      isButtonEnabled: true, // 입력 유무와 상관없이 항상 활성화 (건너뛰기 허용)
      buttonText: dynamicButtonText,
      onNext: widget.onNext,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _bioController,
                maxLength: 50,
                maxLines: null,
                minLines: 1,
                style: AppTypography.b2.copyWith(color: AppColors.black),
                decoration: InputDecoration(
                  hintText: '한 줄 소개를 입력해주세요',
                  hintStyle: AppTypography.b2.copyWith(color: AppColors.gray3),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.gray4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryAble,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_bioController.text.length}/50',
                style: AppTypography.c1.copyWith(color: AppColors.gray2),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
