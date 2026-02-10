/// 최초 작성자: 정승빈

library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'social_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'social_repository.dart';
import '../../core/utils/korean_string_utils.dart';

/// 클래스의 용도: 기존 친구 목록을 검색하고 삭제할 수 있는 편집 화면
class FriendEditScreen extends ConsumerStatefulWidget {
  // ConsumerStatefulWidget으로 변경
  final List<Friend> initialFriends;

  const FriendEditScreen({super.key, required this.initialFriends});

  @override
  ConsumerState<FriendEditScreen> createState() => FriendEditScreenState();
}

class FriendEditScreenState extends ConsumerState<FriendEditScreen> {
  final TextEditingController searchController = TextEditingController();
  late List<Friend> totalList;
  List<Friend> filteredList = [];

  /// 함수의 용도: 초기 상태 설정 및 원본 리스트 복사
  /// 매개 변수: 없음
  /// 반환 값: 없음
  @override
  void initState() {
    super.initState();
    totalList = List.from(widget.initialFriends);
    filteredList = List.from(totalList);
    _applySortAndState();
  }

  /// 함수의 용도: 입력 쿼리에 따라 리스트 필터링
  /// 매개 변수: String query (검색어)
  /// 반환 값: 없음
  void filterList(String query) {
    setState(() {
      String trimmedQuery = query.trim().toLowerCase();
      if (trimmedQuery.isEmpty) {
        filteredList = List.from(totalList);
      } else {
        filteredList = totalList.where((friend) {
          String nickname = friend.nickname.toLowerCase();
          return nickname.contains(trimmedQuery) ||
              KoreanStringUtils.getChoseongString(
                nickname,
              ).contains(trimmedQuery);
        }).toList();
      }
      _applySortAndState();
    });
  }

  /// 정렬 로직 호출 및 상태 반영
  void _applySortAndState() {
    filteredList.sort(
      (a, b) => KoreanStringUtils.compareKoreanFirst(a.nickname, b.nickname),
    );
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

  /// 함수의 용도: 삭제 확인 다이얼로그 노출
  /// 매개 변수: Friend friend (삭제 대상 친구)
  /// 반환 값: 없음
  void showDeleteDialog(Friend friend) {
    showDialog(
      context: context,
      // 1. 여기서 context 이름을 dialogContext로 변경하여 혼동 방지
      builder: (dialogContext) => DeleteConfirmDialog(
        usernickName: friend.nickname,
        onDelete: () async {
          try {
            await ref
                .read(socialRepositoryProvider)
                .deleteFriend(friend.nickname);

            // 2. 화면(FriendEditScreen)이 살아있는지 확인 (setState용)
            if (!mounted) return;

            setState(() {
              totalList.removeWhere((f) => f.nickname == friend.nickname);
              filterList(searchController.text);
            });

            // 3. 다이얼로그가 아직 열려있는지 확인 후 닫기 (Navigator용)
            // 'context' 대신 'dialogContext'를 사용하세요.
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }

            displayToast('${friend.nickname} 님이 삭제되었습니다.');
          } catch (e) {
            if (!mounted) return;

            // 여기서도 dialogContext가 살아있는지 확인하면 더 안전합니다.
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }

            displayToast('삭제에 실패했습니다. 다시 시도해 주세요.');
            debugPrint('친구 삭제 실패: $e');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context, totalList),
        ),
        centerTitle: true,
        title: const Text('친구 목록 편집', style: AppTypography.h2),
      ),
      body: Column(
        children: [
          buildSearchHeader(),
          Expanded(child: buildEditListView()),
        ],
      ),
    );
  }

  /// 함수의 용도: 검색창 영역 빌드
  /// 매개 변수: 없음
  /// 반환 값: Widget
  Widget buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                onChanged: filterList,
                decoration: const InputDecoration(
                  hintText: '친구 검색',
                  hintStyle: AppTypography.b2,
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: AppTypography.b2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 함수의 용도: 필터링된 편집 리스트뷰 빌드
  /// 매개 변수: 없음
  /// 반환 값: Widget
  Widget buildEditListView() {
    if (filteredList.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.', style: AppTypography.b2));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredList.length,
      itemBuilder: (context, index) => buildEditTile(filteredList[index]),
    );
  }

  /// 함수의 용도: 개별 친구 편집 항목 타일 생성
  /// 매개 변수: Friend friend (대상 친구 데이터)
  /// 반환 값: Widget
  Widget buildEditTile(Friend friend) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0x7FDFE1DC),
              shape: BoxShape.circle,
              image: friend.profileImageUrl != null
                  ? DecorationImage(
                      image: AssetImage(friend.profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: friend.profileImageUrl == null
                ? Center(
                    child: SvgPicture.asset(
                      'assets/images/icons/default_profile_icon.svg',
                      width: 24,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.nickname,
                  style: AppTypography.h3.copyWith(fontSize: 15),
                ),
                Text(
                  friend.title,
                  style: AppTypography.c1.copyWith(color: AppColors.gray2),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showDeleteDialog(friend),
            icon: SvgPicture.asset(
              'assets/images/icons/big_trash_icon.svg',
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.notification,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 클래스의 용도: 친구 삭제 여부를 묻는 팝업 다이얼로그
class DeleteConfirmDialog extends StatelessWidget {
  final String usernickName;
  final VoidCallback onDelete;

  const DeleteConfirmDialog({
    super.key,
    required this.usernickName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('친구 삭제', style: AppTypography.h2),
            const SizedBox(height: 12),
            Text(
              '$usernickName 님을 삭제하시겠습니까?',
              style: AppTypography.b2.copyWith(color: AppColors.gray2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x7FDFE1DC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('취소', style: AppTypography.b1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x7FDFE1DC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '삭제하기',
                          style: AppTypography.b1.copyWith(
                            color: AppColors.notification,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
  late AnimationController animationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> opacityAnimation;

  /// 함수의 용도: 애니메이션 초기화 및 자동 소멸 로직
  /// 매개 변수: 없음
  /// 반환 값: 없음
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutQuart,
          ),
        );

    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animationController.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        await animationController.reverse();
        widget.onDismissed();
      }
    });
  }

  /// 함수의 용도: 애니메이션 컨트롤러 해제
  /// 매개 변수: 없음
  /// 반환 값: 없음
  @override
  void dispose() {
    animationController.dispose();
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
