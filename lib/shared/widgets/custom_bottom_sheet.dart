// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'bottom_sheet_header.dart';

// -- 챌린지 생성화면의 탭 화면의 제목, 콘텐츠들 커스텀할 수 있도록 함 --
class CustomBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final double heightFactor;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.heightFactor = 0.55,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: BottomSheetHeader(title: title),
          ),
          Expanded(child: child),

          // 맨 아래 여백
          const SizedBox(height: 20),
          // 아이폰 홈 바 영역까지 안전하게 확보
          const SafeArea(top: false, child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
