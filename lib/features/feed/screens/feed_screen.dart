// 최초 작성자 : 강선욱
// 피드 화면 클래스 앱 바와 탭 바의 구조를 담당
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/feed/screens/challenge_search_screen.dart';
import '../provider/feed_provider.dart';
import 'package:haenaem/features/feed/views/share_feed_view.dart';
import 'package:haenaem/shared/widgets/custom_tab_bar.dart';

const double _kNavVelocityThreshold = 800.0;

class FeedScreen extends StatefulWidget {
  final void Function(bool isNext)? onSwipeToMain;

  const FeedScreen({super.key, this.onSwipeToMain});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _friendScrollController = ScrollController();
  final ScrollController _exploreScrollController = ScrollController();

  bool _isHandlingSwipe = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _friendScrollController.dispose();
    _exploreScrollController.dispose();
    super.dispose();
  }

  void _triggerNavigation({required bool isNext}) {
    _isHandlingSwipe = true;
    widget.onSwipeToMain?.call(isNext);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _isHandlingSwipe = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: AppBar(
        backgroundColor: appColors.whiteToBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '피드',
          style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(
                      name: ChallengeSearchScreen.routeName,
                    ),
                    builder: (context) => const ChallengeSearchScreen(),
                  ),
                );
              },
              icon: SvgPicture.asset(
                'assets/images/icons/search_icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  appColors.blackToWhite,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomTabBar(
        tabs: const ['친구', '둘러보기'],
        scrollControllers: [_friendScrollController, _exploreScrollController],
        children: [
          // 친구 탭: 오른쪽 스와이프 → 통계 화면
          SwipeNavWrapper(
            onSwipeRight: () => _triggerNavigation(isNext: false),
            child: ShareFeedView(
              scrollController: _friendScrollController,
              provider: friendFeedProvider,
              emptyMessage: "아직 등록된 친구의 피드가 없어요.",
            ),
          ),
          // 둘러보기 탭: 왼쪽 스와이프 → 소셜 화면
          SwipeNavWrapper(
            onSwipeLeft: () => _triggerNavigation(isNext: true),
            child: ShareFeedView(
              scrollController: _exploreScrollController,
              provider: exploreFeedProvider,
              emptyMessage: "둘러볼 수 있는 피드가 없습니다.",
            ),
          ),
        ],
      ),
    );
  }
}

/// 수평 스와이프 네비게이션 감지 래퍼
/// ListView의 수직 스크롤과 충돌 없이 수평 드래그만 감지합니다.
class SwipeNavWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  /// 네비게이션으로 인정할 최소 수평 이동 거리 (px)
  final double swipeThreshold;

  /// 수평/수직 비율 - 이 값보다 수평 비율이 높아야 수평 스와이프로 인정
  final double horizontalDominanceRatio;

  const SwipeNavWrapper({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.swipeThreshold = 80.0,
    this.horizontalDominanceRatio = 1.5,
  });

  @override
  State<SwipeNavWrapper> createState() => _SwipeNavWrapperState();
}

class _SwipeNavWrapperState extends State<SwipeNavWrapper> {
  Offset? _pointerDownPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _pointerDownPosition = event.position;
      },
      onPointerUp: (event) {
        final start = _pointerDownPosition;
        if (start == null) return;
        _pointerDownPosition = null;

        final dx = event.position.dx - start.dx;
        final dy = event.position.dy - start.dy;

        // 수평 이동이 threshold 미만이면 무시
        if (dx.abs() < widget.swipeThreshold) return;

        // 수직 이동이 수평보다 크면 스크롤로 간주하고 무시
        if (dy.abs() * widget.horizontalDominanceRatio > dx.abs()) return;

        if (dx > 0) {
          widget.onSwipeRight?.call(); // 오른쪽 스와이프
        } else {
          widget.onSwipeLeft?.call(); // 왼쪽 스와이프
        }
      },
      child: widget.child,
    );
  }
}
