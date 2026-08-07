// 최초 작성자: 정승빈

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:haenaem/features/notification/services/fcm_service.dart';

import 'package:haenaem/features/user/provider/user_provider.dart';
import 'package:haenaem/shared/models/user_detail.dart';

import 'profile/profile_edit_screen.dart';
import '../views/profile_header_view.dart';
import '../views/my_challenge_section_view.dart';
import '../views/my_page_menu_view.dart';
import 'package:haenaem/shared/widgets/animated_toast.dart';

class MyPageMainScreen extends ConsumerStatefulWidget {
  const MyPageMainScreen({super.key});

  @override
  ConsumerState<MyPageMainScreen> createState() => _MyPageMainScreenState();
}

class _MyPageMainScreenState extends ConsumerState<MyPageMainScreen> {
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // myProfileProvider가 로딩중일 때
    // 전역 관리하는 currentUserProvider가 닉네임/이미지라도 먼저 가져옴
    final currentUser = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: _buildAppBar(profileAsync.value, appColors),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              if (currentUser != null)
                profileAsync.when(
                  loading: () => ProfileHeaderView(
                    nickname: currentUser.nickname,
                    profileImageUrl: currentUser.profileUrl ?? '',
                    introduction: '',
                    tags: const [],
                  ),
                  error: (_, __) => ProfileHeaderView(
                    nickname: currentUser.nickname,
                    profileImageUrl: currentUser.profileUrl ?? '',
                    introduction: '',
                    tags: const [],
                  ),
                  data: (UserDetail detail) => ProfileHeaderView(
                    // ✅ UserDetail 사용
                    nickname: detail.user.nickname,
                    profileImageUrl: detail.user.profileUrl ?? '',
                    introduction: detail.introduction,
                    tags: detail.tags,
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),

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

  PreferredSizeWidget _buildAppBar(
    UserDetail? detail,
    AppColorsExtension appColors,
  ) {
    return AppBar(
      backgroundColor: appColors.whiteToBlack,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 24),
          Text(
            '내 페이지',
            style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
          ),
          InkWell(
            onTap: () {
              // 1. 현재 로드된 프로필 데이터를 가져옵니다.
              //final profileData = ref.read(myProfileProvider).value;
              if (detail != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(
                      //user: currentUser,
                      detail: detail,
                    ),
                  ),
                );
              } else {
                // 데이터 로딩 중이거나 에러 시 알림
                displayToast(context, '프로필 정보를 불러오는 중입니다.');
              }
            },
            child: SvgPicture.asset(
              'assets/images/icons/my_page_edit.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                appColors.blackToWhite,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
