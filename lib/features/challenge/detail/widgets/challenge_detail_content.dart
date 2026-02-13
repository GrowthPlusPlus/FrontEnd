import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart'; // 상세 모델 임포트

class ChallengeDetailContent extends StatelessWidget {
  final ChallengeDetailModel challenge;
  final ScrollController scrollController;
  final bool showTitle; // ✅ 제목 노출 여부 추가

  const ChallengeDetailContent({
    super.key,
    required this.challenge,
    required this.scrollController,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. 날짜 데이터 가공
    String formattedStart = challenge.startDate.isNotEmpty
        ? DateFormat(
            'yyyy년 MM월 dd일',
          ).format(DateTime.parse(challenge.startDate))
        : "";
    String formattedEnd = challenge.endDate.isNotEmpty
        ? DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(challenge.endDate))
        : "";

    // 2. D-Day 계산 로직
    String dDayString = "";
    if (challenge.endDate.isNotEmpty) {
      DateTime end = DateTime.parse(challenge.endDate);
      DateTime today = DateTime.now();
      DateTime targetDay = DateTime(end.year, end.month, end.day);
      DateTime currentDay = DateTime(today.year, today.month, today.day);

      int difference = targetDay.difference(currentDay).inDays;

      if (difference == 0) {
        dDayString = "(D-Day)";
      } else if (difference > 0) {
        dDayString = "(D-$difference)";
      } else {
        dDayString = "(종료됨)";
      }
    }

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 챌린지 제목
          if (showTitle) ...[
            Text(
              challenge.title,
              style: AppTypography.h3.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 24),
          ],

          _buildInfoSection('챌린지 시작일', formattedStart),
          _buildInfoSection('챌린지 마감일', '$formattedEnd $dDayString'),
          _buildInfoSection('인증 빈도', '매일'),

          // 태그 섹션
          Text(
            '챌린지 태그',
            style: AppTypography.b1.copyWith(color: AppColors.gray2),
          ),
          const SizedBox(height: 8),

          // Row(
          //   children: challenge.tags.isEmpty
          //       ? [const Text("-", style: TextStyle(color: AppColors.gray2))]
          //       : challenge.tags.map((tagObj) {
          //           return Padding(
          //             padding: const EdgeInsets.only(right: 8),
          //             child: _buildTag(tagObj.tag),
          //           );
          //         }).toList(),
          // ),
          const _CustomDivider(),

          // 챌린지 설명
          Text(
            '챌린지 설명',
            style: AppTypography.b1.copyWith(color: AppColors.gray2),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: AppTypography.b1.copyWith(
              color: AppColors.black,
              height: 1.5,
            ),
          ),

          const _CustomDivider(),

          // 방장 정보
          Text('방장', style: AppTypography.b1.copyWith(color: AppColors.gray2)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildProfileImage(challenge.host.profileImageUrl),
              const SizedBox(width: 12),
              Text(
                challenge.host.name,
                style: AppTypography.b1.copyWith(color: AppColors.black),
              ),
            ],
          ),

          const _CustomDivider(),

          // 참여자 수
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: AppColors.black),
              const SizedBox(width: 4),
              Text(
                '참여자 수',
                style: AppTypography.b1.copyWith(color: AppColors.gray2),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${challenge.participantCount}명',
            style: AppTypography.b1.copyWith(color: AppColors.black),
          ),

          const _CustomDivider(),

          // 오늘의 인증자
          Text(
            '오늘의 인증자',
            style: AppTypography.b1.copyWith(color: AppColors.gray2),
          ),
          const SizedBox(height: 12),
          challenge.todaySuccessUsers.isEmpty
              ? Text(
                  '아직 오늘의 인증자가 없습니다.',
                  style: AppTypography.b1.copyWith(color: AppColors.gray2),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: challenge.todaySuccessUsers.map((user) {
                      return _buildAttendee(user.name, user.profileImageUrl);
                    }).toList(),
                  ),
                ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- 내부 컴포넌트 메서드 ---

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.b1.copyWith(color: AppColors.gray2)),
          const SizedBox(height: 4),
          Text(
            content,
            style: AppTypography.b1.copyWith(color: AppColors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: AppTypography.b2.copyWith(
          color: AppColors.primaryAble,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return SizedBox(
      width: 36,
      height: 36,
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                  'assets/images/icons/default_profile_icon.svg',
                ),
              )
            : SvgPicture.asset('assets/images/icons/default_profile_icon.svg'),
      ),
    );
  }

  Widget _buildAttendee(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          _buildProfileImage(imageUrl), // 재사용
          const SizedBox(height: 6),
          SizedBox(
            width: 50,
            child: Text(
              name,
              style: AppTypography.c1.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(height: 1, thickness: 1, color: AppColors.gray4),
    );
  }
}
