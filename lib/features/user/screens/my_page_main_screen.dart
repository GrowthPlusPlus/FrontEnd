// 최초 작성자: 정승빈

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';

import 'profile_edit_screen.dart'; // 4단계에서 경로 수정 예정
import '../views/profile_header_view.dart';
import '../views/my_challenge_section_view.dart';
import '../views/my_page_menu_view.dart';

class MyPageMainScreen extends ConsumerStatefulWidget {
  const MyPageMainScreen({super.key});

  @override
  ConsumerState<MyPageMainScreen> createState() => _MyPageMainScreenState();
}

class _MyPageMainScreenState extends ConsumerState<MyPageMainScreen> {
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

              // 1. 프로필 헤더 뷰
              profileAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => const Center(child: Text('데이터 로드 실패')),
                data: (profile) => ProfileHeaderView(
                  nickname: profile.nickname,
                  introduction: profile.introduction,
                  profileImageUrl: profile.profileImageUrl,
                  tags: profile.tags,
                ),
              ),

              const SizedBox(height: 40),

              // 2. 나의 챌린지 뷰
              const MyChallengeSectionView(),

              const SizedBox(height: 24),

              // 3. 하단 설정 메뉴 뷰
              const MyPageMenuView(),

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
                // 데이터 로딩 중이거나 에러 시 알림
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
}
