// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../core/utils/korean_string_utils.dart';
import '../../../shared/models/user.dart';
import '../provider/friend_list_provider.dart';
import '../widgets/friend_list_tile.dart';
import 'friend_add_screen.dart';
import 'friend_edit_screen.dart';
import 'package:haenaem/shared/widgets/custom_search_bar.dart';

class SocialMainScreen extends ConsumerStatefulWidget {
  const SocialMainScreen({super.key});

  @override
  ConsumerState<SocialMainScreen> createState() => _SocialMainScreenState();
}

class _SocialMainScreenState extends ConsumerState<SocialMainScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    // 새로운 Provider 구독
    final friendListAsync = ref.watch(friendListProvider);

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: _buildAppBar(context, appColors),
      body: Column(
        children: [
          _buildSearchBar(),
          // 친구 목록 섹션
          Expanded(
            child: friendListAsync.when(
              data: (totalFriends) {
                // 1. 검색 필터링
                final filteredFriends = totalFriends.where((user) {
                  final name = user.nickname.toLowerCase();
                  final query = searchQuery.toLowerCase();
                  return name.contains(query) ||
                      KoreanStringUtils.getChoseongString(name).contains(query);
                }).toList();

                // 2. 가나다순 정렬
                filteredFriends.sort(
                  (a, b) => KoreanStringUtils.compareKoreanFirst(
                    a.nickname,
                    b.nickname,
                  ),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildListHeader(
                      filteredFriends.length,
                      totalFriends,
                      appColors,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: appColors.primaryAble,
                        onRefresh: () async {
                          // 스크롤을 당기면 데이터를 강제로 다시 불러옵니다.
                          return await ref.refresh(friendListProvider.future);
                        },
                        // 친구 목록이 비어있을 때 빈 상태 표시, 그렇지 않으면 친구 목록 표시
                        child: filteredFriends.isEmpty
                            ? _buildEmptyState()
                            : _buildFriendList(filteredFriends),
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

  // AppBar 위젯을 별도의 메서드로 분리
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppColorsExtension appColors,
  ) {
    return AppBar(
      backgroundColor: appColors.whiteToBlack,
      elevation: 0,
      centerTitle: true,
      title: const Text('친구', style: AppTypography.h3),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/friend_add_icon.svg',
            colorFilter: ColorFilter.mode(
              appColors.blackToWhite,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () async {
            // await를 사용하여 FriendAddScreen이 닫힐 때까지 기다림
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FriendAddScreen()),
            );

            if (!mounted) return;

            // 화면이 닫히고 돌아오면 친구 목록 Provider를 강제로 새로고침
            ref.invalidate(friendListProvider);
          },
        ),
      ],
    );
  }

  // 검색 바 위젯
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: CustomSearchBar(
        controller: searchController,
        hintText: '친구 검색',
        onChanged: (value) => setState(() => searchQuery = value),
      ),
    );
  }

  // 친구 목록 헤더 위젯
  Widget _buildListHeader(
    int count,
    List<User> totalFriends,
    AppColorsExtension appColors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('친구 $count', style: AppTypography.b2),
          GestureDetector(
            onTap: () async {
              // await로 편집 화면이 닫힐 때까지 대기
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FriendEditScreen(initialFriends: totalFriends),
                ),
              );

              if (!mounted) return;

              // 편집 화면에서 돌아오면 친구 목록 새로고침 (삭제 반영)
              ref.invalidate(friendListProvider);
            },
            child: Text(
              '편집',
              style: AppTypography.c1.copyWith(color: appColors.gray2),
            ),
          ),
        ],
      ),
    );
  }

  // 친구가 없을 때 보여줄 빈 상태 위젯
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: const Center(child: Text('친구가 없습니다.')),
      ),
    );
  }

  // 친구 목록을 보여주는 위젯
  Widget _buildFriendList(List<User> filteredFriends) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // 스크롤이 가능하도록 설정
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredFriends.length,
      itemBuilder: (context, index) =>
          FriendListTile(user: filteredFriends[index]),
    );
  }
}
