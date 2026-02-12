// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/widgets/ChallengePopupMenu.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/widgets/challenge_create_success_dialog.dart';

// 분리된 뷰 파일들 (아래 2번 단계에서 생성/수정할 파일들)
import 'package:haenaem/features/challenge/detail/views/calendar_view.dart';
import 'package:haenaem/features/challenge/detail/views/information_view.dart';
import 'package:haenaem/features/challenge/detail/views/member_view.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final int challengeId;
  final String? challengeTitle;
  final bool isJustCreated;
  final ChallengeCreateResponse? createdData;

  const ChallengeDetailScreen({
    super.key,
    required this.challengeId,
    this.challengeTitle,
    this.isJustCreated = false,
    this.createdData,
  });

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen>
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

    // 챌린지 생성 직후라면 생성 성공 다이얼로그 실행
    if (widget.isJustCreated && widget.createdData != null) {
      // 프레임이 그려진 직후에 다이얼로그를 띄우기 위해 postFrameCallback 사용
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierColor: const Color(0x7F1A1D1B),
          builder: (context) => ChallengeCreateSuccessDialog(
            // [수정 1] friends 파라미터 삭제 (이제 필요 없음)
            // friends: widget.createdData!.friends,

            // [수정 2] challengeId 추가 (필수)
            // 주의: createdData 객체 안에 있는 ID 변수명을 정확히 적어주세요. (예: .id 또는 .challengeId)
            // challengeId: widget.createdData!.id,

            // // 기존 유지
            // challengeLink: widget.createdData!.challengeLink,
            createdData: widget.createdData!,
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

  void _scrollToTop(ScrollController controller) {
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
        title: Text(widget.challengeTitle ?? "챌린지 상세", style: AppTypography.h3),
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
    );
  }
}
