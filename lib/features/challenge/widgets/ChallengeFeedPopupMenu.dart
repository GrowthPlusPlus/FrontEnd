// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/widgets/DeleteConfirmDialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'edit_article_dialog.dart';
import 'package:haenaem/features/challenge/verification/screens/challenge_verification_screen.dart';

// 인증글 다이얼로그 (내 인증글일 경우와 타인의 인증글일 경우)
class ChallengeFeedPopupMenu extends ConsumerWidget {
  final CertificationPostModel post; // 인증글 데이터
  const ChallengeFeedPopupMenu({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: api 생기면 그때 수정
    // 본인 글인지 확인하는 로직 (모델에 mine 필드가 없다면 닉네임 비교 가능)
    // ♥️임시로 하드코딩♥️
    final bool isMine = post.userNickname == "챙";

    return PopupMenuButton<String>(
      //popUpAnimationStyle: AnimationStyle.none, // 애니메이션 없이 즉시 노출
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(maxWidth: 206),
      offset: const Offset(0, 40), // 버튼 아래로 띄우기
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: AppColors.gray4),
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      elevation: 4, // 그림자 효과

      icon: SvgPicture.asset(
        'assets/images/icons/dots_vert_icon.svg',
        width: 24,
        height: 24,
      ),

      // 내 글이냐 아니냐에 따라 아이템 리스트만 교체
      itemBuilder: (context) {
        if (isMine) {
          return [
            _buildPopupItem(
              '수정하기',
              'assets/images/icons/edit_icon.svg',
              'edit',
            ),
            _buildDivider(),
            _buildPopupItem(
              '삭제하기',
              'assets/images/icons/small_trash_icon.svg',
              'delete',
              isDanger: true,
            ),
          ];
        } else {
          return [
            _buildPopupItem(
              '챌린지 보기',
              'assets/images/icons/eye.svg',
              'view_challenge',
            ),
            _buildDivider(),
            _buildPopupItem(
              '신고하기',
              'assets/images/icons/complaint.svg',
              'report',
              isDanger: true,
            ),
          ];
        }
      },
      onSelected: (value) => _handleMenuSelection(context, ref, value),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String title,
    String iconPath,
    String value, {
    bool isDanger = false,
  }) {
    final Color textColor = isDanger ? AppColors.notification : AppColors.black;

    return PopupMenuItem<String>(
      value: value,
      height: 40, // 높이 조절
      padding: EdgeInsets.zero,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.b2.copyWith(color: textColor, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // 구분선 위젯
  PopupMenuEntry<String> _buildDivider() {
    return const PopupMenuDivider(height: 1);
  }

  // 메뉴 선택 핸들러
  void _handleMenuSelection(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();

    switch (value) {
      case 'edit':
        // 💡 [로직 변경] 다이얼로그 대신 '인증하기' 화면으로 데이터와 함께 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeVerificationScreen(
              challengeId: 0, // 챌린지 ID가 필요하다면 post 모델에 추가하거나 context에서 가져와야 함
              existingPost: post, // 💡 현재 게시글 데이터를 전달하여 '수정 모드'로 진입
            ),
          ),
        );
        break;
      case 'delete':
        final bool? confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const DeleteConfirmDialog(
            title: '인증글 삭제',
            message: '정말로 이 게시물을 삭제하시겠습니까?\n삭제된 게시물은 복구할 수 없습니다.',
          ),
        );

        if (confirmed == true) {
          final success = await ref
              .read(articleDeleteNotifierProvider.notifier)
              .removeArticle(post.postId);

          if (success && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("인증글이 삭제되었습니다.")));

            // 관련된 모든 Provider를 무효화하여 한꺼번에 새로고침
            ref.invalidate(challengePostsProvider); // 하단 리스트 새로고침
            ref.invalidate(challengeCalendarPhotosProvider); // 캘린더 사진 새로고침
            ref.invalidate(challengeCalendarDataProvider); // 상단 정보 새로고침
            Navigator.pop(context); // 상세 페이지 닫기
          }
        }

        break;
      case 'view_challenge':
        // TODO: 챌린지 상세(소개) 페이지로 이동하거나 탭을 전환하는 로직
        debugPrint('🚀 [Action] 챌린지 보기 클릭');
        // Navigator.push(...) 혹은 현재 탭 전환 로직 추가
        break;
      case 'complain':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("신고가 접수되었습니다.")));
        break;
    }
  }
}
