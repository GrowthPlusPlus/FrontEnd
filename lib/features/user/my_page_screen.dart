/// 최초 작성자: 정승빈
/// 작성일: 2026-01-18
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';

import 'withdrawal_screen.dart';
import 'challenge_list_screen.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';
import 'package:haenaem/features/auth/signup/screens/auth_gate.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  // 💡 ChallengeStatus 대신 MyPageTab을 사용하여 탭 충돌 해결!
  MyPageTab selectedTab = MyPageTab.inProgress;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        title: SizedBox(
          width: double.infinity,
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 왼쪽: 좌우 균형을 위한 더미 공간 (24px)
              const SizedBox(width: 24),

              // 중앙: 타이틀
              Text(
                '내 페이지',
                style: AppTypography.h3.copyWith(color: AppColors.black),
              ),

              // 오른쪽: 설정 아이콘
              InkWell(
                onTap: () {
                  // TODO: 설정 페이지 이동 로직
                },
                child: SvgPicture.asset(
                  'assets/images/icons/settings.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 사용자 프로필 섹션
              profileAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const Text('프로필 로드 실패'),
                data: (profile) => Column(
                  children: [
                    _buildProfileImage(profile.profileImageUrl), // 이미지 URL 전달
                    const SizedBox(height: 17),
                    _buildProfileInfo(profile.nickname, isName: true), // 닉네임 전달
                    const SizedBox(height: 2),
                    _buildProfileInfo(profile.introduction, isName: false),
                    const SizedBox(height: 17),
                    _buildTagList(profile.tags),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildChallengeSection(), // 나의 챌린지 영역
              const SizedBox(height: 16),
              _buildMenuItem(
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
              const SizedBox(height: 10),
              _buildMenuItem(
                title: '로그아웃',
                textColor: AppColors.black,
                onTap: () => _showLogoutDialog(context),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagList(List<String> tags) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10, // 가로 간격
      runSpacing: 8, // 세로 간격 (줄바꿈 시)
      alignment: WrapAlignment.center,
      children: tags
          .map(
            (tag) => Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: ShapeDecoration(
                color: AppColors.selected,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag,
                    style: AppTypography.b2.copyWith(
                      color: AppColors.primaryAble,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // --- 챌린지 섹션 구성 (헤더 + 탭 + 리스트) ---

  Widget _buildChallengeSection() {
    return Container(
      width: double.infinity,
      //clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray4, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.gray5,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '나의 챌린지',
                      style: AppTypography.h3.copyWith(color: Colors.black),
                    ),
                    _buildMoreButton(),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStatusTabs(), // 탭 버튼 영역
              ],
            ),
          ),

          // 구분선
          const Divider(height: 1, color: AppColors.gray4),

          // 하단 흰색 영역 (실제 리스트)
          _buildChallengeList(),
        ],
      ),
    );
  }

  // 더보기 버튼
  Widget _buildMoreButton() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChallengeListScreen()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('더보기', style: AppTypography.b1.copyWith(color: AppColors.gray3)),
          SvgPicture.asset(
            'assets/images/icons/right_arrow_icon.svg',
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }

  // 진행중/완료/실패 탭 바
  Widget _buildStatusTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          _buildTabButton(
            '진행중',
            MyPageTab.inProgress,
            'assets/images/icons/inprogress.svg',
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            '완료',
            MyPageTab.success,
            'assets/images/icons/success_check.svg',
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            '실패',
            MyPageTab.fail,
            'assets/images/icons/fail_circle.svg',
          ),
        ],
      ),
    );
  }

  // 개별 탭 버튼 위젯
  Widget _buildTabButton(String label, MyPageTab tab, String svgPath) {
    final bool isSelected = selectedTab == tab;
    Color activeColor = tab == MyPageTab.inProgress
        ? AppColors.blue
        : (tab == MyPageTab.success
              ? AppColors.primaryAble
              : AppColors.notification);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: isSelected ? null : Border.all(color: AppColors.gray4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : AppColors.gray3,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.b2.copyWith(
                  color: isSelected ? Colors.white : AppColors.gray3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // API 연동 리스트 출력
  Widget _buildChallengeList() {
    final challengesAsync = switch (selectedTab) {
      MyPageTab.inProgress => ref.watch(
        myInProgressChallengesProvider(onlyTwo: true),
      ),
      MyPageTab.success => ref.watch(
        mySuccessChallengesProvider(onlyTwo: true),
      ),
      MyPageTab.fail => ref.watch(myFailedChallengesProvider(onlyTwo: true)),
    };

    return challengesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => const Center(child: Text('데이터 로드 실패')),
      data: (list) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: list.isEmpty
              ? Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: const Text(
                    '해당하는 챌린지가 없습니다.',
                    style: TextStyle(color: AppColors.gray2),
                  ),
                )
              : Column(
                  children: list.asMap().entries.map((entry) {
                    final item = entry.value;
                    final isLast = entry.key == (list.length - 1);
                    return Column(
                      children: [
                        _buildChallengeCard(item),
                        if (!isLast)
                          Divider(
                            height: 1,
                            color: AppColors.gray5,
                            indent: 0,
                            endIndent: 0,
                          ),
                      ],
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  // 개별 챌린지 카드 (배경을 투명하게 하여 테두리와 충돌 방지)
  Widget _buildChallengeCard(ChallengeInProgressModel item) {
    Color themeColor;
    String statusText;
    final serverStatus = item.status.toUpperCase();

    if (serverStatus == "SUCCESS") {
      themeColor = AppColors.primaryAble;
      statusText = '완료';
    } else if (serverStatus == "FAIL" || serverStatus == "FAILED") {
      themeColor = AppColors.notification;
      statusText = '실패';
    } else {
      themeColor = AppColors.blue;
      statusText = '진행중';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.transparent, // 카드의 배경을 투명하게 설정 (부모의 흰색 배경 사용)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 제목 그룹
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: AppTypography.b3.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: ShapeDecoration(
                            color: themeColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: AppTypography.c1.copyWith(color: themeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.dateInfo,
                      style: AppTypography.b2.copyWith(color: AppColors.gray2),
                    ),
                  ],
                ),
              ),
              // 오른쪽 끝: 달성률 수치 및 텍스트
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(item.progress * 100).toInt()}%',
                    style: AppTypography.h2.copyWith(color: themeColor),
                  ),
                  Text(
                    '달성률',
                    style: AppTypography.c1.copyWith(color: AppColors.gray2),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          // 하단: 불 아이콘 + 인원
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/icons/small_fire_icon.svg',
                width: 16,
              ),
              const SizedBox(width: 2),
              Text(
                '${item.duringDate}일째',
                style: AppTypography.b2.copyWith(color: AppColors.black),
              ),
              const SizedBox(width: 12),
              if (serverStatus == "IN_PROGRESS") ...[
                SvgPicture.asset(
                  'assets/images/icons/mini_success_icon.svg',
                  width: 16,
                ),
                const SizedBox(width: 2),
                Text(
                  item.countInfo,
                  style: AppTypography.b2.copyWith(color: AppColors.black),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
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

  // --- 기존 UI 컴포넌트 정리 (디자인 + SVG 입히기) ---

  Widget _buildProfileImage(String imageUrl) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: const BoxDecoration(
            color: Color(0xFFDFE1DC),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : SvgPicture.asset(
                    'assets/images/placeholders/default_profile.svg',
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(String text, {required bool isName}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: isName
              ? AppTypography.h2
              : AppTypography.b1.copyWith(color: AppColors.gray3),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.gray5,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.b1.copyWith(color: textColor)),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthGate()),
                  (route) => false,
                );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
