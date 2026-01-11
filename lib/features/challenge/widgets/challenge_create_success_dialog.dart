import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart'; // 클립보드 복사
import 'package:share_plus/share_plus.dart'; // 공유

class ChallengeCreateSuccessDialog extends StatefulWidget {
  const ChallengeCreateSuccessDialog({super.key});

  @override
  State<ChallengeCreateSuccessDialog> createState() =>
      _ChallengeCreateSuccessDialogState();
}

class _ChallengeCreateSuccessDialogState
    extends State<ChallengeCreateSuccessDialog> {
  // 초대한 친구들의 이름을 저장하는 Set
  final Set<String> _invitedFriends = {};

  // 나중에 백엔드에서 받아올 실제 URL이 들어감
  final String challengeUrl = "https://challenge.app/room/abc123";

  // 친구 데이터 정의 (나중에 백엔드에서 받아올 데이터 구조)
  final List<Map<String, String>> _allFriends = [
    {'id': 'u1', 'name': '김철수'},
    {'id': 'u2', 'name': '이순신'},
    {'id': 'u3', 'name': '홍길동'},
    {'id': 'u4', 'name': '박지성'},
    {'id': 'u5', 'name': '김연아'},
    {'id': 'u6', 'name': '손흥민'},
  ];

  // 화면에 실제로 보여줄 필터링된 리스트
  List<Map<String, String>> _filteredFriends = [];

  // 검색창 제어를 위한 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 초기에는 전체 친구 목록을 보여줍니다.
    _filteredFriends = _allFriends;

    // 검색창 입력 감지 리스너 추가
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 클립보드 복사 로직
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: challengeUrl)).then((_) {
      // 복사 완료 후 유저에게 알림 (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('링크가 클립보드에 복사되었습니다.'),
          behavior: SnackBarBehavior.floating, // 팝업 위에 떠있게 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  // 공유창 로직
  void _shareChallenge(BuildContext context) async {
    // 클릭된 버튼의 위치와 크기 정보를 가져옵니다 (iPad/태블릿 대응)
    final box = context.findRenderObject() as RenderBox?;

    // 공식 예제의 SharePlus.instance.share 방식 사용
    await SharePlus.instance.share(
      ShareParams(
        text: '[해냄] 새로운 챌린지에 초대받았어요!\n지금 바로 확인해보세요: $challengeUrl',
        subject: '해냄 챌린지 초대',
        // 팝업이 버튼 근처에서 나타나도록 위치 지정
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      ),
    );
  }

  // 검색 로직: 입력값이 바뀔 때마다 리스트를 필터링
  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = _allFriends;
      } else {
        _filteredFriends = _allFriends
            .where((friend) => friend['name']!.toLowerCase().contains(query))
            .toList();
      }
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
            _buildGradientHeader(),

            // 링크 공유 + 친구 초대
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 링크 공유 섹션
                    _buildLinkShareSection(),

                    const SizedBox(height: 10),

                    // 친구 검색창
                    _buildFriendSearchBar(),

                    const SizedBox(height: 10),

                    // ✨ 5. 필터링된 리스트를 화면에 뿌려줍니다.
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
                        (friend) =>
                            _buildInviteItem(friend['name']!, friend['id']!),
                      ),
                  ],
                ),
              ),
            ),
            // 하단 닫기 버튼
            _buildLaterButton(context),
          ],
        ),
      ),
    );
  }

  // 상단 그라데이션 헤더 위젯
  Widget _buildGradientHeader() {
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
  Widget _buildLinkShareSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: AppColors.gray5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                side: BorderSide(width: 1, color: AppColors.gray4), // gray4
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/icons/challenge_create_success_link.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'https://challenge.app/room/abc123',
                    style: AppTypography.c1.copyWith(
                      color: const Color(0xFF3E7E60),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 복사, 공유
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                label: '복사',
                color: const Color(0xFF2B7FFF),
                iconPath: 'assets/images/icons/link_copy.svg',
                // 복사 함수 연결
                onTap: (ctx) => _copyToClipboard(ctx),
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                label: '공유',
                color: const Color(0xFF615FFF),
                iconPath: 'assets/images/icons/link_share.svg',
                // TODO: 링크 공유 로직
                onTap: (ctx) => _shareChallenge(ctx),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 복사/공유 공통 버튼 위젯
  Widget _buildActionButton({
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: ShapeDecoration(
              color: color,
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
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTypography.c1.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 친구 검색창
  Widget _buildFriendSearchBar() {
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

  // 친구 초대 아이템
  Widget _buildInviteItem(String name, String id) {
    bool isInvited = _invitedFriends.contains(id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.gray5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, backgroundColor: Color(0xFFD9D9D9)),
          const SizedBox(width: 10),
          Text(name, style: AppTypography.b2.copyWith(color: AppColors.black)),
          const Spacer(),
          GestureDetector(
            onTap: isInvited
                ? null
                : () {
                    setState(() {
                      _invitedFriends.add(id); // ID 저장
                    });
                  },
            child: isInvited
                ? _buildInvitedButton()
                : _buildActiveInviteButton(),
          ),
        ],
      ),
    );
  }

  // 초대함 버튼
  Widget _buildInvitedButton() {
    return Container(
      width: 54.08,
      height: 33.99,
      decoration: ShapeDecoration(
        color: AppColors.disable, // 해냄-green-disable
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
  Widget _buildActiveInviteButton() {
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
  Widget _buildLaterButton(BuildContext context) {
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
}
