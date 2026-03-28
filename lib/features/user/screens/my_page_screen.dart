/// 최초 작성자: 정승빈
/// 작성일: 2026-01-18
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/user/screens/push_notification_settings_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:haenaem/features/notification/services/fcm_service.dart';

import 'package:haenaem/features/user/provider/user_provider.dart';
import 'package:haenaem/shared/models/user.dart';
import 'package:haenaem/shared/models/user_detail.dart';

import 'withdrawal_screen.dart';
import 'challenge_list_screen.dart';
import 'profile_edit_screen.dart';
import '../widgets/profile_header.dart';
import '../widgets/my_page_menu_item.dart';
import '../widgets/challenge_section.dart';
import '../widgets/logout_dialog.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(currentUser),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              if (currentUser != null)
                profileAsync.when(
                  loading: () => ProfileHeader(
                    nickname: currentUser.nickname, // ✅ 닉네임/이미지는 currentUser에서
                    profileImageUrl: currentUser.profileUrl ?? '',
                    introduction: '',
                    tags: const [],
                  ),
                  error: (_, __) => ProfileHeader(
                    nickname: currentUser.nickname,
                    profileImageUrl: currentUser.profileUrl ?? '',
                    introduction: '',
                    tags: const [],
                  ),
                  data: (UserDetail detail) => ProfileHeader(
                    nickname: currentUser.nickname,
                    profileImageUrl: currentUser.profileUrl ?? '',
                    introduction: detail.introduction,
                    tags: detail.tags,
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 40),
              const ChallengeSection(), // 챌린지 섹션 위젯

              const SizedBox(height: 24),
              _buildMenuSection(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(User? currentUser) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 24),
          Text(
            '내 페이지',
            style: AppTypography.h3.copyWith(color: AppColors.black),
          ),
          InkWell(
            onTap: () {
              // 1. 현재 로드된 프로필 데이터를 가져옵니다.
              final profileData = ref.read(myProfileProvider).value;
              if (currentUser != null && profileData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(
                      user: currentUser,
                      detail: profileData,
                    ),
                  ),
                );
              } else {
                // 데이터 로딩 중이거나 에러 시 알림 (선택 사항)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('프로필 정보를 불러오는 중입니다.')),
                );
              }
            },
            child: SvgPicture.asset(
              'assets/images/icons/my_page_edit.svg',
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
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        MyPageMenuItem(
          title: '푸시 알림 설정',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PushNotificationSettingsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        MyPageMenuItem(
          title: '로그아웃',
          onTap: () {
            // 분리된 LogoutDialog 호출
            showDialog(
              context: context,
              builder: (context) => const LogoutDialog(),
            );
          },
        ),
        const SizedBox(height: 10),
        MyPageMenuItem(
          title: '회원 탈퇴',
          textColor: AppColors.notification,
          showArrow: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WithdrawalScreen()),
            );
          },
        ),
      ],
    );
  }
}
