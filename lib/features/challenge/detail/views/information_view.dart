import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/provider/challenge_detail_provider.dart';
import 'package:haenaem/shared/widgets/challenge_detail_content.dart';

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
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final challengeAsync = ref.watch(
      challengeDetailProvider(challengeId: challengeId),
    );

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      body: challengeAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: appColors.primaryAble),
        ),
        error: (error, stack) => Center(
          child: Text(
            '데이터를 불러오지 못했습니다.\n잠시 후 다시 시도해주세요.',
            textAlign: TextAlign.center,
            style: AppTypography.b1.copyWith(color: appColors.gray2),
          ),
        ),
        data: (challenge) => ChallengeDetailContent(
          challenge: challenge,
          scrollController: scrollController,
          showTitle: false,
        ),
      ),
    );
  }
}
