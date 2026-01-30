/// 최초 작성자: 정승빈
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'withdrawal_screen.dart';

/// 클래스의 용도: 사용자의 프로필 정보 조회 및 로그아웃, 회원탈퇴 기능을 제공하는 마이페이지 화면
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  /// 함수의 용도: 마이페이지 화면 UI 빌드
  /// 매개 변수: BuildContext context
  /// 반환 값: Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '내 페이지',
          style: AppTypography.h2.copyWith(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // --- 프로필 섹션 ---
              buildProfileImage(),
              const SizedBox(height: 16),
              buildProfileInfo('김해냄', isName: true),
              const SizedBox(height: 4),
              buildProfileInfo('Hello World 😊', isName: false),
              const SizedBox(height: 20),
              // --- 등급 뱃지 ---
              buildRankBadge('초보 모험가'),
              const SizedBox(height: 80),
              // --- 메뉴 리스트 섹션 ---
              buildMenuItem(
                title: '로그아웃',
                textColor: AppColors.black,
                onTap: () => showLogoutDialog(context),
              ),
              const SizedBox(height: 12),
              buildMenuItem(
                title: '회원 탈퇴',
                textColor: AppColors.notification,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WithdrawalScreen(),
                    ),
                  );
                },
                showArrow: true,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  /// 함수의 용도: 프로필 이미지 및 설정 아이콘 레이아웃 생성
  /// 매개 변수: 없음
  /// 반환 값: Widget
  Widget buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFDFE1DC).withAlpha(128),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/placeholders/default_profile.svg',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.black,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/images/icons/black_settings_icon.svg',
            width: 20,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  /// 함수의 용도: 사용자 이름 또는 상태 메시지 정보 행 생성
  /// 매개 변수: String text, bool isName (이름 여부)
  /// 반환 값: Widget
  Widget buildProfileInfo(String text, {required bool isName}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 24), // 좌우 균형을 위한 더미 공간
        Text(
          text,
          style: isName
              ? AppTypography.h3.copyWith(color: AppColors.black)
              : AppTypography.b1.copyWith(color: AppColors.gray2),
        ),
        const SizedBox(width: 4),
        SvgPicture.asset(
          'assets/images/icons/edit.svg',
          width: 16,
          colorFilter: const ColorFilter.mode(AppColors.gray3, BlendMode.srcIn),
        ),
      ],
    );
  }

  /// 함수의 용도: 사용자의 등급 뱃지 위젯 생성
  /// 매개 변수: String rank (등급 명칭)
  /// 반환 값: Widget
  Widget buildRankBadge(String rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.selected,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        rank,
        style: AppTypography.b1.copyWith(color: AppColors.primaryAble),
      ),
    );
  }

  /// 함수의 용도: 로그아웃, 회원탈퇴 등 메뉴 아이템 위젯 빌드
  /// 매개 변수: String title, Color textColor, VoidCallback onTap, bool showArrow
  /// 반환 값: Widget
  Widget buildMenuItem({
    required String title,
    required Color textColor,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFDFE1DC).withAlpha(128),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.b1.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.gray3,
              ),
          ],
        ),
      ),
    );
  }

  /// 함수의 용도: 로그아웃 확인 팝업 다이얼로그 표시
  /// 매개 변수: BuildContext context
  /// 반환 값: 없음
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: 335,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text(
                  '로그아웃',
                  style: AppTypography.h2.copyWith(color: AppColors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '로그아웃 하시겠습니까?',
                  style: AppTypography.b1.copyWith(color: AppColors.gray2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: buildDialogButton(
                        context: context,
                        text: '취소',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildDialogButton(
                        context: context,
                        text: '확인',
                        onTap: () {
                          // TODO: 실제 로그아웃 로직 연결 예정
                          Navigator.pop(context);
                          // 현재는 로그아웃 버튼 누르면 다이얼로그 닫힘
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 함수의 용도: 다이얼로그 내 공통 버튼 빌드
  /// 매개 변수: BuildContext context, String text, VoidCallback onTap
  /// 반환 값: Widget
  Widget buildDialogButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDFE1DC).withAlpha(127),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTypography.b1.copyWith(
              color: AppColors.gray2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
