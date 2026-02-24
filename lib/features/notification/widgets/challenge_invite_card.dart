// 최초 작성자: 정승빈
// '챌린지 초대' 탭의 수락/거절 버튼이 있는 카드
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChallengeInviteCard extends StatelessWidget {
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // 너무 진하지 않은 부드러운 그림자
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 초대자 정보 헤더
          Row(
            children: [
              _buildIconBox(),
              const SizedBox(width: 8),
              Text(
                '$inviterName님의 초대',
                style: AppTypography.b2.copyWith(color: AppColors.gray2),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. 챌린지 이름 및 우측 꺾쇠
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  challengeName,
                  style: AppTypography.h3.copyWith(color: AppColors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gray2),
            ],
          ),
          const SizedBox(height: 8),

          // 3. 참여 인원 및 D-Day 정보
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: AppColors.gray2),
              const SizedBox(width: 4),
              Text(
                '${participantCount.toString().padLeft(2, '0')}명', // '00명' 포맷 유지
                style: AppTypography.b2.copyWith(color: AppColors.gray2),
              ),
              const SizedBox(width: 12),
              Text(
                '완료까지 $dDay',
                style: AppTypography.b2.copyWith(color: AppColors.gray2),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. 라벨(태그) 영역
          Row(
            children: labels
                .map(
                  (label) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.selected,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        label,
                        style: AppTypography.b2.copyWith(
                          color: AppColors.primaryAble,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // 5. 버튼 영역 (거절 / 수락)
          Row(
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
                      style: AppTypography.b1.copyWith(color: AppColors.gray2),
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
