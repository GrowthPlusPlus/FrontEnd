import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../views/report_view.dart';
import '../provider/admin_auth_provider.dart';
import 'package:haenaem/features/auth/login/login_screen.dart';
import 'package:haenaem/shared/widgets/select_dialog.dart';

// 최초 작성자: 강선욱
// 관리자 메인 페이지
// 게시글, 댓글을 신고 횟수 순으로 조회할 수 있는 페이지
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _articleScrollController = ScrollController();
  final ScrollController _commentScrollController = ScrollController();
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _previousIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _articleScrollController.dispose();
    _commentScrollController.dispose();
    super.dispose();
  }

  /// 탭을 재탭했을 때 해당 탭의 스크롤을 최상단으로 이동
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => SelectDialog(
                title: '로그아웃',
                content: '관리자 계정을 로그아웃하고\n로그인 화면으로 돌아가시겠습니까?',
                confirmText: '로그아웃',
                cancelText: '취소',
                onConfirm: () async {
                  // 1. 토큰 삭제
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'accessToken');
                  await storage.delete(key: 'refreshToken');

                  // 2. 프로바이더 리셋
                  ref.read(adminLoginProvider.notifier).reset();

                  if (!context.mounted) return;

                  // 3. 로그인 화면으로 이동
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '신고 내역',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryAble,
          unselectedLabelColor: AppColors.gray4,
          indicatorColor: AppColors.primaryAble,
          indicatorWeight: 1,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: AppTypography.b1,
          unselectedLabelStyle: AppTypography.b1,
          onTap: (index) {
            // 같은 탭을 다시 탭하면 최상단으로 스크롤
            if (_previousIndex == index) {
              if (index == 0) {
                _scrollToTop(_articleScrollController);
              } else {
                _scrollToTop(_commentScrollController);
              }
            }
          },
          tabs: const [
            Tab(text: '게시글'),
            Tab(text: '댓글'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ArticleView(scrollController: _articleScrollController),
          CommentView(scrollController: _commentScrollController),
        ],
      ),
    );
  }
}
