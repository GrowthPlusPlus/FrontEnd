// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 프로필 이미지 편집 화면 하단 도구 버튼들 (회전 및 자르기)
class ProfileEditTools extends StatelessWidget {
  final VoidCallback onRotate;
  final VoidCallback onCrop;

  const ProfileEditTools({
    super.key,
    required this.onRotate,
    required this.onCrop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToolButton('assets/images/icons/rotate.svg', '회전', onRotate),
        const SizedBox(width: 155),
        _buildToolButton('assets/images/icons/cut.svg', '자르기', onCrop),
      ],
    );
  }

  Widget _buildToolButton(String path, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            path,
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
