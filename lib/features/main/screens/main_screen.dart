// 최초 작성자 : 김채영
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:haenaem/features/home/screens/home_screen.dart';
import 'package:haenaem/features/social/screens/social_main_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:haenaem/features/user/screens/my_page_main_screen.dart';
import 'package:haenaem/features/feed/screens/feed_screen.dart';
import 'package:haenaem/features/statistics/screens/statistics_screen.dart';
import 'package:haenaem/features/challenge/invite/provider/challenge_invite_provider.dart';
import 'package:haenaem/features/challenge/invite/models/invite_response.dart';
import 'package:haenaem/shared/screens/challenge_detail_screen.dart';
import 'package:haenaem/shared/widgets/confirm_dialog.dart';

// 내비게이션 바를 넣은 화면
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  late final PageController _pageController;

  final bool _isMainSwipeEnabled = true;

  // 딥링크 수신 관리를 위한 변수 선언
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // 하단 바를 통해 전환될 화면 리스트
  // final List<Widget> _pages = [
  //   const HomeScreen(),
  //   const StatisticsScreen(),
  //   const FeedScreen(),
  //   const SocialMainScreen(),
  //   const MyPageMainScreen(),
  // ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _selectedIndex);

    // 화면이 켜질 때 딥링크 모니터링 시스템 작동 시작
    _initDeepLinkMonitoring();
  }

  /// 딥링크 모니터링 초기화 파이프라인
  void _initDeepLinkMonitoring() async {
    _appLinks = AppLinks();

    try {
      // 1. 앱이 완전히 꺼진 상태에서 딥링크를 탭해 켜진 경우 (Cold Start)
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _processIncomingDeepLink(initialUri);
      }

      // 2. 앱이 백그라운드에 켜져 있는 상태에서 딥링크를 탄 경우 (Warm Start)
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          _processIncomingDeepLink(uri);
        },
        onError: (Object error) {
          debugPrint('❌ [딥링크 감시 에러]: $error');
        },
      );
    } catch (e) {
      debugPrint('⚠️ [딥링크 서비스 연동 실패]: $e');
    }
  }

  /// 인입된 딥링크 URI 분석 및 화면 이동 처리
  void _processIncomingDeepLink(Uri uri) async {
    debugPrint(
      '📥 [딥링크 포착 완전 분석]: scheme=${uri.scheme}, host=${uri.host}, pathSegments=${uri.pathSegments}',
    );

    // 1. 규격 검증: scheme이 맞는지, 그리고 host가 'invite'인지 확인
    if (uri.scheme != 'haenaem' || uri.host != 'invite') {
      debugPrint('⚠️ [딥링크 스킵] 올바른 초대 링크 규격이 아닙니다.');
      return;
    }

    // 2. 초대 코드가 pathSegments에 존재하는지 확인
    if (uri.pathSegments.isNotEmpty) {
      // host가 invite이므로, 첫 번째 세그먼트가 바로 초대 코드가 됩니다.
      final String inviteCode = uri.pathSegments.first;
      debugPrint('🔍 [딥링크 코드 포착]: $inviteCode');

      if (!mounted) return;

      try {
        // 선욱님과 승빈님이 만든 프로바이더에서 응답 데이터 수신 (.future 활용)
        final ChallengeDeepLinkResponse response = await ref.read(
          challengeIdByInviteCodeProvider(inviteCode).future,
        );

        if (!mounted) return;

        // 예외 케이스: 이미 챌린지에 참여 중인 유저인 경우
        if (response.alreadyParticipant) {
          showDialog(
            context: context,
            barrierDismissible: false, // 팝업 바깥을 눌러도 닫히지 않도록 설정
            builder: (context) => ConfirmDialog(
              title: '알림',
              content: '이미 참여하고 있는 챌린지입니다.\n홈 화면에서 확인해 주세요.',
              buttonText: '확인',
              onConfirm: () {
                _onItemTapped(0);
              },
            ),
          );
          return;
        }

        // 정상 케이스: 유효한 ID를 받았으므로 상세 페이지로 Push 이동
        if (response.challengeId != 0) {
          debugPrint('✈️ [화면 라우팅] 챌린지 상세 페이지 이동 ID: ${response.challengeId}');

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChallengeDetailScreen(
                challengeId: response.challengeId,
                challengeTitle: response.challengeTitle,
              ),
            ),
          );
        } else {
          _showErrorSnackBar('존재하지 않거나 만료된 초대 링크입니다.');
        }
      } catch (error) {
        if (mounted) {
          _showErrorSnackBar('네트워크 오류가 발생했습니다. 다시 시도해 주세요.');
        }
      }
    }
  }

  /// 실패 알림용 스낵바
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // 하단 탭 클릭 시 페이지 애니메이션 이동 공통 메서드
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    // 💡 메모리 누수 방지를 위한 감시 스트림 구독 해제 필수 보장
    _linkSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(),
      const StatisticsScreen(),
      FeedScreen(
        onSwipeToMain: (isNext) {
          if (isNext) {
            // '둘러보기' 탭(1번 인덱스)에서 오른쪽으로 밀었을 때 -> 소셜 화면으로 이동
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            // '친구' 탭(0번 인덱스)에서 왼쪽으로 밀었을 때 -> 통계 화면으로 이동
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
      ),
      const SocialMainScreen(),
      const MyPageMainScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: _selectedIndex == 2
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: pages,
      ),
      // 분리한 하단 바 위젯 호출
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
