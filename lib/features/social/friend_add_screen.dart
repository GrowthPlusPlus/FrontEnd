/// 최초 작성자: 정승빈
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'social_repository.dart';
import 'social_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// --- 메인 화면 ---

/// 클래스의 용도: 친구 검색, 받은 요청, 보낸 요청을 관리하는 친구 추가 메인 화면
class FriendAddScreen extends ConsumerStatefulWidget {
  const FriendAddScreen({super.key});

  @override
  ConsumerState<FriendAddScreen> createState() => FriendAddScreenState();
}

class FriendAddScreenState extends ConsumerState<FriendAddScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final TextEditingController searchController = TextEditingController();

  // 서버로부터 받아올 데이터 리스트
  List<SearchResultUser> filteredResults = [];
  List<ReceivedRequest> receivedRequests = [];
  List<SearchResultUser> sentRequests = [];
  bool isSearchPerformed = false;
  bool isLoading = false;

  /// 함수의 용도: 컨트롤러 및 리포지토리 데이터 상태 복구
  /// 매개 변수: 없음
  /// 반환 값: 없음
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    // 화면 진입 시 받은 요청과 보낸 요청 목록을 먼저 불러옵니다.
    _fetchInitialData();
  }

  /// 초기 데이터(받은/보낸 요청) 로드
  Future<void> _fetchInitialData() async {
    final repo = ref.read(socialRepositoryProvider);
    try {
      final received = await repo
          .getReceivedRequests(); // GET /api/users/friend/request/received
      final sent = await repo
          .getSentRequests(); // GET /api/users/friend/request/sent
      setState(() {
        receivedRequests = received;
        sentRequests = sent;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      // 개발자를 위한 상세 로그
      debugPrint('---------- [초기 데이터 로드 오류] ----------');
      debugPrint('상태 코드: ${e.response?.statusCode}');
      debugPrint('에러 경로: ${e.requestOptions.path}');
      debugPrint('에러 내용: ${e.response?.data}');
      debugPrint('-----------------------------------------');

      displayToast('데이터를 불러오는데 실패했습니다.');
    } catch (e) {
      if (!mounted) return;
      debugPrint('초기 데이터 로드 중 알 수 없는 에러: $e');
      displayToast('데이터 로딩 중 오류가 발생했습니다.');
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

  /// 닉네임 유저 검색 수행
  Future<void> performSearch() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      isSearchPerformed = true;
    });

    try {
      final results = await ref
          .read(socialRepositoryProvider)
          .searchUsers(query);

      if (!mounted) return;
      setState(() {
        filteredResults = results;
        isLoading = false;
      });
    } on DioException catch (e) {
      // DioException을 직접 잡아 구체적인 원인 파악
      if (!mounted) return;

      // 디버그 콘솔에 상세 오류 출력
      debugPrint('---------- [검색 오류 발생] ----------');
      debugPrint('상태 코드: ${e.response?.statusCode}');
      debugPrint('에러 데이터: ${e.response?.data}');
      debugPrint('에러 메시지: ${e.message}');
      debugPrint('------------------------------------');

      setState(() => isLoading = false);

      // 사용자에게는 최소한의 정보만 전달
      displayToast('검색 결과가 없거나 오류가 발생했습니다.');
    } catch (e) {
      if (!mounted) return;
      debugPrint('시스템 오류: $e');
      setState(() => isLoading = false);
      displayToast('잠시 후 다시 시도해 주세요.');
    }
  }

  /// 친구 신청 보내기
  Future<void> sendFriendRequestAction(SearchResultUser user) async {
    // 1. 이미 신청된 상태면 아무 작업도 하지 않음 (중복 방지)
    if (user.isRequested) return;

    try {
      // POST /api/users/friend/request/{toUserNickName}
      await ref.read(socialRepositoryProvider).sendFriendRequest(user.nickname);

      // 2. 비동기 작업 후 위젯이 여전히 화면에 있는지 확인 (unmounted 에러 방지)
      if (!mounted) return;

      setState(() {
        user.isRequested = true; // 로컬 상태 즉시 반영
      });

      _fetchInitialData(); // 보낸 요청 목록 갱신
      displayToast('${user.nickname} 님에게 친구 신청을 보냈습니다!');
    } on DioException catch (e) {
      if (!mounted) return;

      // 🔥 [디버깅용 로그] 정확한 에러 원인 확인
      debugPrint('---------- [친구 신청 실패] ----------');
      debugPrint('대상 닉네임: ${user.nickname}');
      debugPrint('상태 코드: ${e.response?.statusCode}');
      debugPrint('서버 응답: ${e.response?.data}'); // 에러 메시지나 코드 확인
      debugPrint('------------------------------------');

      // 사용자에게는 기존과 동일하게 안내
      displayToast('이미 신청되었거나 신청에 실패했습니다.');
    } catch (e) {
      if (!mounted) return;
      debugPrint('친구 신청 중 알 수 없는 에러: $e');
      displayToast('신청 중 오류가 발생했습니다.');
    }
  }

  /// 신청 취소하기
  Future<void> cancelFriendRequestAction(SearchResultUser user) async {
    if (user.requestId == null) return;
    try {
      // PATCH /api/users/friend/request/sent/cancel/{requestId}
      await ref.read(socialRepositoryProvider).cancelRequest(user.requestId!);
      _fetchInitialData();
      displayToast('친구 신청을 취소했습니다.');
    } catch (e) {
      displayToast('취소에 실패했습니다.');
    }
  }

  /// 친구 수락하기
  Future<void> acceptFriendRequestAction(ReceivedRequest req) async {
    try {
      // PATCH /api/users/friend/request/accept/{requestId}
      await ref.read(socialRepositoryProvider).acceptRequest(req.requestId);
      if (!mounted) return;
      _fetchInitialData(); // 목록 갱신
      displayToast('${req.nickname} 님과 친구가 되었습니다!');
    } on DioException catch (e) {
      if (!mounted) return;

      // 🔥 [수락 실패 디버그]
      debugPrint('---------- [친구 수락 실패] ----------');
      debugPrint('대상 닉네임: ${req.nickname}');
      debugPrint('대상 Request ID: ${req.requestId}');
      debugPrint('상태 코드: ${e.response?.statusCode}');
      debugPrint('에러 메시지: ${e.response?.data}');
      debugPrint('요청 경로: ${e.requestOptions.path}');
      debugPrint('------------------------------------');

      displayToast('수락 처리에 실패했습니다. (코드: ${e.response?.statusCode})');
    } catch (e) {
      if (!mounted) return;
      debugPrint('수락 중 알 수 없는 에러: $e');
      displayToast('수락 중 오류가 발생했습니다.');
    }
  }

  /// 친구 거절하기
  Future<void> rejectFriendRequestAction(ReceivedRequest req) async {
    try {
      // PATCH /api/users/friend/request/reject/{rejectId}
      // 주의: requestId가 null인지 확인이 필요할 수 있습니다.
      await ref.read(socialRepositoryProvider).rejectRequest(req.requestId);

      if (!mounted) return;
      _fetchInitialData(); // 목록 갱신
      displayToast('요청을 거절했습니다.');
    } on DioException catch (e) {
      if (!mounted) return;

      // 🔥 [거절 실패 디버그]
      debugPrint('---------- [친구 거절 실패] ----------');
      debugPrint('거절할 ID: ${req.requestId}');
      debugPrint('상태 코드: ${e.response?.statusCode}');
      debugPrint('에러 메시지: ${e.response?.data}');
      debugPrint('요청 경로: ${e.requestOptions.path}');
      debugPrint('------------------------------------');

      displayToast('거절 처리에 실패했습니다. (코드: ${e.response?.statusCode})');
    } catch (e) {
      if (!mounted) return;
      debugPrint('거절 중 알 수 없는 에러: $e');
      displayToast('거절 중 오류가 발생했습니다.');
    }
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
    return Container(
      color: const Color(0x7FDFE1DC),
      child: receivedRequests.isEmpty
          ? const Center(child: Text('받은 요청이 없습니다.', style: AppTypography.b2))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: receivedRequests.length,
              itemBuilder: (context, index) {
                final req = receivedRequests[index];
                return buildReceivedCard(
                  req,
                  onAccept: () => acceptFriendRequestAction(req),
                  onReject: () => rejectFriendRequestAction(req),
                );
              },
            ),
    );
  }

  /// 함수의 용도: 보낸 요청 목록을 포함하는 탭 빌드
  Widget buildSentTab() {
    return Container(
      color: const Color(0x7FDFE1DC),
      child: sentRequests.isEmpty
          ? const Center(child: Text('보낸 요청이 없습니다.', style: AppTypography.b2))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sentRequests.length,
              itemBuilder: (context, index) =>
                  buildSentCard(sentRequests[index]),
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
                onSubmitted: (query) => performSearch(),
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
              buildProfileCircle(user.profileImageUrl, 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname,
                      style: AppTypography.h3.copyWith(fontSize: 15),
                    ),
                    Text(
                      "해냄 메이트", // api에 title이 없으므로 기본값 설정
                      //TODO: 추후 title 필드가 추가되면 반영
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
  Widget buildReceivedCard(
    ReceivedRequest req, {
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
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
              buildProfileCircle(req.profileImageUrl, 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.nickname, style: AppTypography.h3),
                    Text(
                      "함께 아는 친구 0명",
                      //"함께 아는 친구 ${req.mutualFriends}명",
                      //TODO: 추후 mutualFriends 필드가 추가되면 반영
                      style: AppTypography.c1.copyWith(color: AppColors.gray2),
                    ),
                    Text(
                      DateFormat(
                        'yyyy년 MM월 dd일',
                      ).format(DateTime.parse(req.createdAt)),
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
                  onReject, // 전달받은 거절 액션 연결
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildActionButton(
                  '수락',
                  AppColors.primaryAble,
                  Colors.white,
                  onAccept, // 전달받은 수락 액션 연결
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
                  buildProfileCircle(user.profileImageUrl, 48),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.nickname, style: AppTypography.h3),
                      Text(
                        user.createdAt != null
                            ? DateFormat(
                                'yyyy년 MM월 dd일',
                              ).format(DateTime.parse(user.createdAt!))
                            : '',
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
            () => cancelFriendRequestAction(user), // 위에서 만든 취소 액션 연결
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

  /// 함수의 용도: 유저 프로필 이미지 원형 위젯 생성 (Asset -> Network 이미지 대응)
  /// 매개 변수: String? imagePath, double size
  Widget buildProfileCircle(String? imageUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0x7FDFE1DC),
        shape: BoxShape.circle,
        // 서버에서 오는 이미지는 NetworkImage로 처리해야 합니다.
        image: imageUrl != null && imageUrl.startsWith('http')
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : (imageUrl != null
                  ? DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null),
      ),
      child: imageUrl == null
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
      // 🔥 이미 신청된 상태(isRequested)면 클릭 이벤트를 null로 설정하여 비활성화
      onTap: user.isRequested ? null : () => sendFriendRequestAction(user),
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
