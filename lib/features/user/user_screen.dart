/// 최초 작성자: 정승빈
/// 작성일: 2026-01-18
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'withdrawal_screen.dart';
import 'challenge_list_screen.dart';
import '../auth/services/auth_service.dart';
import 'package:haenaem/features/auth/signup/screens/auth_gate.dart';

/// 클래스의 용도: 사용자의 프로필 정보 조회 및 챌린지 현황, 로그아웃 기능을 제공하는 마이페이지 화면
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // 선택된 챌린지 필터 상태 관리
  ChallengeStatus selectedTab = ChallengeStatus.ongoing;

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
              const SizedBox(height: 20),
              // --- 프로필 섹션 ---
              buildProfileImage(),
              const SizedBox(height: 16),
              buildProfileInfo('김해냄', isName: true),
              const SizedBox(height: 4),
              buildProfileInfo('Hello World 😊', isName: false),
              const SizedBox(height: 20),
              // --- 등급 뱃지 ---
              buildRankBadge('초보 모험가'),
              const SizedBox(height: 40),
              // --- 나의 챌린지 섹션 ---
              buildChallengeSection(),
              const SizedBox(height: 16),
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
              const SizedBox(height: 30),
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

  /// 함수의 용도: 나의 챌린지 현황 섹션 빌드
  /// 매개 변수: 없음
  /// 반환 값: Widget
  Widget buildChallengeSection() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray4),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '나의 챌린지',
                  style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChallengeListScreen(
                          challenges: ALL_CHALLENGES_DATA,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        '더보기',
                        style: AppTypography.b2.copyWith(
                          color: AppColors.gray3,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.gray3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                buildStatusTab('진행중', ChallengeStatus.ongoing),
                const SizedBox(width: 8),
                buildStatusTab('완료', ChallengeStatus.success),
                const SizedBox(width: 8),
                buildStatusTab('실패', ChallengeStatus.fail),
              ],
            ),
          ),
          const SizedBox(height: 16),
          buildChallengeList(),
        ],
      ),
    );
  }

  /// 함수의 용도: 상태 필터링 탭 버튼 생성
  /// 매개 변수: String label, ChallengeStatus status
  /// 반환 값: Widget
  Widget buildStatusTab(String label, ChallengeStatus status) {
    final bool isSelected = selectedTab == status;

    Color activeColor;
    IconData icon;
    switch (status) {
      case ChallengeStatus.ongoing:
        activeColor = AppColors.blue;
        icon = Icons.access_time;
        break;
      case ChallengeStatus.success:
        activeColor = AppColors.primaryAble;
        icon = Icons.check_circle_outline;
        break;
      case ChallengeStatus.fail:
        activeColor = AppColors.notification;
        icon = Icons.cancel_outlined;
        break;
    }

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTab = status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? null : Border.all(color: AppColors.gray4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.gray3,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.b2.copyWith(
                  color: isSelected ? Colors.white : AppColors.gray3,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 함수의 용도: 선택된 탭에 따른 챌린지 목록 위젯 생성
  /// 매개 변수: 없음
  /// 반환 값: Widget
  Widget buildChallengeList() {
    final sortedList = ChallengeModel.getSortedList(
      ALL_CHALLENGES_DATA,
      selectedTab,
    );

    if (sortedList.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          '챌린지가 없습니다.',
          style: AppTypography.b2.copyWith(color: AppColors.gray3),
        ),
      );
    }

    final displayList = sortedList.take(2).toList();

    return Column(
      children: [
        ...displayList.asMap().entries.map((entry) {
          final item = entry.value;
          final index = entry.key;
          final isLast = index == (displayList.length - 1);

          return Column(
            children: [
              buildChallengeCard(item),
              if (!isLast) const Divider(height: 1, color: AppColors.gray4),
            ],
          );
        }),
        const SizedBox(height: 1),
      ],
    );
  }

  /// 함수의 용도: 개별 챌린지 항목 카드 위젯 생성
  /// 매개 변수: ChallengeModel item
  /// 반환 값: Widget
  Widget buildChallengeCard(ChallengeModel item) {
    Color themeColor;
    String statusText;
    switch (item.status) {
      case ChallengeStatus.ongoing:
        themeColor = AppColors.blue;
        statusText = '진행중';
        break;
      case ChallengeStatus.success:
        themeColor = AppColors.primaryAble;
        statusText = '완료';
        break;
      case ChallengeStatus.fail:
        themeColor = AppColors.notification;
        statusText = '실패';
        break;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item.title,
                    style: AppTypography.b1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: AppTypography.c1.copyWith(color: themeColor),
                    ),
                  ),
                ],
              ),
              Text(
                '${(item.progress * 100).toInt()}%',
                style: AppTypography.h3.copyWith(
                  color: themeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.dateInfo,
            style: AppTypography.b2.copyWith(color: AppColors.gray2),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/icons/small_fire_icon.svg',
                width: 16,
                height: 16,
              ),
              Text(
                item.status == ChallengeStatus.ongoing
                    ? ' ${item.streak}일째'
                    : ' 최대 ${item.streak}일',
                style: AppTypography.c1.copyWith(color: AppColors.black),
              ),
              const SizedBox(width: 12),
              if (item.status == ChallengeStatus.ongoing) ...[
                SvgPicture.asset(
                  'assets/images/icons/mini_success_icon.svg',
                  width: 16,
                  height: 16,
                ),
                Text(' ${item.countInfo}', style: AppTypography.b2),
              ],
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: item.progress,
            backgroundColor: AppColors.gray5,
            color: themeColor,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
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
                        onTap: () async {
                          // 1. 다이얼로그 먼저 닫기
                          Navigator.pop(context);

                          // 2. 로그아웃 API 호출 및 로컬 데이터 삭제
                          await AuthService.logout();

                          // 3. 화면 이동 (context가 유효한지 확인 후 실행)
                          if (context.mounted) {
                            // pushAndRemoveUntil을 사용하면 현재 마이페이지를 포함한 모든 화면을 지우고
                            // AuthGate를 처음부터 다시 실행하게 됩니다.
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const AuthGate(),
                              ),
                              (route) => false, // 이전의 모든 기록을 지움
                            );
                          }

                          /// 3. 로그인 화면으로 이동 (기존 페이지 스택을 모두 비움)
                          //if (context.mounted) {
                          // '/login'은 팀원이 설정한 로그인 화면의 라우트 이름입니다.
                          // 만약 라우트 설정이 없다면 MaterialPageRoute를 사용하세요.
                          //Navigator.pushAndRemoveUntil(
                          //context,
                          //MaterialPageRoute(
                          //builder: (context) => const AuthGate(),
                          //),
                          //(route) => false,
                          //);
                          //}
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
