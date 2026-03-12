/// 최초 작성자: 정승빈 (수정: Gemini)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 추가
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/features/social/screens/friend_edit_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'friend_add_screen.dart';
import '../data/social_repository.dart';
import '../models/social_model.dart';
import '../../../core/utils/korean_string_utils.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod을 통해 친구 목록 프로바이더 구독
    final friendListAsync = ref.watch(friendListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('친구', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/images/icons/friend_add_icon.svg'),
            onPressed: () async {
              // 1. async 키워드 추가
              // 2. await를 사용하여 FriendAddScreen이 닫힐 때까지 기다림
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendAddScreen(),
                ),
              );

              // 3. 화면이 닫히고 돌아오면 친구 목록 Provider를 강제로 새로고침
              ref.invalidate(friendListProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색창 (friend_add_screen.dart 스타일로 수정됨)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gray4), // 연한 회색 테두리
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/icons/search_icon.svg',
                    width: 18,
                    colorFilter: const ColorFilter.mode(
                      AppColors.gray3,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: '친구 검색',
                        hintStyle: AppTypography.b2,
                        border: InputBorder.none, // 기본 TextField 테두리 제거
                        isDense: true, // 텍스트 필드 내부 여백 최소화 (중앙 정렬 도움)
                      ),
                      style: AppTypography.b1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 친구 목록 섹션
          Expanded(
            child: friendListAsync.when(
              data: (totalFriends) {
                // 1. 필터링 및 2. 정렬 로직 적용
                final filteredFriends = totalFriends.where((friend) {
                  final name = friend.nickname.toLowerCase();
                  final query = searchQuery.toLowerCase();
                  return name.contains(query) ||
                      KoreanStringUtils.getChoseongString(name).contains(query);
                }).toList();

                // 가나다순 정렬 추가
                filteredFriends.sort(
                  (a, b) => KoreanStringUtils.compareKoreanFirst(
                    a.nickname,
                    b.nickname,
                  ),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '친구 ${filteredFriends.length}',
                            style: AppTypography.b2,
                          ),
                          GestureDetector(
                            onTap: () async {
                              // 1. async 추가
                              // 2. await로 편집 화면이 닫힐 때까지 대기
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FriendEditScreen(
                                    initialFriends: totalFriends,
                                  ),
                                ),
                              );

                              // 3. 편집 화면에서 돌아오면 친구 목록 새로고침 (삭제 반영)
                              ref.invalidate(friendListProvider);
                            },
                            child: Text(
                              '편집',
                              style: AppTypography.c1.copyWith(
                                color: AppColors.gray2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primaryAble,
                        onRefresh: () async {
                          // 스크롤을 당기면 데이터를 강제로 다시 불러옵니다.
                          return await ref.refresh(friendListProvider.future);
                        },
                        child: filteredFriends.isEmpty
                            ? SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(), // 친구가 없어도 스크롤을 당길 수 있게 설정
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: const Center(child: Text('친구가 없습니다.')),
                                ),
                              )
                            : ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(), // 스크롤이 가능하도록 설정
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: filteredFriends.length,
                                itemBuilder: (context, index) =>
                                    buildFriendTile(filteredFriends[index]),
                              ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  const Center(child: Text('친구 목록을 불러오지 못했습니다.')),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFriendTile(Friend friend) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 프로필 이미지 (NetworkImage 대응)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0x7FDFE1DC),
              shape: BoxShape.circle,
              image:
                  friend.profileImageUrl != null &&
                      friend.profileImageUrl!.startsWith('http')
                  ? DecorationImage(
                      image: NetworkImage(friend.profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : (friend.profileImageUrl != null
                        ? DecorationImage(
                            image: AssetImage(friend.profileImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null),
            ),
            child: friend.profileImageUrl == null
                ? Center(
                    child: SvgPicture.asset(
                      'assets/images/icons/default_profile_icon.svg',
                      width: 24,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.nickname,
                style: AppTypography.h3.copyWith(fontSize: 15),
              ),
              Text(
                "칭호 없음", // Swagger 모델에 맞게 수정 필요 시 변경
                style: AppTypography.c1.copyWith(color: AppColors.gray2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
