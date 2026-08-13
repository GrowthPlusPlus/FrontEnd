// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'dart:math' as math;

/// 챌린지 탐색 화면 상단의 "OO님의 관심 태그 기반 추천" 그라데이션 배너
class GradationBanner extends StatelessWidget {
  const GradationBanner({
    super.key,
    required this.userName,
    this.summary, // ✅ API의 summary 필드
    this.isLoading = false, // 로딩 상태 여부
    this.onRequest, // 추천받기 버튼 동작
  });

  final String userName;
  final String? summary;
  final bool isLoading;
  final VoidCallback? onRequest;

  // "#20대"처럼 태그로 시작하는 토큰 + "챌린지는 OOO 입니다"의 챌린지명을 굵게 처리
  List<TextSpan> _buildSummarySpans() {
    if (summary == null) return []; // summary가 없을 경우 빈 배열 반환

    final normalStyle = AppTypography.b1.copyWith(color: AppColors.white);
    final boldStyle = AppTypography.b3.copyWith(color: AppColors.white);

    // 1. 굵게 처리할 두 종류의 패턴을 각각 찾는다
    final tagRegex = RegExp(r'#\S+');
    // "챌린지는 " 다음, " 입니다" 앞까지의 챌린지 이름 캡처
    final challengeNameRegex = RegExp(r'(?<=챌린지는 ).+?(?= 입니다)');

    final matches = <RegExpMatch>[
      ...tagRegex.allMatches(summary!),
      ...challengeNameRegex.allMatches(summary!),
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
            text: summary!.substring(lastEnd, match.start),
            style: normalStyle,
          ),
        );
      }
      spans.add(TextSpan(text: match.group(0), style: boldStyle));
      lastEnd = match.end;
    }

    if (lastEnd < summary!.length) {
      spans.add(
        TextSpan(text: summary!.substring(lastEnd), style: normalStyle),
      );
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
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                Flexible(
                  child: Text(
                    '$userName님의 관심 태그 기반 추천',
                    style: AppTypography.h3.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
            // ── 상태에 따른 하단 UI 렌더링 ──
            // 1. 로딩 중이면 로딩 인디케이터
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 문구 좌측 정렬
                  children: [
                    Text(
                      '$userName님에게 추천할 챌린지를 찾고 있어요!',
                      style: AppTypography.b1.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 12), // 텍스트와 로딩 점 사이 간격
                    const Align(
                      alignment: Alignment.centerRight, // 점 애니메이션 우측 하단 정렬
                      child: _BouncingDots(), // 배경 컨테이너 제거됨
                    ),
                  ],
                ),
              )
            // 2. summary가 있으면 summary 텍스트
            else if (summary != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text.rich(TextSpan(children: _buildSummarySpans())),
              )
            // 3. summary가 없고 onRequest 콜백이 있으면 "챌린지 추천받기" 버튼
            else if (onRequest != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onRequest,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: AppColors.white.withValues(alpha: 0.25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        '챌린지 추천받기',
                        style: AppTypography.b3.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── 통통 튀는 점 3개 로딩 애니메이션 위젯 ──
class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 애니메이션 반복 실행
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18, // 텍스트 폰트 높이와 비슷하게 맞춤
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double val = _controller.value;
              double delay = index * 0.15; // 각 점마다 시작 딜레이를 주어 파도타기 효과
              double offset = 0.0;

              // 현재 애니메이션 주기 내에서 점이 튀어 오를 타이밍인지 확인
              if (val > delay && val < delay + 0.4) {
                double normalized = (val - delay) / 0.4;
                offset = math.sin(normalized * math.pi) * -4.0; // 위로 4px 만큼 이동
              }

              return Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
