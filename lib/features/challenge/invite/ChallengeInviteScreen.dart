// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
// import 'package:share_plus/share_plus.dart';

class ChallengeInviteScreen extends StatefulWidget {
  const ChallengeInviteScreen({super.key});

  @override
  State<ChallengeInviteScreen> createState() => _ChallengeInviteScreenState();
}

class _ChallengeInviteScreenState extends State<ChallengeInviteScreen> {
  final Set<String> _invitedFriends = {};
  final String challengeUrl = "https://challenge.app/room/abc123";

  // 이미지에 나온 예시 데이터 반영
  final List<Map<String, String>> _allFriends = [
    {'id': 'u1', 'name': '김철수'},
    {'id': 'u2', 'name': '다'},
    {'id': 'u3', 'name': '을지문덕'},
    {'id': 'u4', 'name': '이순신'},
    {'id': 'u5', 'name': '홍길동'},
    {'id': 'u6', 'name': '김철'},
    {'id': 'u7', 'name': '다라'},
    {'id': 'u8', 'name': '을지'},
    {'id': 'u9', 'name': '이순'},
    {'id': 'u10', 'name': '홍'},
  ];

  List<Map<String, String>> _filteredFriends = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredFriends = _allFriends;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = _allFriends
          .where((friend) => friend['name']!.toLowerCase().contains(query))
          .toList();
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
                  // 친구 리스트
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredFriends.length,
                    itemBuilder: (context, index) {
                      final friend = _filteredFriends[index];
                      return _buildFriendInviteItem(
                        friend['name']!,
                        friend['id']!,
                      );
                    },
                  ),
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

  // 친구 리스트 아이템
  Widget _buildFriendInviteItem(String name, String id) {
    bool isInvited = _invitedFriends.contains(id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            child: SvgPicture.asset(
              'assets/images/icons/default_profile_icon.svg',
            ),
          ),
          const SizedBox(width: 10),
          Text(name, style: AppTypography.b2),
          const Spacer(),
          SizedBox(
            width: 70,
            height: 36,
            child: ElevatedButton(
              onPressed: isInvited
                  ? null
                  : () {
                      // 1. 상태 변경
                      setState(() => _invitedFriends.add(id));

                      // 2. 안내 팝업 띄우기
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$name 님에게 챌린지 초대를 보냈습니다!',
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
