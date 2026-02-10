// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 재사용 목적 - 텍스트 라벨
class ChallengeLabel extends StatelessWidget {
  final String label;

  const ChallengeLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // 박스와의 간격 고정
      child: Text(label, style: AppTypography.b1),
    );
  }
}
