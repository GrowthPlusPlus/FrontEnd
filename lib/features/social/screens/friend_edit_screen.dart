// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../core/utils/korean_string_utils.dart';
import '../../../shared/models/user.dart';
import '../../../shared/widgets/animated_toast.dart';
import '../provider/friend_list_provider.dart';
// import '../widgets/delete_confirm_dialog.dart';
import 'package:haenaem/shared/widgets/select_dialog.dart';
import '../widgets/friend_edit_tile.dart';
import 'package:haenaem/shared/widgets/custom_search_bar.dart';

class FriendEditScreen extends ConsumerStatefulWidget {
  final List<User> initialFriends; // 초기 친구 목록을 전달받는 매개변수

  const FriendEditScreen({super.key, required this.initialFriends});

  @override
  ConsumerState<FriendEditScreen> createState() => _FriendEditScreenState();
}

class _FriendEditScreenState extends ConsumerState<FriendEditScreen> {
  final TextEditingController searchController = TextEditingController();
  late List<User> totalList;
  List<User> filteredList = [];

  @override
  void initState() {
    super.initState();
    totalList = List.from(widget.initialFriends);
    filteredList = List.from(totalList);
    _applySortAndState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // 입력 쿼리에 따라 리스트 필터링
  void filterList(String query) {
    setState(() {
      String trimmedQuery = query.trim().toLowerCase();
      if (trimmedQuery.isEmpty) {
        filteredList = List.from(totalList);
      } else {
        filteredList = totalList.where((user) {
          String nickname = user.nickname.toLowerCase();
          return nickname.contains(trimmedQuery) ||
              KoreanStringUtils.getChoseongString(
                nickname,
              ).contains(trimmedQuery);
        }).toList();
      }
      _applySortAndState();
    });
  }

  // 정렬 로직 호출 및 상태 반영
  void _applySortAndState() {
    filteredList.sort(
      (a, b) => KoreanStringUtils.compareKoreanFirst(a.nickname, b.nickname),
    );
  }

  // 삭제 확인 다이얼로그 표시
  void showDeleteDialog(User user, AppColorsExtension appColors) {
    showDialog(
      context: context,
      builder: (dialogContext) => SelectDialog(
        title: '친구 삭제',
        content: '${user.nickname} 님을 삭제하시겠습니까?',
        confirmText: '삭제하기',
        confirmTextColor: appColors.notification,
        cancelText: '취소',

        // [취소] 클릭 시 단순히 다이얼로그 닫기
        onCancel: () => Navigator.of(dialogContext).pop(),

        // [삭제] 클릭 시 중간 단계 없이 곧바로 비즈니스 로직 가동
        onConfirm: () async {
          try {
            // 1. Notifier를 통한 서버 삭제 API 호출
            await ref
                .read(friendListProvider.notifier)
                .removeFriend(user.nickname);

            if (!mounted) return;

            // 2. 삭제 성공 시 로컬 리스트에서 제거 및 UI 즉시 업데이트
            setState(() {
              totalList.removeWhere((u) => u.nickname == user.nickname);
              filterList(searchController.text);
            });

            // 3. 안전하게 다이얼로그 닫기
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }

            if (context.mounted) {
              displayToast(context, '${user.nickname} 님이 삭제되었습니다.');
            }
          } catch (e) {
            // 에러 발생 시 다이얼로그를 닫고 토스트 알림
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
            if (context.mounted) {
              displayToast(context, '삭제에 실패했습니다. 다시 시도해 주세요.');
            }
            debugPrint('친구 삭제 실패: $e');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: AppBar(
        backgroundColor: appColors.whiteToBlack,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.blackToWhite),
          onPressed: () => Navigator.pop(context, totalList),
        ),
        centerTitle: true,
        title: const Text('친구 목록 편집', style: AppTypography.h2),
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(child: _buildEditListView(appColors)),
        ],
      ),
    );
  }

  // 검색창 영역 빌드
  // 검색창 영역 빌드
  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: CustomSearchBar(
        controller: searchController,
        hintText: '친구 검색',
        onChanged: filterList,
      ),
    );
  }

  // 편집 리스트 빌드
  Widget _buildEditListView(AppColorsExtension appColors) {
    if (filteredList.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.', style: AppTypography.b2));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final user = filteredList[index];
        return FriendEditTile(
          user: user,
          onDeleteTap: () => showDeleteDialog(user, appColors),
        );
      },
    );
  }
}
