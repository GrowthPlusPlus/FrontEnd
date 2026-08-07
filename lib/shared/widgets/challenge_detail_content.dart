import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/models/challenge_detail.dart';
import 'package:haenaem/shared/widgets/user_profile_circle.dart';
// import 'package:haenaem/features/challenge/models/challenge_model.dart';
// import 'package:haenaem/shared/models/tag_model.dart';
import 'package:haenaem/shared/widgets/tag_badge.dart';

class ChallengeDetailContent extends StatelessWidget {
  final ChallengeDetail challenge;
  final ScrollController scrollController;
  final bool showTitle;

  const ChallengeDetailContent({
    super.key,
    required this.challenge,
    required this.scrollController,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // 1. 날짜 데이터 가공
    String formattedStart = DateFormat(
      'yyyy년 MM월 dd일',
    ).format(challenge.startDate);
    String formattedEnd = DateFormat('yyyy년 MM월 dd일').format(challenge.endDate);

    // 2. D-Day 계산 로직
    String dDayString = "";
    final DateTime targetDay = DateTime(
      challenge.endDate.year,
      challenge.endDate.month,
      challenge.endDate.day,
    );
    final DateTime today = DateTime.now();
    final DateTime currentDay = DateTime(today.year, today.month, today.day);
    final int difference = targetDay.difference(currentDay).inDays + 1;

    if (difference == 0) {
      dDayString = "(D-Day)";
    } else if (difference > 0) {
      dDayString = "(D-$difference)";
    } else {
      dDayString = "(종료됨)";
    }

    // 인증 빈도 텍스트 가공 로직
    String frequencyText = challenge.weeklyFrequency == 7
        ? '매일'
        : '주 ${challenge.weeklyFrequency}회';

    // TagMapper 기준 정렬 로직
    // final List<ChallengeTagModel> sortedTags = List.from(challenge.tags);
    // final priorityList = TagMapper.tagInternalOrder.values
    //     .expand((e) => e)
    //     .toList();

    // sortedTags.sort((a, b) {
    //   final indexA = priorityList.indexOf(a.tag);
    //   final indexB = priorityList.indexOf(b.tag);
    //   return (indexA == -1 ? 99 : indexA).compareTo(indexB == -1 ? 99 : indexB);
    // });

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('챌린지 시작일', formattedStart, appColors),
          _buildInfoSection('챌린지 마감일', '$formattedEnd $dDayString', appColors),
          _buildInfoSection('인증 빈도', frequencyText, appColors),
          _buildInfoSection(
            '인증 방식',
            challenge.photoRequired ? '사진 첨부 필수' : '사진 첨부 선택',
            appColors,
          ),

          // 태그 섹션
          Text(
            '챌린지 태그',
            style: AppTypography.b1.copyWith(color: appColors.gray2),
          ),
          const SizedBox(height: 8),

          challenge.tags.isEmpty
              ? Text(
                  "-",
                  style: AppTypography.b1.copyWith(color: appColors.gray3),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: challenge.tags
                      .map((tag) => TagBadge(label: tag))
                      .toList(),
                ),

          // 가로 스크롤 대신 Wrap을 사용하여 정돈된 느낌을 줍니다.
          // challenge.tags.isEmpty
          //     ? Text(
          //         "-",
          //         style: AppTypography.b1.copyWith(color: AppColors.gray3),
          //       )
          //     : Wrap(
          //         spacing: 8,
          //         runSpacing: 10,
          //         children: sortedTags.map((tagObj) {
          //           // 💡 AppTagChip 대신 새로 만든 TagBadge를 사용합니다.
          //           return TagBadge(label: tagObj.tag);
          //         }).toList(),
          //       ),
          const _CustomDivider(),

          // 챌린지 설명
          Text(
            '챌린지 설명',
            style: AppTypography.b1.copyWith(color: appColors.gray2),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: AppTypography.b1.copyWith(
              color: appColors.blackToWhite,
              height: 1.5,
            ),
          ),

          const _CustomDivider(),

          // 방장 정보
          Text('방장', style: AppTypography.b1.copyWith(color: appColors.gray2)),
          const SizedBox(height: 12),
          Row(
            children: [
              UserProfileCircle(
                imageUrl: challenge.leader.profileUrl,
                size: 36,
              ),
              const SizedBox(width: 12),
              Text(
                challenge.leader.nickname,
                style: AppTypography.b1.copyWith(color: appColors.blackToWhite),
              ),
            ],
          ),

          const _CustomDivider(),

          // 참여자 수
          Row(
            children: [
              Icon(Icons.person, size: 18, color: appColors.blackToWhite),
              const SizedBox(width: 4),
              Text(
                '참여자 수',
                style: AppTypography.b1.copyWith(color: appColors.gray2),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${challenge.participantCount}명/50명',
            style: AppTypography.b1.copyWith(color: appColors.blackToWhite),
          ),

          const _CustomDivider(),

          // 오늘의 인증자
          Text(
            '오늘의 인증자',
            style: AppTypography.b1.copyWith(color: appColors.gray2),
          ),
          const SizedBox(height: 12),
          challenge.todaySuccessUsers.isEmpty
              ? Text(
                  '아직 오늘의 인증자가 없습니다.',
                  style: AppTypography.b1.copyWith(color: appColors.gray2),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: challenge.todaySuccessUsers.map((user) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Column(
                          children: [
                            UserProfileCircle(
                              imageUrl: user.profileUrl,
                              size: 36,
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 50,
                              child: Text(
                                user.nickname,
                                style: AppTypography.c1.copyWith(
                                  color: appColors.blackToWhite,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- 내부 컴포넌트 메서드 ---

  Widget _buildInfoSection(
    String title,
    String content,
    AppColorsExtension appColors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.b1.copyWith(color: appColors.gray2)),
          const SizedBox(height: 4),
          Text(
            content,
            style: AppTypography.b1.copyWith(color: appColors.blackToWhite),
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
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(height: 1, thickness: 1, color: appColors.gray4),
    );
  }
}
