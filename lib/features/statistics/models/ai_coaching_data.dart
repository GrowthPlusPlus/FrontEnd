// 최초 작성자: 김채영
// AI 코칭 카드 데이터 모델
// 통계 화면 하단에 노출되는 "AI 분석" 코칭 카드 3종의 데이터 정의

import 'package:flutter/material.dart';

/// 코칭 카드 종류
/// - achievement : 나의 해냄 포인트 (잘하고 있는 점)
/// - improvement : 이것만 해내면 완벽해요 (보완할 점)
/// - nextStep    : 다음 단계 해내기 (액션 제안)
enum CoachingCardType { achievement, improvement, nextStep }

/// AI 코칭 카드 3종이 공통으로 쓰는 테두리 그라데이션
/// (GradationBanner와 동일한 그라데이션)
const LinearGradient aiCoachingCardBorderGradient = LinearGradient(
  begin: Alignment(-1.05, 0.00),
  end: Alignment(1.36, 1.45),
  colors: [Color(0xFF00C769), Color(0xFF357FFF)],
);

/// 카드 제목 앞 이모지
extension CoachingCardTypeStyle on CoachingCardType {
  /// 카드 제목 앞 이모지
  String get emoji {
    switch (this) {
      case CoachingCardType.achievement:
        return '👏';
      case CoachingCardType.improvement:
        return '💡';
      case CoachingCardType.nextStep:
        return '🚀';
    }
  }
}

/// 코칭 카드 한 장에 필요한 데이터
class AiCoachingCardModel {
  final CoachingCardType type;
  final String title;
  final List<String> bullets;

  const AiCoachingCardModel({
    required this.type,
    required this.title,
    required this.bullets,
  });

  factory AiCoachingCardModel.fromJson(Map<String, dynamic> json) {
    return AiCoachingCardModel(
      type: CoachingCardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CoachingCardType.achievement,
      ),
      title: json['title'] as String,
      bullets: List<String>.from(json['bullets'] as List),
    );
  }

  /// "- 문장1\n- 문장2" 형태의 마크다운 불릿 문자열을 List<String>으로 변환
  /// (POST /api/v1/rag/coach/query 응답의 goodPoint / improvement / recommendation 값이 이 형태)
  static List<String> _parseBullets(String raw) {
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.startsWith('- ') ? line.substring(2) : line)
        .toList();
  }
}

/// POST /api/v1/rag/coach/query 응답을 3개의 코칭 카드로 변환
///
/// 응답 예시:
/// {
///   "goodPoint": "- ...\n- ...",
///   "improvement": "- ...\n- ...",
///   "recommendation": "- ...\n- ..."
/// }
List<AiCoachingCardModel> parseCoachQueryResponse(Map<String, dynamic> json) {
  return [
    AiCoachingCardModel(
      type: CoachingCardType.achievement,
      title: '나의 해냄 포인트',
      bullets: AiCoachingCardModel._parseBullets(
        json['goodPoint'] as String? ?? '',
      ),
    ),
    AiCoachingCardModel(
      type: CoachingCardType.improvement,
      title: '이것만 해내면 완벽해요',
      bullets: AiCoachingCardModel._parseBullets(
        json['improvement'] as String? ?? '',
      ),
    ),
    AiCoachingCardModel(
      type: CoachingCardType.nextStep,
      title: '다음 단계 해내기',
      bullets: AiCoachingCardModel._parseBullets(
        json['recommendation'] as String? ?? '',
      ),
    ),
  ];
}
