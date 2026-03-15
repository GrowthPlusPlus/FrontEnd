// 최초 작성자: 정승빈
// 사용자 프로필 사진을 원형으로 보여주는 위젯입니다. 이미지 URL이 제공되지 않으면 기본 아이콘이 표시됩니다.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserProfileCircle extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const UserProfileCircle({super.key, this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    // 🔥 디버깅용 콘솔 출력 추가: 어떤 URL 값이 들어오는지 확인
    debugPrint('UserProfileCircle - 전달받은 imageUrl: $imageUrl');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0x7FDFE1DC),
        shape: BoxShape.circle,
        image: imageUrl != null && imageUrl!.startsWith('http')
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : (imageUrl != null
                  ? DecorationImage(
                      image: AssetImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null),
      ),
      child: imageUrl == null
          ? Center(
              child: SvgPicture.asset(
                'assets/images/icons/default_profile_icon.svg',
                width: size,
              ),
            )
          : null,
    );
  }
}
