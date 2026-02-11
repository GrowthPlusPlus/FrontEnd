import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/social/social_model.dart';
import 'package:haenaem/features/social/social_repository.dart';
import 'package:haenaem/core/utils/korean_string_utils.dart';
import 'package:haenaem/features/challenge/data/challenge_repository.dart';
// import 'package:share_plus/share_plus.dart';

// [공통 위젯] 챌린지 초대 본문 (링크 공유 + 친구 검색 + 리스트)
class ChallengeInviteContent extends ConsumerStatefulWidget {
  final int challengeId;
  final String challengeUrl; // 링크 공유용

  const ChallengeInviteContent({
    super.key,
    required this.challengeId,
    this.challengeUrl = "https://challenge.app/room/abc123", // 기본값
  });

  @override
  ConsumerState<ChallengeInviteContent> createState() =>
      _ChallengeInviteContentState();
}

class _ChallengeInviteContentState
    extends ConsumerState<ChallengeInviteContent> {
  final Set<int> _invitedFriends = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // 클립보드 복사
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.challengeUrl)).then((_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크가 복사되었습니다.')));
    });
  }

  @override
  Widget build(BuildContext context) {
    // API로부터 친구 목록 상태 구독
    final friendListAsync = ref.watch(friendListProvider);

    return Column(
      children: [
        // 1. 링크 공유 섹션
        _buildLinkShareBox(),
        const SizedBox(height: 10),

        // 2. 검색창
        _buildSearchBar(),
        const SizedBox(height: 10),

        // 3. 친구 리스트 (API 데이터 연동)
        Expanded(
          child: friendListAsync.when(
            data: (friends) {
              // 검색 필터링
              final filteredFriends = friends.where((friend) {
                final name = friend.nickname;
                final query = _searchQuery;
                return name.toLowerCase().contains(query) ||
                    KoreanStringUtils.getChoseongString(name).contains(query);
              }).toList();

              // 정렬
              filteredFriends.sort(
                (a, b) => KoreanStringUtils.compareKoreanFirst(
                  a.nickname,
                  b.nickname,
                ),
              );

              if (filteredFriends.isEmpty) {
                return Container(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    friends.isEmpty ? '친구가 없습니다.' : '검색 결과가 없습니다.',
                    style: AppTypography.b2.copyWith(color: AppColors.gray2),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true, // 필요 시 추가
                // 검색창도 같이 스크롤 되어 올라감
                // physics: const NeverScrollableScrollPhysics(), // 필요 시 추가
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  return _buildFriendInviteItem(filteredFriends[index]);
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Center(
                child: Text(
                  '친구 목록을 불러오지 못했습니다.',
                  style: AppTypography.b2.copyWith(color: AppColors.gray2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 링크 공유 박스 UI
  Widget _buildLinkShareBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '챌린지 링크 공유',
            style: AppTypography.b2.copyWith(color: AppColors.gray1),
          ),
          const SizedBox(height: 8),
          // 링크 표시창
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: AppColors.gray4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              widget.challengeUrl,
              style: AppTypography.c1.copyWith(color: const Color(0xFF3E7E60)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          // 버튼 영역
          SizedBox(
            height: 40, // 버튼 영역 높이 확보
            child: Row(
              children: [
                Expanded(
                  child: _buildActionItem(
                    label: '복사',
                    color: AppColors.gray5,
                    iconPath: 'assets/images/icons/link_copy.svg',
                    onTap: _copyToClipboard,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionItem(
                    label: '공유',
                    color: AppColors.gray5,
                    iconPath: 'assets/images/icons/share_icon.svg',
                    onTap: () {
                      // TODO: SharePlus 등 공유 로직
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 공통 버튼 아이템 빌더 (아이콘 + 텍스트)
  Widget _buildActionItem({
    required String label,
    required Color color,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.gray2,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.b2.copyWith(color: AppColors.gray2),
            ),
          ],
        ),
      ),
    );
  }

  // 검색창 UI
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        isDense: true,
        hintText: '친구 검색',
        hintStyle: AppTypography.b2.copyWith(color: AppColors.gray3),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14.0),
          child: SvgPicture.asset('assets/images/icons/search_icon.svg'),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray4),
        ),
      ),
    );
  }

  // 친구 리스트 아이템 + 실제 API 로직
  Widget _buildFriendInviteItem(Friend friend) {
    bool isInvited = _invitedFriends.contains(friend.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x7FDFE1DC),
              image:
                  friend.profileImageUrl != null &&
                      friend.profileImageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(friend.profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child:
                friend.profileImageUrl == null ||
                    friend.profileImageUrl!.isEmpty
                ? Center(
                    child: SvgPicture.asset(
                      'assets/images/icons/default_profile_icon.svg',
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(friend.nickname, style: AppTypography.b2),
          const Spacer(),

          // 초대 버튼
          SizedBox(
            width: 70,
            height: 36,
            child: ElevatedButton(
              onPressed: isInvited
                  ? null
                  : () async {
                      try {
                        // ★ API 호출 복구 완료
                        await ref
                            .read(challengeRepositoryProvider)
                            .inviteFriend(widget.challengeId, friend.nickname);

                        if (!mounted) return;
                        setState(() => _invitedFriends.add(friend.id));

                        // ★ 커스텀 스낵바 디자인 복구 완료
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${friend.nickname} 님에게 챌린지 초대를 보냈습니다!',
                                  style: AppTypography.b2.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF424242),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            duration: const Duration(seconds: 1),
                            margin: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 30,
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('초대 전송에 실패했습니다. 다시 시도해주세요.'),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isInvited
                    ? AppColors.disable
                    : AppColors.primaryAble,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                isInvited ? '초대됨' : '초대',
                style: AppTypography.c1.copyWith(
                  color: isInvited ? AppColors.gray2 : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
