// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/settings/data/challenge_member_repository.dart';
import 'package:haenaem/shared/models/user.dart';
// import '../provider/challenge_provider.dart';
import 'package:haenaem/shared/provider/home_provider.dart';
import 'package:haenaem/features/challenge/settings/provider/challenge_member_provider.dart';
import 'package:haenaem/shared/widgets/challenge_exit_base_dialog.dart';
// import 'package:haenaem/features/challenge/data/challenge_repository.dart';

// 챌린지장 위임 다이얼로그
class DelegateDialog extends ConsumerStatefulWidget {
  final int challengeId;
  const DelegateDialog({super.key, required this.challengeId});

  @override
  ConsumerState<DelegateDialog> createState() => _DelegateDialogState();
}

class _DelegateDialogState extends ConsumerState<DelegateDialog> {
  User? selectedMember;
  bool isExpanded = false; // 위임할 멤버 리스트 확장 여부

  @override
  Widget build(BuildContext context) {
    return ChallengeExitBaseDialog(
      confirmButtonText: '위임 후 나가기',
      isConfirmEnabled: selectedMember != null,
      onConfirm: () async {
        if (selectedMember == null) return;
        try {
          await ref
              .read(challengeMemberRepositoryProvider)
              .delegateChallengeOwner(widget.challengeId, selectedMember!.id);

          // 홈 화면 데이터 새로고침
          ref.invalidate(homeNotifierProvider);

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
              // 펼쳐지는 위임할 멤버 리스트 (확장 상태일 때만 표시)
              if (isExpanded) ...[
                const SizedBox(height: 4),
                _buildExpandedMemberList(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 클릭 가능한 선택 박스
  Widget _buildMemberSelector() {
    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded), // 토글 기능
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gray5,
          borderRadius: BorderRadius.circular(8),
          border: isExpanded ? Border.all(color: AppColors.gray4) : null,
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
            // 확장 상태에 따라 아이콘 회전 효과 (선택사항)
            Transform.rotate(
              angle: isExpanded ? 3.14159 : 0, // 180도 회전
              child: SvgPicture.asset(
                'assets/images/icons/big_down_arrow.svg',
                width: 16,
                height: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 아래로 펼쳐지는 멤버 리스트 위젯
  Widget _buildExpandedMemberList() {
    final filter = MemberFilter(challengeId: widget.challengeId);
    final membersAsync = ref.watch(challengeMembersProvider(filter));

    return Container(
      constraints: const BoxConstraints(maxHeight: 100), // 최대 높이 제한
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: membersAsync.when(
        data: (members) {
          final displayMembers = members;

          if (displayMembers.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('위임 가능한 멤버가 없습니다.'),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: displayMembers.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Colors.transparent),
            itemBuilder: (context, index) {
              final member = displayMembers[index];
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.gray5,
                  backgroundImage: member.profileUrl != null
                      ? NetworkImage(member.profileUrl!)
                      : null,
                ),
                title: Text(member.nickname, style: AppTypography.b2),
                onTap: () {
                  setState(() {
                    selectedMember = member;
                    isExpanded = false; // 선택 후 닫기
                  });
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (e, s) => const Center(child: Text('로드 실패')),
      ),
    );
  }
}
