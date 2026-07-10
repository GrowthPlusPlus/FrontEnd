// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/widgets/slider_indicator.dart';
import 'package:haenaem/shared/widgets/tag_badge.dart';
import 'package:expandable_page_view/expandable_page_view.dart';

// 챌린지 탐색 화면의 추천 챌린지 카드
class RecommendedChallengeCard extends StatefulWidget {
  const RecommendedChallengeCard({super.key, required this.items});

  // 임시 더미 데이터 (title, description, detail, participantCount,
  // remainingDays, tags 키를 가진 Map 리스트)
  final List<Map<String, dynamic>> items;

  @override
  State<RecommendedChallengeCard> createState() =>
      _RecommendedChallengeCardState();
}

class _RecommendedChallengeCardState extends State<RecommendedChallengeCard> {
  int _currentIndex = 0;

  // 각 카드의 '추천 이유 보기' 상태를 한꺼번에 추적하기 위한 Map 상태
  // {인덱스: 열림여부} — 카드별 "추천 이유" 펼침 상태
  final Map<int, bool> _expandedStates = {};

  @override
  Widget build(BuildContext context) {
    // 현재 카드가 열려있는지 확인 (기본값은 false)
    final isExpanded = _expandedStates[_currentIndex] ?? false;
    final currentItem = widget.items[_currentIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 0),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
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
            // ── 카드 상단: 항상 PageView 유지 → 언제든 좌우 스와이프 가능 ──
            //    내용 길이에 맞춰 카드 높이 자동 조절 ──
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
            // ── "추천 이유" 펼침 영역: 현재 인덱스 기준으로만 표시 ──
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Text(
                      currentItem['recommendReason'] as String? ??
                          '사용자가 운동에 관심이 많고 러닝 챌린지에 참여한 경험이 있기 때문에, 걷기 또한 운동의 일환으로 쉽게 접근할 수 있습니다. 만보 걷기는 일상에서 쉽게 실천할 수 있으며, 걸음 수를 기록하고 공유함으로써 성취감을 느낄 수 있습니다.',
                      style: AppTypography.b2.copyWith(color: AppColors.gray1),
                    )
                  : const SizedBox.shrink(),
            ),

            // ── 추천 이유 토글 버튼 (현재 페이지 기준) ──
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
                    color: AppColors.gray1,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 인디케이터 - 카드 안, 콘텐츠 아래 고정
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

// 카드 상단 고정 콘텐츠(제목/통계/태그/설명) — ExpandablePageView 안에서만 쓰임
class _RecommendedChallengeTop extends StatelessWidget {
  const _RecommendedChallengeTop({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final tags = item['tags'] as List<String>;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10, // 콘텐츠 ↔ 화살표 아이콘
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12, // 제목 블록 내부 간격
            children: [
              Text(
                item['title'] as String,
                style: AppTypography.b3.copyWith(color: AppColors.black),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    spacing: 16, // 인원수 ↔ D-day
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                            item['participantCount'] as String,
                            style: AppTypography.b2.copyWith(
                              color: AppColors.gray2,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        item['remainingDays'] as String,
                        style: AppTypography.b2.copyWith(
                          color: AppColors.gray2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5, // 태그 간 간격
                    children: tags.map((tag) => TagBadge(label: tag)).toList(),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['description'] as String,
                    style: AppTypography.b1.copyWith(color: AppColors.gray1),
                  ),
                  Text(
                    item['detail'] as String,
                    style: AppTypography.b2.copyWith(color: AppColors.gray1),
                  ),
                ],
              ),
            ],
          ),
        ),
        SvgPicture.asset('assets/images/icons/thick_right_arrow_icon.svg'),
      ],
    );
  }
}
