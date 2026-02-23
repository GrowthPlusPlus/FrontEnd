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
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/notification/services/fcm_service.dart';

import 'package:haenaem/shared/models/tag_data.dart';
import 'withdrawal_screen.dart';
import 'challenge_list_screen.dart';
import 'profile_edit_screen.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';
import 'package:haenaem/features/auth/signup/screens/auth_gate.dart';

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
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              profileAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => const Center(child: Text('데이터 로드 실패')),
                data: (profile) => ProfileHeader(
                  nickname: profile.nickname,
                  introduction: profile.introduction,
                  profileImageUrl: profile.profileImageUrl,
                  tags: profile.tags,
                ),
              ),

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

  PreferredSizeWidget _buildAppBar() {
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

              // 2. 데이터가 있을 때만 화면 이동 (null 체크)
              if (profileData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileEditScreen(profile: profileData),
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
            /* 탈퇴 페이지 이동 */
          },
        ),
      ],
    );
  }
}
