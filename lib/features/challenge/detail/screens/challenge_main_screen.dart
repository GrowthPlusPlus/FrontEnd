// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/widgets/challenge_popup_menu.dart';
import 'package:haenaem/features/challenge/models/challenge_model.dart';
import 'package:haenaem/features/challenge/widgets/challenge_create_success_dialog.dart';
import 'package:haenaem/shared/widgets/bottom_action_button.dart';
import 'package:haenaem/shared/widgets/custom_tab_bar.dart';
import 'package:haenaem/features/challenge/verification/screens/challenge_verification_screen.dart';
import 'package:haenaem/features/challenge/detail/screens/member_ranking_screen.dart';

// 분리된 뷰 파일들 (아래 2번 단계에서 생성/수정할 파일들)
import 'package:haenaem/features/challenge/detail/views/calendar_view.dart';
import 'package:haenaem/features/challenge/detail/views/information_view.dart';
import 'package:haenaem/features/challenge/detail/views/member_view.dart';

class ChallengeMainScreen extends ConsumerStatefulWidget {
  final int challengeId;
  final String? challengeTitle;
  final int streakCount;
  final bool isJustCreated;
  final ChallengeCreateResponse? createdData;

  const ChallengeMainScreen({
    super.key,
    required this.challengeId,
    this.challengeTitle,
    // 새로 가입, 생성한 챌린지는 streakCount가 0
    this.streakCount = 0,
    this.isJustCreated = false,
    this.createdData,
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
    if (widget.isJustCreated && widget.createdData != null) {
      // 프레임이 그려진 직후에 다이얼로그를 띄우기 위해 postFrameCallback 사용
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierColor: const Color(0x7F1A1D1B),
          builder: (context) =>
              ChallengeCreateSuccessDialog(createdData: widget.createdData!),
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
    // 공통 데이터 로드 (방장 여부 등 확인용)
    final summaryAsync = ref.watch(
      challengeCalendarDataProvider(widget.challengeId),
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
        title: summaryAsync.when(
          // 1. 데이터가 로드되었을 때 (이미 widget에 있는 타이틀 사용)
          data: (data) =>
              Text(widget.challengeTitle ?? "챌린지 상세", style: AppTypography.h3),

          // 2. 로딩 중일 때
          loading: () =>
              Text(widget.challengeTitle ?? "챌린지 상세", style: AppTypography.h3),

          // 3. 에러가 발생했을 때
          error: (_, __) =>
              Text(widget.challengeTitle ?? "챌린지 상세", style: AppTypography.h3),
        ),
        centerTitle: true,
        actions: [
          summaryAsync.when(
            data: (data) => ChallengePopupMenu(
              isHost: data.challengeOwner,
              challengeId: widget.challengeId,
            ),
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
    // 0: 소개, 1: 내 현황 -> '인증하기'
    // 2: 멤버 현황 -> '내 순위 확인하기'
    final bool isMemberTab = _currentTabIndex == 2;

    return BottomActionButton(
      // 1. 텍스트 분기
      text: isMemberTab ? '내 순위 확인하기' : '인증하기',

      // 2. 배경색: 멤버 탭이면 흰색, 아니면 기본색(초록)
      backgroundColor: isMemberTab ? Colors.white : AppColors.primaryAble,

      // 3. 글자색: 멤버 탭이면 초록색, 아니면 흰색
      textColor: isMemberTab ? AppColors.primaryAble : Colors.white,

      // 4. 테두리색: 멤버 탭일 때만 초록색 테두리 추가
      borderColor: isMemberTab ? AppColors.primaryAble : null,

      onPressed: () {
        if (isMemberTab) {
          // 랭킹 페이지 이동 로직
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MemberRankingScreen(challengeId: widget.challengeId),
            ),
          );
        } else {
          // 인증 페이지 이동 로직
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChallengeVerificationScreen(challengeId: widget.challengeId),
            ),
          );
        }
      },
    );
  }
}
