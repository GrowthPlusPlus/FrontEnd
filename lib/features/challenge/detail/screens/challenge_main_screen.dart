// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/widgets/challenge_popup_menu.dart';
//import 'package:haenaem/features/challenge/widgets/challenge_create_success_dialog_.dart';
import 'package:haenaem/shared/widgets/bottom_action_button.dart';
import 'package:haenaem/features/challenge/verification/screens/challenge_verification_screen.dart';
import 'package:haenaem/features/challenge/detail/screens/member_ranking_screen.dart';
import 'package:haenaem/features/challenge/widgets/challenge_create_success_dialog.dart';
import 'package:haenaem/shared/models/challenge_base.dart';

// 분리된 뷰 파일들 (아래 2번 단계에서 생성/수정할 파일들)
import 'package:haenaem/features/challenge/detail/views/calendar_view.dart';
import 'package:haenaem/features/challenge/detail/views/information_view.dart';
import 'package:haenaem/features/challenge/detail/views/member_view.dart';

class ChallengeMainScreen extends ConsumerStatefulWidget {
  final int challengeId;
  final String? challengeTitle;
  final bool isJustCreated;
  final ChallengeBase? createdData;

  const ChallengeMainScreen({
    super.key,
    required this.challengeId,
    this.challengeTitle,
    this.isJustCreated = false,
    this.createdData,
  });

  @override
  ConsumerState<ChallengeMainScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 스크롤 컨트롤러들
  final ScrollController _infoScrollController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _memberScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 탭 3개: 소개(0), 내 현황(1), 멤버 현황(2)
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // 인덱스 변경 완료 시 UI 업데이트
      }
    });

    // 챌린지 생성 직후라면 생성 성공 다이얼로그 실행
    if (widget.isJustCreated && widget.createdData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierColor: const Color(0x7F1A1D1B),
          builder: (context) => ChallengeCreateSuccessDialog(
            challengeId: widget.createdData!.id, // ✅ ChallengeBase.id 사용
            //challengeLink: '', // ✅ ChallengeBase에 link 없으므로 빈 값
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _infoScrollController.dispose();
    _calendarScrollController.dispose();
    _memberScrollController.dispose();
    super.dispose();
  }

  void scrollToTop(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryAble,
          unselectedLabelColor: AppColors.gray2,
          indicatorColor: AppColors.primaryAble,
          indicatorWeight: 1,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: AppTypography.b1.copyWith(color: AppColors.primaryAble),
          tabs: const [
            Tab(text: '소개'),
            Tab(text: '내 현황'),
            Tab(text: '멤버 현황'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InformationView(
            challengeId: widget.challengeId,
            scrollController: _infoScrollController,
          ),
          CalendarView(
            challengeId: widget.challengeId,
            scrollController: _calendarScrollController,
          ),
          MemberView(
            challengeId: widget.challengeId,
            scrollController: _memberScrollController,
          ),
        ],
      ),
      bottomNavigationBar: buildBottomButton(),
    );
  }

  Widget buildBottomButton() {
    // 0: 소개, 1: 내 현황 -> '인증하기'
    // 2: 멤버 현황 -> '내 순위 확인하기'
    final bool isMemberTab = _tabController.index == 2;

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

  void scrollToMyRank() {
    // MemberView에서 내 순위를 찾는 로직을 구현하거나
    // scrollController를 통해 하단으로 이동시키는 로직 등을 수행합니다.
    _memberScrollController.animateTo(
      500, // 예시 값
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
}
