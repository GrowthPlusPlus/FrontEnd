// 최초 작성자 : 강선욱
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/widgets/DeleteConfirmDialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/shared/models/post.dart';
//import 'package:haenaem/features/challenge/models/challenge_model.dart';
// 리스트 갱신용으로 유지
// import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
//import '../../challenge/widgets/edit_article_dialog.dart';
import '../provider/post_detail_provider.dart';
import 'package:haenaem/features/challenge/verification/screens/challenge_verification_screen.dart';
import 'package:haenaem/features/report/screens/report_screen.dart';
import 'package:haenaem/features/report/provider/report_provider.dart';

// 인증글 다이얼로그 (내 인증글일 경우와 타인의 인증글일 경우)
class PostPopupMenu extends ConsumerWidget {
  final Post post; // 인증글 데이터
  const PostPopupMenu({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 현재 로그인한 내 프로필 정보를 가져옵니다.
    //final myProfileAsync = ref.watch(myProfileProvider);

    // 2. 내 닉네임과 게시글 작성자 닉네임을 비교하여 '내 글' 여부 판단
    final bool isMine = post.isAuthor;

    // 2. [날짜 체크] 오늘 날짜 문자열(yyyy-MM-dd) 생성
    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 3. 게시글의 postDate와 오늘 날짜 비교
    // 💡 날짜 타입이 DateTime으로 바뀌었으므로 String으로 포맷 변환 후 비교
    final String postDateStr = DateFormat('yyyy-MM-dd').format(post.date);
    final bool isToday = postDateStr.startsWith(todayStr);

    // 💡 디버깅을 위해 로그를 한 번 찍어보세요. (문제 확인용)
    debugPrint('🔍 비교 날짜 - 서버 데이터: "$postDateStr", 오늘 날짜: "$todayStr"');
    debugPrint('🔍 판정 결과 - isMine: $isMine, isToday: $isToday');

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
          if (isToday) {
            // 📅 오늘 올린 글: 수정/삭제 가능
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
            // 🕰️ 지난 날짜 글: 내 글이라도 수정/삭제 불가 (대신 챌린지 보기만 노출)
            // 자신이 쓴 글을 신고할 순 없으니 '챌린지 보기'만 넣어주는 게 자연스러워요!
            return [
              _buildPopupItem(
                '챌린지 보기',
                'assets/images/icons/eye.svg',
                'view_challenge',
              ),
            ];
          }
        } else {
          // ✨ 타인의 글: 기존과 동일 (보기/신고)
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
        // 다이얼로그 대신 '인증하기' 화면으로 데이터와 함께 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeVerificationScreen(
              challengeId: post
                  .challengeId, // 챌린지 ID가 필요하다면 post 모델에 추가하거나 context에서 가져와야 함
              existingPost: post, // 현재 게시글 데이터를 전달하여 '수정 모드'로 진입
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
          try {
            // 💡 삭제 시도
            final success = await ref
                .read(postDeleteNotifierProvider.notifier)
                .removeArticle(post.id);

            if (success && context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("인증글이 삭제되었습니다.")));

              // 만약 상세페이지라면 뒤로가기
              Navigator.pop(context);
            }
          } catch (e) {
            // 💡 [핵심] 서버의 에러 메시지(PAST_POST_CANNOT_DELETE) 처리
            String errorMessage = "삭제에 실패했습니다.";

            if (e.toString().contains("PAST_POST_CANNOT_DELETE")) {
              errorMessage = "지나간 날짜의 인증글은 삭제할 수 없습니다. ✊";
            }

            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(errorMessage)));
            }
          }
        }
        break;

      case 'view_challenge':
        // TODO: 챌린지 상세(소개) 페이지로 이동하거나 탭을 전환하는 로직
        debugPrint('🚀 [Action] 챌린지 보기 클릭');
        // TODO: Navigator.push(...) 혹은 현재 탭 전환 로직 추가
        break;
      // case 'complain':
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(const SnackBar(content: Text("신고가 접수되었습니다.")));
      //   break;
      case 'report':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(
              targetType: ReportTargetType.article, // 인증글 타입
              targetId: post.id, // 인증글 ID
            ),
          ),
        );
        break;
    }
  }
}
