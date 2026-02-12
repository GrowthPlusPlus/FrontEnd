// 최초 작성자: 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class InformationView extends ConsumerWidget {
  final int challengeId;
  final ScrollController scrollController;

  const InformationView({
    super.key,
    required this.challengeId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 챌린지 상세 정보를 가져오는 Provider 구독 (예: challengeDetailProvider)

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("챌린지 소개", style: AppTypography.h3),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray5,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "여기에 챌린지 상세 설명이 들어갑니다.\n서버에서 받아온 데이터를 연결해 주세요.",
                style: AppTypography.b2,
              ),
            ),
            const SizedBox(height: 24),
            const Text("진행 규칙", style: AppTypography.h3),
            const SizedBox(height: 12),
            const Text("• 매일 인증 사진 1장 업로드", style: AppTypography.b2),
          ],
        ),
      ),
    );
  }
}
