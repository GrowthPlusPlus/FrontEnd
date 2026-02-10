/// 최초 작성자: 정승빈
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'social_repository.dart';
import 'social_model.dart';

// --- 메인 화면 ---

/// 클래스의 용도: 친구 검색, 받은 요청, 보낸 요청을 관리하는 친구 추가 메인 화면
class FriendAddScreen extends StatefulWidget {
  const FriendAddScreen({super.key});

  @override
  State<FriendAddScreen> createState() => FriendAddScreenState();
}

class FriendAddScreenState extends State<FriendAddScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final TextEditingController searchController = TextEditingController();
  final SocialRepository repository = SocialRepository();

  final List<SearchResultUser> userDatabase = [
    SearchResultUser(
      name: '장영실',
      title: '사용자 칭호',
      profileImage: 'assets/images/profiles/user1.png',
    ),
    SearchResultUser(name: '장영실입니다', title: '사용자 칭호'),
    SearchResultUser(name: '장영실입니다요', title: '사용자 칭호'),
    SearchResultUser(name: '장영실_123', title: '사용자 칭호'),
    SearchResultUser(name: '장영실_12345', title: '사용자 칭호'),
  ];

  List<SearchResultUser> filteredResults = [];
  bool isSearchPerformed = false;

  /// 함수의 용도: 컨트롤러 및 리포지토리 데이터 상태 복구
  /// 매개 변수: 없음
  /// 반환 값: 없음
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);

    for (var user in userDatabase) {
      user.isRequested = repository.sentRequests.any(
        (res) => res.name == user.name,
      );
      if (user.isRequested) {
        user.requestTime = repository.sentRequests
            .firstWhere((res) => res.name == user.name)
            .requestTime;
      }
    }
  }

  /// 함수의 용도: 사용된 리소스 해제
  /// 매개 변수: 없음
  /// 반환 값: 없음
  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  /// 함수의 용도: 입력된 쿼리를 기반으로 유저 데이터베이스 검색
  /// 매개 변수: String query (검색어)
  /// 반환 값: 없음
  void performSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      isSearchPerformed = true;
      filteredResults = userDatabase
          .where((user) => user.name.contains(query.trim()))
          .toList();
    });
  }

  /// 함수의 용도: 선택한 유저에게 친구 신청을 보내고 저장소에 기록
  /// 매개 변수: SearchResultUser user (대상 유저)
  /// 반환 값: 없음
  void sendFriendRequest(SearchResultUser user) {
    if (user.isRequested) return;
    setState(() {
      user.isRequested = true;
      user.requestTime = DateFormat(
        'yyyy년 MM월 dd일 HH:mm',
      ).format(DateTime.now());
      repository.addRequest(user);
    });
    displayToast('${user.name} 님에게 친구 신청을 보냈습니다!');
  }

  /// 함수의 용도: 보낸 친구 신청을 취소하고 저장소에서 삭제
  /// 매개 변수: SearchResultUser user (대상 유저)
  /// 반환 값: 없음
  void cancelFriendRequest(SearchResultUser user) {
    setState(() {
      user.isRequested = false;
      user.requestTime = null;
      repository.removeRequest(user.name);
    });
    displayToast('친구 신청을 취소했습니다.');
  }

  /// 함수의 용도: 커스텀 Overlay 애니메이션 토스트 표시
  /// 매개 변수: String message (출력 문구)
  /// 반환 값: 없음
  void displayToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => AnimatedToast(
        message: message,
        onDismissed: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }

  /// 함수의 용도: 메인 빌드 메서드
  /// 매개 변수: BuildContext context (빌드 컨텍스트)
  /// 반환 값: Widget (완성된 화면 위젯)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('친구 추가', style: AppTypography.h2),
      ),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            indicatorColor: AppColors.primaryAble,
            labelColor: AppColors.primaryAble,
            unselectedLabelColor: AppColors.gray2,
            labelStyle: AppTypography.b1.copyWith(fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: '친구 신청'),
              Tab(text: '받은 요청'),
              Tab(text: '보낸 요청'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [buildSearchTab(), buildReceivedTab(), buildSentTab()],
            ),
          ),
        ],
      ),
    );
  }

  /// 함수의 용도: 검색창과 검색 결과를 포함하는 탭 빌드
  Widget buildSearchTab() {
    return Column(
      children: [
        buildSearchInputSection(),
        if (isSearchPerformed) ...[
          buildResultCountHeader(filteredResults.length),
          Expanded(child: buildSearchResultList()),
        ] else
          const Expanded(child: SizedBox.expand()),
      ],
    );
  }

  /// 함수의 용도: 받은 요청 목록을 포함하는 탭 빌드
  Widget buildReceivedTab() {
    final receivedList = repository.receivedRequests;
    return Container(
      color: const Color(0x7FDFE1DC),
      child: receivedList.isEmpty
          ? const Center(child: Text('받은 요청이 없습니다.', style: AppTypography.b2))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: receivedList.length,
              itemBuilder: (context, index) =>
                  buildReceivedCard(receivedList[index]),
            ),
    );
  }

  /// 함수의 용도: 보낸 요청 목록을 포함하는 탭 빌드
  Widget buildSentTab() {
    final sentList = repository.sentRequests;
    return Container(
      color: const Color(0x7FDFE1DC),
      child: sentList.isEmpty
          ? const Center(child: Text('보낸 요청이 없습니다.', style: AppTypography.b2))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sentList.length,
              itemBuilder: (context, index) => buildSentCard(sentList[index]),
            ),
    );
  }

  /// 함수의 용도: 검색창 입력 필드 영역 생성
  Widget buildSearchInputSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/icons/search_icon.svg',
              width: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.gray3,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: searchController,
                onSubmitted: performSearch,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: '닉네임을 검색하세요',
                  hintStyle: AppTypography.b2,
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: AppTypography.b1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 함수의 용도: 검색 결과 수 헤더 생성
  Widget buildResultCountHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text('검색 결과 $count명', style: AppTypography.b2),
    );
  }

  /// 함수의 용도: 검색된 유저 리스트 생성
  Widget buildSearchResultList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final user = filteredResults[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              buildProfileCircle(user.profileImage, 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppTypography.h3.copyWith(fontSize: 15),
                    ),
                    Text(
                      user.title,
                      style: AppTypography.c1.copyWith(color: AppColors.gray2),
                    ),
                  ],
                ),
              ),
              buildRequestButton(user),
            ],
          ),
        );
      },
    );
  }

  /// 함수의 용도: 받은 요청 카드 위젯 생성
  Widget buildReceivedCard(ReceivedRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              buildProfileCircle(req.profileImage, 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.name, style: AppTypography.h3),
                    Text(
                      '함께 아는 친구 ${req.mutualFriends}명',
                      style: AppTypography.c1.copyWith(color: AppColors.gray2),
                    ),
                    Text(
                      req.time,
                      style: AppTypography.c2.copyWith(color: AppColors.gray3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildActionButton(
                  '거절',
                  const Color(0x7FDFE1DC),
                  AppColors.gray2,
                  () {
                    setState(() {
                      repository.rejectFriendRequest(req);
                    });
                    displayToast('${req.name} 님의 요청을 거절했습니다.');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildActionButton(
                  '수락',
                  AppColors.primaryAble,
                  Colors.white,
                  () {
                    setState(() {
                      repository.acceptFriendRequest(req);
                    });
                    displayToast('${req.name} 님과 친구가 되었습니다!');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 함수의 용도: 보낸 요청 카드 위젯 생성
  /// 매개 변수: SearchResultUser user (대상 유저)
  Widget buildSentCard(SearchResultUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  buildProfileCircle(user.profileImage, 48),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: AppTypography.h3),
                      Text(
                        user.requestTime ?? '',
                        style: AppTypography.c2.copyWith(
                          color: AppColors.gray3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              buildBadge('대기 중'),
            ],
          ),
          const SizedBox(height: 16),
          buildActionButton(
            '요청 취소',
            const Color(0x7FDFE1DC),
            AppColors.gray2,
            () => cancelFriendRequest(user),
          ),
        ],
      ),
    );
  }

  /// 함수의 용도: 상태 표시를 위한 배지 위젯 생성
  /// 매개 변수: String text (배지 문구)
  Widget buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF444444), fontSize: 12),
      ),
    );
  }

  /// 함수의 용도: 공통 버튼 위젯 생성
  /// 매개 변수: String label, Color bg, Color text, VoidCallback onTap
  Widget buildActionButton(
    String label,
    Color bg,
    Color text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.b1.copyWith(
            color: text,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 함수의 용도: 유저 프로필 이미지 원형 위젯 생성
  /// 매개 변수: String? imagePath, double size
  Widget buildProfileCircle(String? imagePath, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0x7FDFE1DC),
        shape: BoxShape.circle,
        image: imagePath != null
            ? DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover)
            : null,
      ),
      child: imagePath == null
          ? Center(
              child: SvgPicture.asset(
                'assets/images/icons/default_profile_icon.svg',
                width: size * 0.6,
              ),
            )
          : null,
    );
  }

  /// 함수의 용도: 검색 결과의 친구 신청/신청됨 버튼 생성
  /// 매개 변수: SearchResultUser user (대상 유저)
  Widget buildRequestButton(SearchResultUser user) {
    return GestureDetector(
      onTap: () => sendFriendRequest(user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: user.isRequested ? AppColors.disable : AppColors.primaryAble,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          user.isRequested ? '신청됨' : '친구 신청',
          style: AppTypography.c1.copyWith(
            color: user.isRequested ? AppColors.gray2 : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// --- 애니메이션 컴포넌트 ---

/// 클래스의 용도: 화면 하단에 메시지를 띄우는 애니메이션 토스트 위젯
class AnimatedToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const AnimatedToast({
    super.key,
    required this.message,
    required this.onDismissed,
  });

  @override
  State<AnimatedToast> createState() => AnimatedToastState();
}

class AnimatedToastState extends State<AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> opacityAnimation;

  /// 함수의 용도: 애니메이션 컨트롤러 및 애니메이션 초기화
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutQuart));

    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    controller.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        await controller.reverse();
        widget.onDismissed();
      }
    });
  }

  /// 함수의 용도: 애니메이션 컨트롤러 해제
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: opacityAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC1A1D1B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: AppTypography.b1.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
