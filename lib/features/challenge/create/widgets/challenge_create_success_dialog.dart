// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart'; // 클립보드 복사
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:share_plus/share_plus.dart'; // 공유

// 챌린지 생성 성공했을 경우 띄우는 작은 화면
class ChallengeCreateSuccessDialog extends StatefulWidget {
  final String challengeLink;
  final List<FriendModel> friends;

  const ChallengeCreateSuccessDialog({
    super.key,
    required this.challengeLink,
    required this.friends,
  });

  @override
  State<ChallengeCreateSuccessDialog> createState() =>
      _ChallengeCreateSuccessDialogState();
}

// 챌린지 생성 성공 화면의 로직 및 상태 관리 클래스
class _ChallengeCreateSuccessDialogState
    extends State<ChallengeCreateSuccessDialog> {
  final Set<int> _invitedFriends = {}; // 초대한 친구들의 이름을 저장하는 Set

  List<FriendModel> _filteredFriends = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 3. 부모로부터 받은 실제 친구 목록으로 초기화
    _filteredFriends = widget.friends;
    _searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 검색 로직: 입력값이 바뀔 때마다 리스트를 필터링
  void onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = widget.friends;
      } else {
        _filteredFriends = widget.friends
            .where((friend) => friend.nickname.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  // 클립보드 복사 로직
  void copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.challengeLink)).then((_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크가 클립보드에 복사되었습니다.')));
    });
  }

  // 공유창 로직
  void shareChallenge(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: '[해냄] 새로운 챌린지에 초대받았어요!\n${widget.challengeLink}',
        subject: '해냄 챌린지 초대',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      ),
    );
  }

  // 초대 버튼 누를 경우 뜨는 토스트 메시지
  void _showToast(BuildContext context, String name) {
    // 토스트 위젯 생성
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: ShapeDecoration(
                color: const Color(0xff1B1D1B).withAlpha(200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '$name 님에게 챌린지 초대를 보냈습니다!',
                textAlign: TextAlign.center,
                style: AppTypography.b1.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    // 화면에 추가
    Overlay.of(context).insert(overlayEntry);

    // 2초 후 자동으로 사라지게 설정
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: const Alignment(0, -0.3),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        height: 600,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // 상단 그라데이션 헤더
            buildGradientHeader(),

            // 링크 공유 + 친구 초대
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 링크 공유 섹션
                    buildLinkShareSection(),

                    const SizedBox(height: 10),

                    // 친구 검색창
                    buildFriendSearchBar(),

                    const SizedBox(height: 10),

                    // 필터링된 리스트를 화면에 보여주기
                    if (_filteredFriends.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            '검색 결과가 없습니다.',
                            style: AppTypography.b2.copyWith(
                              color: AppColors.gray3,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._filteredFriends.map(
                        (friend) => buildInviteItem(friend),
                      ),
                  ],
                ),
              ),
            ),
            // 하단 닫기 버튼
            buildLaterButton(context),
          ],
        ),
      ),
    );
  }

  // 상단 그라데이션 헤더 위젯
  Widget buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF009951), Color(0xFF00C94D)],
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/icons/challenge_create_success_check.svg',
            width: 44,
            height: 44,
          ),
          const SizedBox(height: 12),
          Text(
            '챌린지 생성 완료!',
            style: AppTypography.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '친구들을 초대해서 함께 도전해보세요',
            style: AppTypography.b1.copyWith(
              color: Colors.white.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  // 링크 공유 섹션
  Widget buildLinkShareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '챌린지 링크 공유',
          style: AppTypography.b2.copyWith(color: AppColors.gray1),
        ),
        const SizedBox(height: 8),
        // 링크 주소 입력 박스 스타일
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: AppColors.gray4), // gray4
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            widget.challengeLink,
            style: AppTypography.c1.copyWith(color: const Color(0xFF3E7E60)),
          ),
        ),
        const SizedBox(height: 8),
        // 복사, 공유
        Row(
          //mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: buildActionButton(
                label: '복사',
                color: AppColors.gray5,
                iconPath: 'assets/images/icons/link_copy.svg',
                // 복사 함수 연결
                onTap: (ctx) => copyToClipboard(ctx),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildActionButton(
                label: '공유',
                color: AppColors.gray5,
                iconPath: 'assets/images/icons/link_share.svg',
                // TODO: 링크 공유 로직
                onTap: (ctx) => shareChallenge(ctx),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 복사/공유 공통 버튼 위젯
  Widget buildActionButton({
    required String label,
    required Color color,
    required String iconPath,
    required Function(BuildContext) onTap, // context를 받는 함수
  }) {
    return Builder(
      // 렌더링 위치를 잡기 위해 Builder 추가
      builder: (context) {
        return GestureDetector(
          onTap: () => onTap(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 8),
            decoration: ShapeDecoration(
              color: AppColors.gray5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
      },
    );
  }

  // 친구 검색창
  Widget buildFriendSearchBar() {
    return Container(
      width: double.infinity,
      height: 37.98,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.gray3),
          borderRadius: BorderRadius.circular(9.50),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 검색 아이콘
          SvgPicture.asset(
            'assets/images/icons/friend_search.svg',
            width: 18.99,
            height: 18.99,
          ),
          const SizedBox(width: 8),
          // 실제 검색 입력 영역
          Expanded(
            child: TextField(
              controller: _searchController,
              style: AppTypography.b2.copyWith(color: AppColors.black),
              decoration: InputDecoration(
                hintText: '친구 검색',
                hintStyle: AppTypography.b2.copyWith(color: AppColors.gray3),
                border: InputBorder.none,
                isDense: true, // 높이 압축
                contentPadding: EdgeInsets.zero, // 내부 여백 제거로 중앙 정렬 보정
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 친구 초대 아이템 위젯 수정 (FriendModel을 받도록)
  Widget buildInviteItem(FriendModel friend) {
    bool isInvited = _invitedFriends.contains(friend.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFD9D9D9),
            backgroundImage: friend.profileImageUrl != null
                ? NetworkImage(friend.profileImageUrl!)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            friend.nickname,
            style: AppTypography.b2.copyWith(color: AppColors.black),
          ),
          const Spacer(),
          GestureDetector(
            onTap: isInvited
                ? null
                : () {
                    setState(() => _invitedFriends.add(friend.id));
                    _showToast(context, friend.nickname);
                  },
            child: isInvited ? buildInvitedButton() : buildActiveInviteButton(),
          ),
        ],
      ),
    );
  }
}

// 초대함 버튼
Widget buildInvitedButton() {
  return Container(
    width: 54.08,
    height: 33.99,
    decoration: ShapeDecoration(
      color: AppColors.disable,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Center(
      child: Text(
        '초대함',
        textAlign: TextAlign.center,
        style: AppTypography.c1.copyWith(color: AppColors.gray2),
      ),
    ),
  );
}

// 초대 전 버튼
Widget buildActiveInviteButton() {
  return Container(
    width: 54.08,
    height: 33.99,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.primaryAble,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('초대', style: AppTypography.c1.copyWith(color: Colors.white)),
  );
}

// 나중에 초대하기 버튼
Widget buildLaterButton(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '나중에 초대하기',
          style: AppTypography.b1.copyWith(color: AppColors.gray2),
        ),
      ),
    ),
  );
}
