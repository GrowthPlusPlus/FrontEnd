// 최초 작성자: 강선욱
// 공통 탭바 위젯
// - TabController 생성 및 관리
// - 공통 TabBar 스타일 적용
// - TabBarView 포함
// - 현재 탭 재탭 시 스크롤 최상단 이동 (scrollControllers 전달 시에만 동작)

import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class CustomTabBar extends StatefulWidget {
  // 탭 항목 텍스트 목록
  final List<String> tabs;

  // 각 탭에 해당하는 view들 리스트
  final List<Widget> children;

  // 초기 탭 인덱스 (기본값: 0)
  // 화면 진입시 가장 먼저 보이는 탭 설정
  final int initialIndex;

  // 탭 변경 시 호출되는 콜백
  final void Function(int index)? onTabChanged;

  // 현재 탭 재탭 시 스크롤을 최상단으로 올릴 ScrollController 목록
  // tabs 리스트와 동일한 순서로 전달해야 함
  // null이면 스크롤 동작 비활성화
  final List<ScrollController>? scrollControllers;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.children,
    this.initialIndex = 0,
    this.onTabChanged,
    this.scrollControllers,
  }) : assert(
         tabs.length == children.length,
         'tabs 길이와 children 길이는 동일해야 합니다.',
       ),
       assert(
         scrollControllers == null || scrollControllers.length == tabs.length,
         'scrollControllers 길이는 tabs 길이와 동일해야 합니다.',
       );

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _previousIndex;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.initialIndex;
    _initTabController();
  }

  void _initTabController() {
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    // 탭 애니메이션 진행 중 중복 호출 방지
    if (!_tabController.indexIsChanging) {
      widget.onTabChanged?.call(_tabController.index);
      _previousIndex = _tabController.index;
    }
  }

  @override
  void didUpdateWidget(covariant CustomTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 탭 개수나 초기 인덱스가 부모 위젯 리빌드로 인해 달라진 경우 처리
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabController.removeListener(_handleTabSelection);
      _tabController.dispose();
      _initTabController();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _scrollToTop(int index) {
    final controllers = widget.scrollControllers;
    if (controllers == null || index >= controllers.length) return;

    final controller = controllers[index];
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
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryAble,
          unselectedLabelColor: AppColors.gray2,
          indicatorColor: AppColors.primaryAble,
          indicatorWeight: 1,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: AppTypography.b1.copyWith(color: AppColors.primaryAble),
          unselectedLabelStyle: AppTypography.b1.copyWith(
            color: AppColors.gray2,
          ),
          tabs: widget.tabs.map((t) => Tab(text: t)).toList(),
          onTap: (index) {
            // 이미 활성화되어 있던 탭을 재선택했을 때 최상단 스크롤
            if (_previousIndex == index) {
              _scrollToTop(index);
            }
          },
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
