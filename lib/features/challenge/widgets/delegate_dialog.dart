// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/model/user_model.dart';
import '../provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/provider/challenge_member_provider.dart';
import 'package:haenaem/shared/widgets/challenge_exit_base_dialog.dart';
import 'package:haenaem/features/challenge/data/challenge_repository.dart';

// 챌린지장 위임 다이얼로그
class DelegateDialog extends ConsumerStatefulWidget {
  final int challengeId;
  const DelegateDialog({super.key, required this.challengeId});

  @override
  ConsumerState<DelegateDialog> createState() => _DelegateDialogState();
}

class _DelegateDialogState extends ConsumerState<DelegateDialog> {
  ChallengeMember? selectedMember;

  @override
  Widget build(BuildContext context) {
    return ChallengeExitBaseDialog(
      confirmButtonText: '위임 후 나가기',
      isConfirmEnabled: selectedMember != null,
      onConfirm: () async {
        if (selectedMember == null) return;
        try {
          await ref
              .read(challengeRepositoryProvider)
              .delegateChallengeOwner(
                widget.challengeId,
                selectedMember!.memberId,
              );

          // 홈 화면 데이터 새로고침
          ref.invalidate(challengeHomeNotifierProvider);

          if (context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst); // 홈으로 이동
          }
        } catch (e) {
          // 에러 처리
        }
      },
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 챌린지장 위임 타이틀 섹션
          Column(
            children: [
              Text(
                '챌린지장 위임',
                style: AppTypography.b3.copyWith(color: AppColors.black),
              ),
              Text(
                '챌린지장 권한을 넘길 멤버를 선택해주세요',
                textAlign: TextAlign.center,
                style: AppTypography.b1.copyWith(color: AppColors.gray2),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 위임할 멤버 선택 섹션
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '위임할 멤버',
                style: AppTypography.b1.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: 8),
              _buildMemberSelector(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSelector() {
    return GestureDetector(
      onTap: () => _showMemberSelectionSheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: AppColors.gray5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedMember?.nickname ?? '멤버를 선택하세요',
              style: AppTypography.b2.copyWith(
                color: selectedMember == null
                    ? AppColors.gray2
                    : AppColors.black,
              ),
            ),
            SvgPicture.asset(
              'assets/images/icons/big_down_arrow.svg',
              width: 16,
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  // 멤버 목록 바텀 시트 (로직 유지)
  void _showMemberSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final filter = MemberFilter(challengeId: widget.challengeId);
            final membersAsync = ref.watch(challengeMembersProvider(filter));

            return Container(
              padding: const EdgeInsets.all(20),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('멤버 선택', style: AppTypography.h3),
                  const SizedBox(height: 16),
                  Expanded(
                    child: membersAsync.when(
                      data: (members) => ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.gray5,
                              backgroundImage: member.profileImageUrl != null
                                  ? NetworkImage(member.profileImageUrl!)
                                  : null,
                            ),
                            title: Text(
                              member.nickname,
                              style: AppTypography.b2,
                            ),
                            onTap: () {
                              setState(() => selectedMember = member);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) =>
                          const Center(child: Text('목록을 불러오지 못했습니다.')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
