// 최초 작성자: 정승빈
// '챌린지 초대' 탭의 수락/거절 버튼이 있는 카드
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/challenge_invite_detail_screen.dart';

class ChallengeInviteCard extends StatelessWidget {
  final int challengeId;
  final String inviterName;
  final String? inviterProfileImageUrl;
  final String challengeName;
  final int participantCount;
  final String dDay;
  final List<String> labels;
  final VoidCallback onAccept; // 수락 함수
  final VoidCallback onReject; // 거절 함수

  const ChallengeInviteCard({
    super.key,
    required this.challengeId,
    required this.inviterName,
    this.inviterProfileImageUrl,
    required this.challengeName,
    required this.participantCount,
    required this.dDay,
    required this.labels,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      // 디자인 가이드에 맞춘 패딩 적용
      padding: const EdgeInsets.only(top: 10, left: 16, right: 4, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 내용 및 우측 꺾쇠 레이아웃
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. 헤더 및 챌린지 이름 그룹 ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          _buildIconBox(),
                          const SizedBox(width: 6),
                          Text(
                            '$inviterName님의 초대',
                            style: AppTypography.b2.copyWith(
                              color: AppColors.gray1, // 디자인 코드 참조
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      challengeName,
                      style: AppTypography.b3.copyWith(color: AppColors.black),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10), // 그룹 간 간격
                    // --- 2. 참여 인원/D-Day 및 라벨 그룹 ---
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/person_icon.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            AppColors.gray2,
                            BlendMode.srcIn,
                          ),
                        ),
                        Text(
                          '${participantCount.toString()}명',
                          style: AppTypography.b2.copyWith(
                            color: AppColors.gray2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '완료까지 $dDay',
                          style: AppTypography.b2.copyWith(
                            color: AppColors.gray2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4), // 정보와 라벨 사이 간격
                    // 4. 태그
                    Wrap(
                      spacing: 6, // 태그 사이 간격
                      // runSpacing: 8, // 줄 바꿈 시 간격 (필요 시 활성화)
                      children: labels.map((label) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ), // 내부 여백
                          decoration: BoxDecoration(
                            color: AppColors.selected,
                            borderRadius: BorderRadius.circular(16), // 모서리 둥글기
                          ),
                          child: Text(
                            label,
                            style: AppTypography.b2.copyWith(
                              color: AppColors.primaryAble,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // 오른쪽 화살표 아이콘
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: () {
                    print("====> 이동하려는 챌린지 ID: $challengeId");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChallengeInviteDetailScreen(
                          challengeId: challengeId,
                          inviterName: inviterName,
                          inviterProfileImageUrl: inviterProfileImageUrl,
                        ),
                      ),
                    );
                  },
                  icon: SvgPicture.asset(
                    'assets/images/icons/thick_right_arrow_icon.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.gray2,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10), // 상단 콘텐츠와 하단 버튼 영역 간격
          // 5. 버튼 영역 (거절 / 수락)
          Padding(
            padding: const EdgeInsets.only(right: 12), // 우측 꺾쇠 공간만큼 패딩 보정
            child: Row(
              children: [
                // 거절 버튼 (왼쪽)
                Expanded(
                  child: InkWell(
                    onTap: onReject,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.gray5,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '거절',
                        style: AppTypography.b1.copyWith(
                          color: AppColors.gray2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // 버튼 사이 간격
                // 수락 버튼 (오른쪽)
                Expanded(
                  child: InkWell(
                    onTap: onAccept,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAble,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '수락',
                        style: AppTypography.b1.copyWith(color: Colors.white),
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

  // 아이콘 또는 프로필 이미지 렌더링 영역
  Widget _buildIconBox() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.gray5,
        shape: BoxShape.circle,
        image:
            inviterProfileImageUrl != null &&
                inviterProfileImageUrl!.startsWith('http')
            ? DecorationImage(
                image: NetworkImage(inviterProfileImageUrl!),
                fit: BoxFit.cover,
              )
            : (inviterProfileImageUrl != null
                  ? DecorationImage(
                      image: AssetImage(inviterProfileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null),
      ),
      child: inviterProfileImageUrl == null
          ? Center(
              child: SvgPicture.asset(
                'assets/images/icons/default_profile_icon.svg',
                width: 24,
              ),
            )
          : null,
    );
  }
}
