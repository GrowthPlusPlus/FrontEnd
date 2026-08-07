// 최초 작성자: 정승빈

import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/widgets/bottom_action_button.dart';

class ReportSuccessScreen extends StatelessWidget {
  const ReportSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 초록색 체크 원형 아이콘
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: appColors.primaryAble,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 완료 안내 제목
                    Text(
                      '신고가 접수되었습니다.',
                      textAlign: TextAlign.center,
                      style: AppTypography.h1.copyWith(
                        color: appColors.blackToWhite,
                      ), // 24px, Bold
                    ),
                    const SizedBox(height: 12),

                    // 완료 안내 부가 설명
                    Text(
                      '검토 결과에 따라 적절한 조치가 취해질 예정이며,\n깨끗한 \'해냄\'을 위해 항상 노력하겠습니다.',
                      textAlign: TextAlign.center,
                      style: AppTypography.b3.copyWith(
                        color: appColors.gray1,
                      ), // 16px, SemiBold
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // 하단 '확인' 버튼
      bottomNavigationBar: BottomActionButton(
        text: '확인',
        onPressed: () {
          // '확인' 버튼을 누르면 이 화면을 닫고 피드(또는 댓글) 화면으로 돌아갑니다.
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
