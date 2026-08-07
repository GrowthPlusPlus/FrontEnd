import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/widgets/bottom_action_button.dart';
import 'package:flutter_svg/svg.dart';

class CalendarSharePreview extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const CalendarSharePreview({
    super.key,
    required this.imageUrl,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Dialog(
      backgroundColor: Colors.transparent, // 배경 투명 (barrierColor가 어둡게 처리)
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 상단 닫기 버튼
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 8),

          // 2. 중앙 이미지 카드
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 300,
                      color: appColors.gray5,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: appColors.blackToWhite,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: appColors.gray5,
                    child: Center(
                      child: Text(
                        '이미지를 불러올 수 없습니다.',
                        style: TextStyle(color: appColors.blackToWhite),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. 하단 액션 버튼 (저장 & 공유)
          Row(
            children: [
              // 이미지 저장 버튼
              Expanded(
                child: BottomActionButton(
                  text: '저장하기',
                  icon: Icons.download_rounded,
                  onPressed: onSave,
                  backgroundColor: appColors.gray2,
                  textColor: appColors.whiteToBlack,
                  showContainerDecoration: false, // Row 안에서 배경 중첩 방지
                ),
              ),
              const SizedBox(width: 12),

              // 외부 공유 버튼
              Expanded(
                child: BottomActionButton(
                  text: '공유하기',
                  icon: Icons.share_rounded,
                  onPressed: onShare,
                  backgroundColor: appColors.primaryAble,
                  textColor: appColors.whiteToBlack,
                  showContainerDecoration: false, // Row 안에서 배경 중첩 방지
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
