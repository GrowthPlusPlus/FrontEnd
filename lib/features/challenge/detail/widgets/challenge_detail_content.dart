import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/shared/models/tag_data.dart';
import 'package:haenaem/shared/widgets/tag_badge.dart';

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
    print("DEBUG: 태그 리스트 길이 -> ${challenge.tags.length}");
    if (challenge.tags.isNotEmpty) {
      print("DEBUG: 첫 번째 태그 내용 -> ${challenge.tags.first.tag}");
    }

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

    // TagMapper 기준 정렬 로직
    final List<ChallengeTagModel> sortedTags = List.from(challenge.tags);
    final priorityList = TagMapper.tagInternalOrder.values
        .expand((e) => e)
        .toList();

    sortedTags.sort((a, b) {
      final indexA = priorityList.indexOf(a.tag);
      final indexB = priorityList.indexOf(b.tag);
      return (indexA == -1 ? 99 : indexA).compareTo(indexB == -1 ? 99 : indexB);
    });

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
          _buildInfoSection(
            '인증 방식',
            challenge.photoRequired ? '사진 첨부 필수' : '사진 첨부 선택',
          ),

          // 태그 섹션
          Text(
            '챌린지 태그',
            style: AppTypography.b1.copyWith(color: AppColors.gray2),
          ),
          const SizedBox(height: 8),

          // 가로 스크롤 대신 Wrap을 사용하여 정돈된 느낌을 줍니다.
          challenge.tags.isEmpty
              ? Text(
                  "-",
                  style: AppTypography.b1.copyWith(color: AppColors.gray3),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: sortedTags.map((tagObj) {
                    // 💡 AppTagChip 대신 새로 만든 TagBadge를 사용합니다.
                    return TagBadge(label: tagObj.tag);
                  }).toList(),
                ),
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
