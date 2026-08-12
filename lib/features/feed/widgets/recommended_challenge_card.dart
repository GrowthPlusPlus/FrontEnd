// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/widgets/slider_indicator.dart';
import 'package:haenaem/shared/widgets/tag_badge.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import '../models/recommended_challenge.dart';
import 'package:haenaem/shared/screens/challenge_detail_screen.dart';

class RecommendedChallengeCard extends StatefulWidget {
  const RecommendedChallengeCard({super.key, required this.items});

  final List<RecommendedChallengeItem> items;

  @override
  State<RecommendedChallengeCard> createState() =>
      _RecommendedChallengeCardState();
}

class _RecommendedChallengeCardState extends State<RecommendedChallengeCard> {
  int _currentIndex = 0;
  final Map<int, bool> _expandedStates = {};

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final isExpanded = _expandedStates[_currentIndex] ?? false;
    final currentItem = widget.items[_currentIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        // ✅ 패딩 제거 → 이미지가 카드 전체 너비를 꽉 채움(풀블리드)
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: appColors.whiteToBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 16,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 이미지 + 콘텐츠(제목/통계/태그/설명) → 페이지별로 스와이프 ──
            ExpandablePageView.builder(
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _RecommendedChallengeTop(item: widget.items[index]);
              },
            ),
            // ── "추천 이유" 펼침 + 토글 버튼: 여기서부터만 좌우 패딩 적용 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: isExpanded
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              currentItem.recommendReason,
                              style: AppTypography.b2.copyWith(
                                color: appColors.gray1,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _expandedStates[_currentIndex] = !isExpanded;
                        });
                      },
                      child: Text(
                        isExpanded ? '추천 이유 닫기' : '추천 이유 보기',
                        textAlign: TextAlign.right,
                        style: AppTypography.b2.copyWith(
                          color: appColors.gray1,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SliderIndicator(
              count: widget.items.length,
              currentIndex: _currentIndex,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 카드 상단: 이미지(풀블리드) + 콘텐츠(제목/통계/태그/설명/화살표)
class _RecommendedChallengeTop extends StatelessWidget {
  const _RecommendedChallengeTop({required this.item});

  final RecommendedChallengeItem item;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 이미지 ──
        SizedBox(
          width: double.infinity,
          height: 120,
          child: item.imageUrl.isNotEmpty
              ? Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: appColors.gray4,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: appColors.gray4,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                )
              : Container(color: appColors.gray4),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              // ── 제목 ──
              Text(
                item.title,
                style: AppTypography.b3.copyWith(color: appColors.blackToWhite),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Row(
                          spacing: 16,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/icons/person_icon.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    appColors.gray2,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                Text(
                                  '${item.participantNumber}명',
                                  style: AppTypography.b2.copyWith(
                                    color: appColors.gray2,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '완료까지 D-${item.remainingDays}',
                              style: AppTypography.b2.copyWith(
                                color: appColors.gray2,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 5,
                          children: item.tags
                              .map((tag) => TagBadge(label: tag.tag))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChallengeDetailScreen(
                            challengeId: item.challengeId,
                            challengeTitle: item.title,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      child: SvgPicture.asset(
                        'assets/images/icons/thick_right_arrow_icon.svg',
                        colorFilter: ColorFilter.mode(
                          appColors.gray2,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // ── 설명: 화살표와 별도, 전체 너비 사용 ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '챌린지 설명',
                    style: AppTypography.b1.copyWith(
                      color: appColors.blackToWhite,
                    ),
                  ),
                  Text(
                    item.content,
                    style: AppTypography.b1.copyWith(color: appColors.gray2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
