// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/widgets/custom_bottom_sheet.dart';

// 촬영 or 갤러리 바텀시트
class ImageSourceSheet extends StatelessWidget {
  final Function(ImageSource) onSourceSelected; // 선택된 소스를 부모 위젯으로 전달하기 위한 콜백 함수

  const ImageSourceSheet({super.key, required this.onSourceSelected});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return CustomBottomSheet(
      title: '사진 추가',
      heightFactor: 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildOptionItem(
              appColors,
              title: '직접 촬영하기',
              iconPath: 'assets/images/icons/camera.svg',
              onTap: () => onSourceSelected(ImageSource.camera),
            ),
            const SizedBox(height: 10),
            _buildOptionItem(
              appColors,
              title: '갤러리에서 가져오기',
              iconPath: 'assets/images/icons/gallery_icon.svg',
              onTap: () => onSourceSelected(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    AppColorsExtension appColors, {
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
          color: appColors.gray5,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 36,
              height: 36,
              colorFilter: ColorFilter.mode(appColors.gray1, BlendMode.srcIn),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTypography.b1.copyWith(color: appColors.gray1),
            ),
          ],
        ),
      ),
    );
  }
}
