// 최초 작성자: 김채영
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';
import '../models/signup_state.dart';
import '../widgets/signup_page_layout.dart';
import 'package:haenaem/shared/widgets/custom_bottom_sheet.dart';
import 'package:haenaem/shared/widgets/image_source_sheet.dart';

// 프로필 이미지 설정 화면
class ProfileImageScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const ProfileImageScreen({super.key, required this.onNext});

  @override
  ConsumerState<ProfileImageScreen> createState() => _ProfileImageScreenState();
}

// 프로필 이미지 설정 화면의 상태 관리 클래스
class _ProfileImageScreenState extends ConsumerState<ProfileImageScreen> {
  final ImagePicker _picker = ImagePicker(); // 이미지 선택 서비스 호출

  // shared-widgets에 있는 시트 불러오기 (카메라/갤러리)
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ImageSourceSheet(onSourceSelected: (source) => _getImage(source)),
    );
  }

  // 갤러리에서 이미지를 가져오는 비동기 함수
  Future<void> _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      ref.read(signupProvider.notifier).updateImage(File(image.path));
      if (mounted) Navigator.pop(context);
    }
  }

  // "다음" 버튼 클릭 시 실행될 핸들러
  Future<void> _handleNext() async {
    // 💡 이미지 업로드 API(uploadProfileImage) 호출을 아예 지웁니다.
    // 이미지는 이미 _getImage 단계에서 notifier.updateImage로 로컬에 저장되었습니다.
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    // 프로바이더에서 현재 선택된 이미지 상태를 직접 가져오기
    final selectedImage = ref.watch(signupProvider).profileImage;

    // 사용자가 이미지를 넣었는지에 따라 텍스트 결정
    final String dynamicButtonText = selectedImage == null ? '건너뛰기' : '다음';

    return SignupPageLayout(
      title: '프로필 이미지를\n설정해주세요',
      subTitle: '나를 잘 나타내는 사진을 올려주세요.\n언제든지 변경할 수 있어요.',
      isButtonEnabled: true,
      buttonText: dynamicButtonText, // 동적 텍스트 전달
      onNext: _handleNext,

      child: Center(
        child: GestureDetector(
          onTap: _showImageSourceSheet,
          child: Stack(
            children: [
              // 이미지 표시 원형 컨테이너
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gray5,
                  border: Border.all(color: AppColors.gray4, width: 1),
                  image: selectedImage != null
                      ? DecorationImage(
                          image: FileImage(selectedImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: selectedImage == null
                    ? SvgPicture.asset(
                        'assets/images/placeholders/default_profile.svg',
                        width: 150,
                      )
                    : null,
              ),
              // 프로필 설정 아이콘 (톱니바퀴)
              Positioned(
                left: 90,
                top: 90,
                child: Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(9),
                  child: SvgPicture.asset(
                    'assets/images/icons/profile_settings.svg',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
