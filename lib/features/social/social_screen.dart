/// 최초 작성자: 정승빈 (수정: Gemini)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 추가
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/features/social/friend_edit_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'friend_add_screen.dart';
import 'social_repository.dart';
import 'social_model.dart';

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

  // 한글 초성 검색 로직 (기존 유지)
  static const int HANGEUL_BASE = 0xAC00;
  static const List<String> CHOSEONG_LIST = [
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ];

  String getChoseong(String text) {
    String result = "";
    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      if (charCode >= HANGEUL_BASE && charCode <= 0xD7A3) {
        int index = (charCode - HANGEUL_BASE) ~/ 588;
        result += CHOSEONG_LIST[index];
      } else {
        result += text[i];
      }
    }
    return result;
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
        title: const Text('소셜', style: AppTypography.h3),
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
              ref.refresh(friendListProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: '내 친구 검색',
                hintStyle: AppTypography.b2.copyWith(color: AppColors.gray2),
                prefixIcon: const Icon(Icons.search, color: AppColors.gray2),
                filled: true,
                fillColor: const Color(0x7FDFE1DC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 친구 목록 섹션
          Expanded(
            child: friendListAsync.when(
              data: (totalFriends) {
                // 검색어에 따른 필터링 로직
                final filteredFriends = totalFriends.where((friend) {
                  final name = friend.nickname.toLowerCase();
                  final query = searchQuery.toLowerCase();
                  return name.contains(query) ||
                      getChoseong(name).contains(query);
                }).toList();

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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FriendEditScreen(
                                    initialFriends: totalFriends,
                                  ),
                                ),
                              );
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
                      child: filteredFriends.isEmpty
                          ? const Center(child: Text('친구가 없습니다.'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: filteredFriends.length,
                              itemBuilder: (context, index) =>
                                  buildFriendTile(filteredFriends[index]),
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
