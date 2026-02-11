// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/social/social_model.dart'; // Friend 모델
import 'package:haenaem/features/social/social_repository.dart'; // friendListProvider
import 'package:haenaem/core/utils/korean_string_utils.dart'; // 한글 검색 유틸
import 'package:haenaem/features/challenge/data/challenge_repository.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';

class ChallengeInviteScreen extends ConsumerStatefulWidget {
  // 1. 외부에서 챌린지 ID를 받아오도록 필드 추가
  final int challengeId;

  const ChallengeInviteScreen({
    super.key,
    required this.challengeId, // 필수값 지정
  });

  @override
  ConsumerState<ChallengeInviteScreen> createState() =>
      _ChallengeInviteScreenState();
}

class _ChallengeInviteScreenState extends ConsumerState<ChallengeInviteScreen> {
  // 친구 ID는 서버 모델에 따라 int로 변경 (기존 String)
  final Set<int> _invitedFriends = {};
  final String challengeUrl = "https://challenge.app/room/abc123";

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

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: challengeUrl)).then((_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크가 복사되었습니다.')));
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. API로부터 친구 목록 상태 구독
    final friendListAsync = ref.watch(friendListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/images/icons/arrow_left.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '챌린지 초대',
          style: AppTypography.h3.copyWith(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // 링크 공유 섹션 (회색 박스)
                  _buildLinkShareBox(),
                  const SizedBox(height: 10),
                  // 검색창
                  _buildSearchBar(),
                  const SizedBox(height: 10),

                  // 친구 리스트 (API 데이터 연동)
                  friendListAsync.when(
                    data: (friends) {
                      // 2. 검색 필터링 로직 (닉네임 포함 OR 초성 포함)
                      final filteredFriends = friends.where((friend) {
                        final name =
                            friend.nickname; // 대소문자 구분 없이 비교하기 위해 원본 유지
                        final query = _searchQuery;

                        // 이름에 검색어 포함 or 초성에 검색어 포함
                        return name.toLowerCase().contains(query) ||
                            KoreanStringUtils.getChoseongString(
                              name,
                            ).contains(query);
                      }).toList();

                      // 3. 정렬 로직 (한글 우선 > 영어 > 기타)
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
                            style: AppTypography.b2.copyWith(
                              color: AppColors.gray2,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredFriends.length,
                        itemBuilder: (context, index) {
                          final friend = filteredFriends[index];
                          return _buildFriendInviteItem(friend);
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
                          style: AppTypography.b2.copyWith(
                            color: AppColors.gray2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 하단 여백 추가
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 상단 링크 공유 박스
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
        spacing: 8,
        children: [
          Text(
            '챌린지 링크 공유',
            style: AppTypography.b2.copyWith(color: AppColors.gray1),
          ),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                Expanded(
                  child: Text(
                    challengeUrl,
                    style: AppTypography.c1.copyWith(
                      color: const Color(0xFF3E7E60),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // 버튼 영역
          SizedBox(
            width: double.infinity,
            height: 40, // 버튼 영역 높이 확보
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                // 복사 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: _copyToClipboard,
                    child: Container(
                      height: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: AppColors.gray5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4,
                        children: [
                          SvgPicture.asset(
                            'assets/images/icons/link_copy.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gray2,
                              BlendMode.srcIn,
                            ),
                          ),
                          Text(
                            '복사',
                            textAlign: TextAlign.center,
                            style: AppTypography.b2.copyWith(
                              color: AppColors.gray2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 공유 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // SharePlus.share(challengeUrl);
                    },
                    child: Container(
                      height: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: AppColors.gray5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4,
                        children: [
                          SvgPicture.asset(
                            'assets/images/icons/share_icon.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gray2,
                              BlendMode.srcIn,
                            ),
                          ),
                          Text(
                            '공유',
                            textAlign: TextAlign.center,
                            style: AppTypography.b2.copyWith(
                              color: AppColors.gray2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 내부에서만 사용하는 공통 버튼 UI (통합)
  Widget _buildActionItem({
    required String label,
    required Color color,
    required String iconName,
    required double iconWidth,
    required double iconHeight,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/icons/$iconName',
                  width: iconWidth,
                  height: iconHeight,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(label, style: AppTypography.c1.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // 친구 검색창
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

  // 친구 리스트 아이템 (Friend 모델 사용으로 변경)
  Widget _buildFriendInviteItem(Friend friend) {
    bool isInvited = _invitedFriends.contains(friend.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // 프로필 이미지 처리
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x7FDFE1DC), // 기본 배경색
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
          // 닉네임
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
                        // 2. API 호출
                        // (Provider 이름은 프로젝트 설정에 따라 다를 수 있습니다.
                        //  보통 challengeRepositoryProvider 혹은 challengeProvider 안에 선언된 repository를 사용합니다.)

                        // 예시 1: Repository Provider를 직접 부르는 경우
                        await ref
                            .read(challengeRepositoryProvider)
                            .inviteFriend(
                              widget.challengeId, // 받아온 챌린지 ID 사용
                              friend.nickname,
                            );

                        // 예시 2: Service나 Controller를 거치는 경우라면 해당 메서드 호출

                        // 3. 성공 시 UI 업데이트
                        if (!mounted) return;

                        setState(() => _invitedFriends.add(friend.id));
                        // 2. 안내 팝업 띄우기
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
                            backgroundColor: const Color(
                              0xFF424242,
                            ), // 어두운 회색 (이미지 색상)
                            behavior: SnackBarBehavior.floating, // 하단에서 떠있는 형태
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            duration: const Duration(seconds: 1), // 1초 후 자동 소멸
                            margin: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 30, // 화면 아래쪽 여백 조절
                            ),
                          ),
                        );
                      } catch (e) {
                        // 4. 실패 시 처리
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
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
