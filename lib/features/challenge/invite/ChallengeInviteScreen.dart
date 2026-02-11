// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/invite/widgets/challenge_invite_content.dart';

class ChallengeInviteScreen extends ConsumerWidget {
  final int challengeId;

  const ChallengeInviteScreen({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/images/icons/arrow_left.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '챌린지 초대',
          style: AppTypography.h3.copyWith(color: Colors.black),
        ),
        centerTitle: true,
      ),
      // ★ 리팩토링 적용: 복잡한 로직을 모두 Content 위젯으로 위임
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ChallengeInviteContent(
                challengeId: challengeId,
                // challengeUrl: "https://...", // 필요시 주입
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
