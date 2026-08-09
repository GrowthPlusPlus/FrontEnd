// 최초 작성자: 김채영
class ClipVerifyResult {
  final bool passed;
  final double? score;
  final double? threshold;
  final List<String>? detectedObjects;
  final List<String>? expectedObjects;

  const ClipVerifyResult({
    required this.passed,
    this.score,
    this.threshold,
    this.detectedObjects,
    this.expectedObjects,
  });

  ClipVerifyResult copyWith({bool? passed}) {
    return ClipVerifyResult(
      passed: passed ?? this.passed,
      score: score,
      threshold: threshold,
      detectedObjects: detectedObjects,
      expectedObjects: expectedObjects,
    );
  }

  factory ClipVerifyResult.fromJson(Map<String, dynamic> json) {
    final String? passedRaw = json['passed']?.toString().toUpperCase();

    // PASS, REVIEW는 통과로 간주
    final bool passed = passedRaw == 'PASS' || passedRaw == 'REVIEW';

    return ClipVerifyResult(
      passed: passed,
      score: (json['score'] as num?)?.toDouble(),
      threshold: (json['threshold'] as num?)?.toDouble(),
      detectedObjects: (json['detectedObjects'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      expectedObjects: (json['expectedObjects'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}
