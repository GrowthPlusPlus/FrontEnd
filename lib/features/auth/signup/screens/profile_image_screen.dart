// 최초 작성자: 김채영
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../widgets/signup_page_layout.dart';
import 'package:haenaem/shared/widgets/custom_bottom_sheet.dart';

// 프로필 이미지 설정 화면
class ProfileImageScreen extends StatefulWidget {
  final VoidCallback onNext;

  const ProfileImageScreen({super.key, required this.onNext});

  @override
  State<ProfileImageScreen> createState() => _ProfileImageScreenState();
}

// 프로필 이미지 설정 화면의 상태 관리 클래스
class _ProfileImageScreenState extends State<ProfileImageScreen> {
  File? _selectedImage; // 선택된 이미지 파일을 담는 변수 (null일 경우 기본 이미지 사용)
  final ImagePicker _picker = ImagePicker(); // 이미지 선택 서비스 호출

  // 갤러리에서 이미지를 가져오는 비동기 함수
  Future<void> _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      if (mounted) Navigator.pop(context);
    }
  }

  // 사진 찍을래, 갤러리에서 고를래 시트
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomBottomSheet(
          title: '사진 추가',
          heightFactor: 0.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildOptionItem(
                  title: '직접 촬영하기',
                  iconPath: 'assets/images/icons/camera.svg',
                  onTap: () => _getImage(ImageSource.camera),
                ),
                const SizedBox(height: 10),
                _buildOptionItem(
                  title: '갤러리에서 가져오기',
                  iconPath: 'assets/images/icons/gallery.svg',
                  onTap: () => _getImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 시트 안 컴포넌트들의 색상, 이미지, 폰트 지정
  Widget _buildOptionItem({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.gray5,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 36,
              height: 36,
              colorFilter: const ColorFilter.mode(
                AppColors.gray1,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTypography.b1.copyWith(color: AppColors.gray1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 사용자가 이미지를 넣었는지에 따라 텍스트 결정
    final String dynamicButtonText = _selectedImage == null ? '건너뛰기' : '다음';

    return SignupPageLayout(
      title: '프로필 이미지를\n설정해주세요',
      subTitle: '나를 잘 나타내는 사진을 올려주세요.\n언제든지 변경할 수 있어요.',
      isButtonEnabled: true,
      buttonText: dynamicButtonText, // 동적 텍스트 전달
      onNext: widget.onNext,

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
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: _selectedImage == null
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
