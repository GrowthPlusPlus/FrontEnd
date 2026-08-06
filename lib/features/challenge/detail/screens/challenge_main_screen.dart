// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
// import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/detail/widgets/challenge_popup_menu.dart';
// import 'package:haenaem/features/challenge/models/challenge_model.dart';
import 'package:haenaem/features/challenge/detail/widgets/challenge_create_success_dialog.dart';
import 'package:haenaem/shared/widgets/bottom_action_button.dart';
import 'package:haenaem/shared/widgets/custom_tab_bar.dart';
import 'package:haenaem/features/challenge/verification/screens/challenge_verification_screen.dart';
import 'package:haenaem/features/challenge/detail/screens/member_ranking_screen.dart';
import 'package:haenaem/features/user/provider/user_provider.dart';
import 'package:haenaem/shared/provider/challenge_detail_provider.dart';
import 'package:haenaem/shared/widgets/animated_toast.dart';

// 분리된 뷰 파일들 (아래 2번 단계에서 생성/수정할 파일들)
import 'package:haenaem/features/challenge/detail/views/calendar_view.dart';
import 'package:haenaem/features/challenge/detail/views/information_view.dart';
import 'package:haenaem/features/challenge/detail/views/member_view.dart';

class ChallengeMainScreen extends ConsumerStatefulWidget {
  final int challengeId;
  final String? challengeTitle;
  final int streakCount;
  final bool isJustCreated;
  final String challengeLink;

  const ChallengeMainScreen({
    super.key,
    required this.challengeId,
    this.challengeTitle,
    // 새로 가입, 생성한 챌린지는 streakCount가 0
    this.streakCount = 0,
    this.isJustCreated = false,
    this.challengeLink = '',
  });

  @override
  ConsumerState<ChallengeMainScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeMainScreen> {
  int _currentTabIndex = 1;

  // 스크롤 컨트롤러들
  final ScrollController _infoScrollController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _memberScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 챌린지 생성 직후라면 생성 성공 다이얼로그 실행
    if (widget.isJustCreated) {
      // 프레임이 그려진 직후에 다이얼로그를 띄우기 위해 postFrameCallback 사용
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierColor: const Color(0x7F1A1D1B),
          builder: (context) => ChallengeCreateSuccessDialog(
            challengeId: widget.challengeId,
            challengeLink: widget.challengeLink,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _infoScrollController.dispose();
    _calendarScrollController.dispose();
    _memberScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      challengeDetailProvider(challengeId: widget.challengeId),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
          ),
        ),
        title: Text(widget.challengeTitle ?? "챌린지 상세", style: AppTypography.h3),
        centerTitle: true,
        actions: [
          detailAsync.when(
            data: (detail) {
              final myInfo = ref.watch(currentUserProvider);
              final bool isHost = detail.leader.id == myInfo?.id;

              return ChallengePopupMenu(
                isHost: isHost,
                challengeId: widget.challengeId,
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: CustomTabBar(
        initialIndex: 1,
        tabs: const ['소개', '내 현황', '멤버 현황'],
        scrollControllers: [
          _infoScrollController,
          _calendarScrollController,
          _memberScrollController,
        ],
        onTabChanged: (index) {
          setState(() => _currentTabIndex = index);
        },
        children: [
          InformationView(
            challengeId: widget.challengeId,
            scrollController: _infoScrollController,
          ),
          CalendarView(
            challengeId: widget.challengeId,
            streakCount: widget.streakCount,
            scrollController: _calendarScrollController,
            joinDate: detailAsync.value?.joinDate ?? DateTime.now(),
          ),
          MemberView(
            challengeId: widget.challengeId,
            scrollController: _memberScrollController,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildBottomButton() {
    final myInfo = ref.watch(currentUserProvider);
    final detailAsync = ref.watch(
      challengeDetailProvider(challengeId: widget.challengeId),
    );

    // .value 대신 AsyncValue 상태를 직접 확인
    final detail = detailAsync.value;

    final bool isMemberTab = _currentTabIndex == 2;

    // 디버깅용 로그 (콘솔에서 확인해 보세요)
    if (detail != null) {
      debugPrint('내 ID: ${myInfo?.id}');
      debugPrint(
        '오늘 성공 유저 ID들: ${detail.todaySuccessUsers.map((e) => e.id).toList()}',
      );
    }

    // 데이터가 로딩 중이면 detail이 null이므로 hasDoneToday는 false가 됨
    final bool hasDoneToday =
        detail?.todaySuccessUsers.any((user) {
          // 타입 이슈 방지를 위해 toString()으로 비교하거나 정확한 필드 확인
          return user.id.toString() == myInfo?.id.toString();
        }) ??
        false;

    // 비활성화 여부를 하나로 정리 (멤버 탭이 아니면서, 오늘 이미 인증했을 때)
    final bool isDisabled = !isMemberTab && hasDoneToday;

    return BottomActionButton(
      text: isMemberTab ? '내 순위 확인하기' : (isDisabled ? '인증 완료!' : '인증하기'),
      backgroundColor: isDisabled
          ? AppColors.disable
          : (isMemberTab ? Colors.white : AppColors.primaryAble),
      textColor: isMemberTab ? AppColors.primaryAble : Colors.white,
      borderColor: isMemberTab ? AppColors.primaryAble : null,
      onPressed: isDisabled
          ? null // 비활성화 시 탭 자체를 막음 (토스트 제거)
          : () {
              if (isMemberTab) {
                // 멤버 탭: 랭킹 페이지 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MemberRankingScreen(challengeId: widget.challengeId),
                  ),
                );
              } else {
                // 아직 인증 전이면 인증 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChallengeVerificationScreen(
                      challengeId: widget.challengeId,
                    ),
                  ),
                );
              }
            },
    );
  }
}
