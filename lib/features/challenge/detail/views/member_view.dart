// 최초 작성자: 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class MemberView extends ConsumerWidget {
  final int challengeId;
  final ScrollController scrollController;

  const MemberView({
    super.key,
    required this.challengeId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 멤버 목록을 가져오는 Provider 구독

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: 10, // 임시 데이터 개수
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: const CircleAvatar(
              backgroundColor: AppColors.gray4,
              child: Icon(Icons.person, color: AppColors.gray3),
            ),
            title: Text("참여자 ${index + 1}", style: AppTypography.b1),
            subtitle: Text("현재 ${index * 10}% 달성 중", style: AppTypography.c1),
            trailing: const Icon(Icons.chevron_right, color: AppColors.gray4),
          );
        },
      ),
    );
  }
}
