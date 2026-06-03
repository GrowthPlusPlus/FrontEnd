/// 최초 작성자: 정승빈
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../auth/services/auth_service.dart';
import 'package:haenaem/features/auth/signup/screens/auth_gate.dart';

/// 클래스의 용도: 회원 탈퇴 안내 및 동의 확인, 탈퇴 처리를 수행하는 화면
class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  // 체크박스 상태 관리
  bool isAgreed = false;

  /// 함수의 용도: 회원 탈퇴 화면 UI 빌드
  /// 매개 변수: BuildContext context
  /// 반환 값: Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          // 뒤로가기 버튼 (SVG 사용 권장)
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          '회원 탈퇴',
          style: AppTypography.h2.copyWith(color: AppColors.black), //
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // --- 경고 아이콘 영역 ---
                    buildWarningIcon(),
                    const SizedBox(height: 20),
                    // --- 안내 문구 영역 ---
                    Text(
                      '정말 탈퇴하시겠습니까?',
                      style: AppTypography.h1.copyWith(
                        color: AppColors.black,
                      ), //
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '계정을 삭제하면 모든 데이터가 영구적으로\n삭제되며 복구할 수 없습니다.',
                      style: AppTypography.b1.copyWith(
                        color: AppColors.gray2,
                      ), //
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // --- 동의 체크박스 영역 ---
                    buildAgreementBox(),
                    const SizedBox(height: 10),
                    // --- 추가 참고 사항 영역 ---
                    buildNoticeBox(),
                  ],
                ),
              ),
            ),
            // --- 하단 버튼 영역 ---
            buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  /// 함수의 용도: 경고 아이콘(SVG) 영역 위젯 생성
  /// 매개 변수: 없음
  /// 반환 값: Widget
  Widget buildWarningIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        // 피그마 mainlist-warning 컬러 적용 (투명도 포함)
        color: const Color(0xFFFFD5C8).withAlpha(127),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset('assets/images/icons/warning.svg', width: 48),
      ),
    );
  }

  /// 함수의 용도: 탈퇴 동의 여부를 확인하는 체크박스 박스 생성
  /// 매개 변수: 없음
  /// 반환 값: Widget
  Widget buildAgreementBox() {
    return InkWell(
      onTap: () => setState(() => isAgreed = !isAgreed),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFDFE1DC).withAlpha(127), // gray5
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 플러터 기본 제공 아이콘 사용
            Icon(
              isAgreed ? Icons.check_box : Icons.check_box_outline_blank,
              size: 24,
              // 체크 여부에 따라 색상 변경 (검정 / 회색3)
              color: isAgreed ? AppColors.black : AppColors.gray3, //
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '위 내용을 확인했으며, 계정 삭제에 동의합니다.',
                style: AppTypography.b2.copyWith(color: AppColors.black), //
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 함수의 용도: 탈퇴 관련 추가 참고 사항을 안내하는 박스 생성
  /// 매개 변수: 없음
  /// 반환 값: Widget
  Widget buildNoticeBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDFE1DC).withAlpha(127),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '참고: 탈퇴 후 30일 이내에는 계정 복구가 가능합니다. '
        '30일이 지나면 모든 데이터가 완전히 삭제됩니다.',
        style: AppTypography.c1.copyWith(color: AppColors.gray2), //
      ),
    );
  }

  /// 함수의 용도: 화면 하단의 취소 및 탈퇴하기 액션 버튼 영역 생성
  /// 매개 변수: BuildContext context
  /// 반환 값: Widget
  Widget buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 탈퇴하기 버튼 (상태에 따라 변화)
          Expanded(
            child: buildActionButton(
              text: '탈퇴하기',
              // 동의 여부에 따라 배경색 변경
              color: isAgreed
                  ? AppColors.notification
                  : const Color(0xFFDBADAD), //
              textColor: Colors.white,
              onTap: isAgreed
                  ? () async {
                      try {
                        // 1. 회원 탈퇴 API 호출 (DELETE 요청 및 토큰 삭제)
                        await AuthService.withdraw();

                        // 2. 탈퇴 성공 알림 및 이동
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('회원 탈퇴가 완료되었습니다.')),
                          );
                          // 3. AuthGate로 이동하여 초기화된 상태로 보냄
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthGate(),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        // 4. 에러 발생 시 처리
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('탈퇴 처리 중 오류가 발생했습니다: $e')),
                          );
                        }
                      }
                    }
                  : null, // 비활성화 상태
            ),
          ),
          const SizedBox(width: 10),
          // 취소 버튼
          Expanded(
            child: buildActionButton(
              text: '취소',
              color: const Color(0xFFDFE1DC).withAlpha(127),
              textColor: AppColors.gray2,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 함수의 용도: 공통 스타일이 적용된 액션 버튼 위젯 생성
  /// 매개 변수: String text, Color color, Color textColor, VoidCallback? onTap
  /// 반환 값: Widget
  Widget buildActionButton({
    required String text,
    required Color color,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTypography.b1.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
