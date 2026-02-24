// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/widgets/challenge_exit_base_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/data/challenge_repository.dart';

// 챌린지 나가기 다이얼로그
class ExitConfirmDialog extends ConsumerWidget {
  final int challengeId;
  const ExitConfirmDialog({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChallengeExitBaseDialog(
      confirmButtonText: '나가기',
      onConfirm: () async {
        try {
          await ref
              .read(challengeRepositoryProvider)
              .leaveChallenge(challengeId);

          // 홈 화면 데이터 Provider를 무효화하여 새로고침 유도
          ref.invalidate(challengeHomeNotifierProvider);

          if (context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst); // 홈으로 이동
          }
        } catch (e) {
          // 에러 처리 로직 (필요 시 추가)
        }
      },
    );
  }
}
