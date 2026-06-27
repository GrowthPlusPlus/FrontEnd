// 최초 작성자 : 정승빈

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/core/utils/korean_string_utils.dart';
import 'package:haenaem/features/challenge/invite/data/challenge_invite_repository.dart';
import '../provider/challenge_invite_provider.dart';
// import 'package:haenaem/features/notification/provider/notification_provider.dart';
import '../models/invite_friend.dart';
// import 'package:haenaem/features/challenge/data/challenge_repository.dart';
// import 'package:haenaem/features/challenge/models/challenge_model.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:haenaem/shared/widgets/animated_toast.dart';

// [공통 위젯] 챌린지 초대 본문 (링크 공유 + 친구 검색 + 리스트)
class ChallengeInviteContent extends ConsumerStatefulWidget {
  final int challengeId;
  final String challengeUrl; // 링크 공유용

  const ChallengeInviteContent({
    super.key,
    required this.challengeId,
    this.challengeUrl = "https://challenge.app/room/loading...", // 기본값
  });

  @override
  ConsumerState<ChallengeInviteContent> createState() =>
      _ChallengeInviteContentState();
}

class _ChallengeInviteContentState
    extends ConsumerState<ChallengeInviteContent> {
  // 이 화면에서 "새로" 초대한 친구들의 ID를 저장 (낙관적 UI 업데이트용)
  final Set<int> _newlyInvitedFriends = {};

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

  // 클립보드 복사 (API에서 받은 최신 링크 사용)
  void _copyToClipboard(String currentLink) {
    Clipboard.setData(ClipboardData(text: currentLink)).then((_) {
      if (!mounted) return;
      displayCopyToast(context, '링크가 복사되었습니다.');
    });
  }

  @override
  Widget build(BuildContext context) {
    // 챌린지 전용 초대 정보 Provider 사용
    final inviteInfoAsync = ref.watch(
      challengeInviteProvider(widget.challengeId),
    );

    // [디버깅 로그] 현재 상태 찍어보기
    debugPrint('🎨 [UI 상태] $inviteInfoAsync');

    return inviteInfoAsync.when(
      data: (info) {
        debugPrint('📋 [UI 데이터 수신] 전체 친구: ${info.friends.length}명');

        return Column(
          children: [
            // 1. 링크 공유 섹션 (API에서 받아온 링크 사용)
            _buildLinkShareBox(info.challengeLink),
            const SizedBox(height: 10),

            // 2. 검색창
            _buildSearchBar(),
            const SizedBox(height: 10),

            // 3. 친구 리스트 (API 데이터 + 검색 필터링)
            Expanded(child: _buildFriendList(info.friends)),
          ],
        );
      },
      // 로딩 중일 때도 기본 UI 틀은 보여줌 (링크는 생성자 값 사용)
      loading: () {
        debugPrint('⏳ [UI 로딩 중...]');
        return Column(
          children: [
            _buildLinkShareBox(widget.challengeUrl),
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 50),
            const CircularProgressIndicator(),
          ],
        );
      },
      error: (err, stack) {
        debugPrint('💥 [UI 에러] $err');
        return Center(
          child: Text(
            '정보를 불러오지 못했습니다.',
            style: AppTypography.b2.copyWith(color: AppColors.gray2),
          ),
        );
      },
    );
  }

  // 친구 리스트 빌더 메서드 분리
  Widget _buildFriendList(List<InviteFriend> friends) {
    debugPrint('🔍 [검색어] "$_searchQuery"');
    // 검색 필터링
    final filteredFriends = friends.where((friend) {
      final name = friend.nickname;
      final query = _searchQuery;
      return name.toLowerCase().contains(query) ||
          KoreanStringUtils.getChoseongString(name).contains(query);
    }).toList();

    debugPrint('✨ [필터링 결과] ${filteredFriends.length}명 표시됨');

    // 정렬 (가나다순)
    filteredFriends.sort(
      (a, b) => KoreanStringUtils.compareKoreanFirst(a.nickname, b.nickname),
    );

    if (filteredFriends.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 50),
        child: Text(
          friends.isEmpty ? '초대할 수 있는 친구가 없습니다.' : '검색 결과가 없습니다.',
          style: AppTypography.b2.copyWith(color: AppColors.gray2),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredFriends.length,
      itemBuilder: (context, index) {
        return _buildFriendInviteItem(filteredFriends[index]);
      },
    );
  }

  // 링크 공유 박스 UI
  Widget _buildLinkShareBox(String link) {
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
              link,
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
                    onTap: () => _copyToClipboard(link),
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
  Widget _buildFriendInviteItem(InviteFriend friend) {
    // 1. 서버에서 온 상태(friend.isInvited)이거나
    // 2. 방금 내가 버튼 눌러서 초대한 상태(_newlyInvitedFriends 포함)인지 확인
    bool isInvited =
        friend.isInvited || _newlyInvitedFriends.contains(friend.id);

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
              image: friend.profileUrl != null && friend.profileUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(friend.profileUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: friend.profileUrl == null || friend.profileUrl!.isEmpty
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
                            .read(challengeInviteRepositoryProvider)
                            .inviteFriend(widget.challengeId, friend.nickname);

                        if (!mounted) return;

                        // 성공 시 '새로 초대된 목록'에 추가하여 버튼 비활성화 (낙관적 업데이트)
                        setState(() => _newlyInvitedFriends.add(friend.id));

                        // 커스텀 Toast 사용
                        displayToast(
                          context,
                          '${friend.nickname} 님에게 챌린지 초대를 보냈습니다!',
                        );
                      } catch (e) {
                        if (!mounted) return;
                        displayToast(context, '초대 전송에 실패했습니다. 다시 시도해주세요.');
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
