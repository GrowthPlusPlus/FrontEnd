/// 최초 작성자: 정승빈
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'withdrawal_screen.dart';

// --- 향후 모델 파일로 분리할 챌린지 데이터 구조 ---
class ChallengeItem {
  final String name;
  final String status; // '진행중', '완료', '실패'
  final double progress;
  final String dDay;
  final int currentStreak;
  final int currentParticipants;
  final int totalParticipants;

  ChallengeItem({
    required this.name,
    required this.status,
    required this.progress,
    required this.dDay,
    this.currentStreak = 0,
    this.currentParticipants = 0,
    this.totalParticipants = 0,
  });
}

// --- 챌린지 데이터 모델 ---
enum ChallengeStatus { ongoing, success, fail }

class ChallengeModel {
  final String title;
  final ChallengeStatus status;
  final double progress;
  final String dateInfo;
  final String countInfo;

  ChallengeModel({
    required this.title,
    required this.status,
    required this.progress,
    required this.dateInfo,
    this.countInfo = '0/0명',
  });
}

/// 클래스의 용도: 사용자의 프로필 정보 조회 및 로그아웃, 회원탈퇴 기능을 제공하는 마이페이지 화면
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // 현재 선택된 탭 상태 (기본값: 진행중)
  ChallengeStatus _selectedTab = ChallengeStatus.ongoing;

  // 임시 데이터 리스트 (추후 실제 API/DB 연결)
  final List<ChallengeModel> _allChallenges = [
    ChallengeModel(
      title: '물 마시기',
      status: ChallengeStatus.ongoing,
      progress: 0.4,
      dateInfo: '매일, 완료까지 D-10',
      countInfo: '3/5명',
    ),
    ChallengeModel(
      title: '러닝하기',
      status: ChallengeStatus.ongoing,
      progress: 0.7,
      dateInfo: '매일, 완료까지 D-03',
      countInfo: '1/2명',
    ),
    ChallengeModel(
      title: '명상하기',
      status: ChallengeStatus.success,
      progress: 1.0,
      dateInfo: '완료일 2025/12/25',
    ),
    ChallengeModel(
      title: '기상 챌린지',
      status: ChallengeStatus.fail,
      progress: 0.0,
      dateInfo: '실패일 2026/01/15',
    ),
  ];

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
              // --- 나의 챌린지 섹션 (새로 추가됨) ---
              _buildChallengeSection(),
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

  // 나의 챌린지 섹션 (탭 전환 기능 포함)
  Widget _buildChallengeSection() {
    return Container(
      width: double.infinity,
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
                  onTap: () {}, // 더보기 페이지 이동 로직
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
          // 필터 탭 버튼 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatusTab('진행중', ChallengeStatus.ongoing),
                const SizedBox(width: 8),
                _buildStatusTab('완료', ChallengeStatus.success),
                const SizedBox(width: 8),
                _buildStatusTab('실패', ChallengeStatus.fail),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 필터링된 리스트 출력
          _buildChallengeList(),
        ],
      ),
    );
  }

  // 상태 탭 버튼 빌더
  Widget _buildStatusTab(String label, ChallengeStatus status) {
    final bool isSelected = _selectedTab == status;

    // 상태별 선택 시 테마 색상 설정
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
        onTap: () => setState(() => _selectedTab = status),
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

  // 필터링된 챌린지 아이템 리스트 생성
  Widget _buildChallengeList() {
    final filteredList = _allChallenges
        .where((item) => item.status == _selectedTab)
        .toList();

    if (filteredList.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          '챌린지가 없습니다.',
          style: AppTypography.b2.copyWith(color: AppColors.gray3),
        ),
      );
    }

    return Column(
      children: filteredList.asMap().entries.map((entry) {
        return Column(
          children: [
            _buildChallengeCard(entry.value),
            if (entry.key != filteredList.length - 1)
              const Divider(height: 1, color: AppColors.gray4),
          ],
        );
      }).toList(),
    );
  }

  // 챌린지 개별 카드 위젯
  Widget _buildChallengeCard(ChallengeModel item) {
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
                item.status == ChallengeStatus.ongoing ? ' 0일째' : ' 최대 0일',
                style: AppTypography.b2,
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
