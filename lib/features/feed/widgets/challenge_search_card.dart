import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/screens/challenge_detail_screen.dart';
import 'package:haenaem/shared/models/search_challenge_card.dart'; // 모델 임포트
import 'package:haenaem/shared/widgets/tag_badge.dart';

class ChallengeSearchCard extends StatelessWidget {
  final SearchChallengeCard challenge;

  const ChallengeSearchCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
      decoration: BoxDecoration(
        color: appColors.whiteToBlack,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 챌린지 제목
                  Text(
                    challenge.base.title,
                    style: AppTypography.b3.copyWith(
                      color: appColors.blackToWhite,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 인원수 및 완료일 정보
                  Row(
                    children: [
                      _buildInfoItem(
                        appColors,
                        iconPath: 'assets/images/icons/person_icon.svg',
                        text: '${challenge.participantCount}명/50명',
                      ),
                      const SizedBox(width: 15),
                      // 하드코딩된 D-000을 모델의 dDay 데이터로 변경
                      Text(
                        '완료까지 D-${challenge.dDay}',
                        style: AppTypography.b2.copyWith(
                          color: appColors.gray2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 챌린지 태그 정보 (List<String> 처리)
                  Row(
                    children: challenge.tags.isEmpty
                        ? [const SizedBox.shrink()]
                        : challenge.tags
                              .take(2)
                              .map(
                                (tag) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: TagBadge(label: tag.tag),
                                ),
                              )
                              .toList(),
                  ),
                ],
              ),
            ),

            // 오른쪽 이동 화살표 아이콘
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChallengeDetailScreen(
                      challengeId: challenge.base.id,
                      challengeTitle: challenge.base.title,
                    ),
                  ),
                );
              },
              icon: SvgPicture.asset(
                'assets/images/icons/thick_right_arrow_icon.svg',
                colorFilter: ColorFilter.mode(appColors.gray2, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 정보 아이템(인원수 등) 위젯
  Widget _buildInfoItem(
    AppColorsExtension appColors, {
    required String iconPath,
    required String text,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(appColors.gray2, BlendMode.srcIn),
        ),
        const SizedBox(width: 2),
        Text(text, style: AppTypography.b2.copyWith(color: appColors.gray2)),
      ],
    );
  }
}
