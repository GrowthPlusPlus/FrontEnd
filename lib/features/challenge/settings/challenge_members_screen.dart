/// 최초 작성자: 정승빈
library;

import 'package:flutter/material.dart';
import 'package:haenaem/features/challenge/data/challenge_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:haenaem/core/utils/korean_string_utils.dart';
import 'package:haenaem/features/challenge/model/user_model.dart';
import 'package:haenaem/features/challenge/provider/challenge_member_provider.dart';
import 'widgets/kick_confirm_dialog.dart';

// 1. StatefulWidget으로 변경 (검색어 상태 관리를 위해)
class ChallengeMemberManagementScreen extends ConsumerStatefulWidget {
  final int challengeId;

  const ChallengeMemberManagementScreen({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeMemberManagementScreen> createState() =>
      _ScreenState();
}

class _ScreenState extends ConsumerState<ChallengeMemberManagementScreen> {
  // 2. 검색어 상태 변수
  String? _searchQuery;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 멤버 강퇴 처리 함수
  Future<void> _handleKickMember(int targetUserId, String nickname) async {
    try {
      // 1. Repository 메서드 호출 (강퇴 요청)
      await ref
          .read(challengeRepositoryProvider)
          .kickMember(widget.challengeId, targetUserId);

      // 2. 성공 시 목록 새로고침 (Provider 초기화 -> 다시 로딩됨)
      // 현재 적용된 필터 조건 그대로 새로고침합니다.
      final currentFilter = MemberFilter(
        challengeId: widget.challengeId,
        page: 0,
        nickname: _searchQuery, // 현재 검색어 상태 유지
      );

      // 해당 필터에 대한 캐시를 날려서 다시 API를 호출하게 만듦
      ref.invalidate(challengeMembersProvider(currentFilter));

      if (mounted) {
        _showToast(context, '$nickname 님을 내보냈습니다.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.notification,
          ),
        );
      }
    }
  }

  // 토스트 메시지
  void _showToast(BuildContext context, String message) {
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
                message, // 전달받은 메시지 그대로 출력
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
    // 클라이언트 필터링을 위해 nickname에 null 전달
    // (서버에서 전체 목록을 받아온 후 앱 내에서 초성 검색 수행)
    final filter = MemberFilter(
      challengeId: widget.challengeId,
      page: 0,
      nickname: null,
    );
    final membersAsyncValue = ref.watch(challengeMembersProvider(filter));

    // TODO: 실제 앱의 UserProvider 등을 통해 현재 로그인한 유저의 ID를 가져오기.
    // 현재는 테스트용 임시 ID가 '나' 역할로 사용되고 있습니다.
    // 그렇기에 '승빈'은 항상 '챌린지장' 배지가 표시되며 강퇴 버튼이 나타나지 않습니다.
    // final currentUserId = ref.watch(userProvider).id;
    const int currentUserId = 14; // 테스트용 임시 ID (로그상의 '승빈'님 ID)

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.black,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          '챌린지 멤버 관리',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '멤버를 검색하고 관리할 수 있습니다.',
              style: AppTypography.b2.copyWith(color: AppColors.gray2),
            ),
          ),
          const SizedBox(height: 10),
          // 1. 검색창 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9.5),
                border: Border.all(color: AppColors.gray4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/icons/search_icon.svg',
                    width: 18,
                    colorFilter: const ColorFilter.mode(
                      AppColors.gray2,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      // 검색어 입력 시 상태 업데이트 -> UI 다시 그리기 (API 재호출 X)
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim().isEmpty ? null : value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '닉네임으로 검색',
                        hintStyle: AppTypography.b2.copyWith(
                          color: AppColors.gray3,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppTypography.b2.copyWith(color: AppColors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 데이터 상태에 따른 UI 분기 처리
          Expanded(
            child: membersAsyncValue.when(
              // 로딩 중일 때
              loading: () => const Center(child: CircularProgressIndicator()),

              // 에러 발생 시
              error: (err, stack) => Center(child: Text('에러가 발생했습니다: $err')),

              // 데이터 로드 성공 시
              data: (members) {
                // 검색어 필터링 (초성 검색 포함)
                final filteredMembers = members.where((member) {
                  if (_searchQuery == null) return true;
                  final query = _searchQuery!.toLowerCase();
                  final nickname = member.nickname;
                  final nicknameLower = nickname.toLowerCase();

                  // 일반 텍스트 포함 여부 OR 2. 초성 포함 여부
                  return nicknameLower.contains(query) ||
                      KoreanStringUtils.getChoseongString(
                        nickname,
                      ).contains(query);
                }).toList();

                // 정렬 (한글 > 영어 > 숫자 > 특수문자)
                filteredMembers.sort((a, b) {
                  return KoreanStringUtils.compareKoreanFirst(
                    a.nickname,
                    b.nickname,
                  );
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 멤버 수 표시
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '멤버 ${filteredMembers.length}',
                        style: AppTypography.b2.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 리스트뷰
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredMembers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final member = filteredMembers[index];
                          // 현재 렌더링 중인 멤버가 '나'인지 확인
                          final isMe = member.memberId == currentUserId;

                          return _MemberTile(
                            member: member,
                            isMe: isMe, // 상태 전달
                            notificationRed: AppColors.notification,
                            // 콜백 함수 전달
                            onKick: () => _handleKickMember(
                              member.memberId,
                              member.nickname,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isMe,
    required this.notificationRed,
    required this.onKick,
  });

  final ChallengeMember member;
  final bool isMe;
  final Color notificationRed;
  final VoidCallback onKick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // 프로필 이미지 (임시 플레이스홀더)
          buildProfileCircle(member.profileImageUrl, 44),
          const SizedBox(width: 10),
          // 이름 및 칭호
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.nickname,
                style: AppTypography.b2.copyWith(color: AppColors.black),
              ),
              Text(
                '사용자 칭호',
                // TODO: 실제 칭호 데이터로 교체 필요
                style: AppTypography.c1.copyWith(color: AppColors.gray2),
              ),
            ],
          ),
          const Spacer(),
          // 강제 퇴장 버튼
          // 본인일 경우 '챌린지장' 배지 표시, 아닐 경우 '강제 퇴장' 버튼 표시
          if (isMe)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.selected,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '챌린지장',
                style: AppTypography.c1.copyWith(color: AppColors.primaryAble),
              ),
            )
          else
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => KickConfirmDialog(
                    nickname: member.nickname,
                    onConfirm: () {
                      onKick();
                      print('👋 \'${member.nickname}\' 강퇴 처리됨');
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: notificationRed),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '강제 퇴장',
                  style: AppTypography.c1.copyWith(color: notificationRed),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 함수의 용도: 유저 프로필 이미지 원형 위젯 생성 (Asset -> Network 이미지 대응)
  /// 매개 변수: String? imagePath, double size
  Widget buildProfileCircle(String? imageUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0x7FDFE1DC),
        shape: BoxShape.circle,
        // 서버에서 오는 이미지는 NetworkImage로 처리해야 합니다.
        image: imageUrl != null && imageUrl.startsWith('http')
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : (imageUrl != null
                  ? DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null),
      ),
      child: imageUrl == null
          ? Center(
              child: SvgPicture.asset(
                'assets/images/icons/default_profile_icon.svg',
                width: size * 0.6,
              ),
            )
          : null,
    );
  }
}
