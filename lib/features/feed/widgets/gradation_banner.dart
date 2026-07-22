// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_typography.dart';

/// 챌린지 탐색 화면 상단의 "OO님의 관심 태그 기반 추천" 그라데이션 배너
class GradationBanner extends StatelessWidget {
  const GradationBanner({
    super.key,
    required this.userName,
    required this.summary, // ✅ API의 summary 필드
  });

  final String userName;
  final String summary;

  // "#20대"처럼 태그로 시작하는 토큰 + "챌린지는 OOO 입니다"의 챌린지명을 굵게 처리
  List<TextSpan> _buildSummarySpans() {
    final normalStyle = AppTypography.b1.copyWith(color: Colors.white);
    final boldStyle = AppTypography.b3.copyWith(color: Colors.white);

    // 1. 굵게 처리할 두 종류의 패턴을 각각 찾는다
    final tagRegex = RegExp(r'#\S+');
    // "챌린지는 " 다음, " 입니다" 앞까지의 챌린지 이름 캡처
    final challengeNameRegex = RegExp(r'(?<=챌린지는 ).+?(?= 입니다)');

    final matches = <RegExpMatch>[
      ...tagRegex.allMatches(summary),
      ...challengeNameRegex.allMatches(summary),
    ]..sort((a, b) => a.start.compareTo(b.start)); // 등장 순서대로 정렬

    if (matches.isEmpty) {
      return [TextSpan(text: summary, style: normalStyle)];
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // 겹치는 매치는 건너뜀 (혹시 태그와 챌린지명 캡처가 겹칠 경우 대비)
      if (match.start < lastEnd) continue;

      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: summary.substring(lastEnd, match.start),
            style: normalStyle,
          ),
        );
      }
      spans.add(TextSpan(text: match.group(0), style: boldStyle));
      lastEnd = match.end;
    }

    if (lastEnd < summary.length) {
      spans.add(TextSpan(text: summary.substring(lastEnd), style: normalStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-1.05, 0.00),
            end: Alignment(1.36, 1.45),
            colors: [Color(0xFF00C769), Color(0xFF357FFF)],
          ),
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
          spacing: 6,
          children: [
            // ── 제목 줄: 아이콘 + "OO님의 관심 태그 기반 추천" ──
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 6,
              children: [
                SvgPicture.asset(
                  'assets/images/icons/sparkle_icon.svg',
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                Flexible(
                  child: Text(
                    '$userName 님의 관심 태그 기반 추천',
                    style: AppTypography.h3.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            // ── 서술 요약 줄: summary (#태그는 굵게) ──
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text.rich(TextSpan(children: _buildSummarySpans())),
            ),
          ],
        ),
      ),
    );
  }
}
