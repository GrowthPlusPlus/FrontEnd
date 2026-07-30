// 최초 작성자: 김채영

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'ai_coaching_card.dart';
import '../data/ai_coaching_repository.dart';

// AI 코칭 섹션 위젯
class AiCoachingSection extends ConsumerWidget {
  const AiCoachingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachingAsync = ref.watch(aiCoachingRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: coachingAsync.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, stack) {
          // 디버그 콘솔에서 원인을 확인하기 위한 로그
          debugPrint('❌ AiCoaching 로드 실패: $e');
          if (e is DioException) {
            debugPrint('  - type: ${e.type}');
            debugPrint('  - message: ${e.message}');
            debugPrint('  - statusCode: ${e.response?.statusCode}');
            debugPrint('  - responseData: ${e.response?.data}');
            debugPrint('  - requestUrl: ${e.requestOptions.uri}');
          }
          debugPrint(stack.toString());
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '데이터를 불러오지 못했어요',
                    style: AppTypography.b2.copyWith(color: AppColors.gray4),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref
                        .read(aiCoachingRepositoryProvider.notifier)
                        .refresh(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (cards) => Column(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i != 0) const SizedBox(height: 20),
              AiCoachingCard(data: cards[i]),
            ],
          ],
        ),
      ),
    );
  }
}
