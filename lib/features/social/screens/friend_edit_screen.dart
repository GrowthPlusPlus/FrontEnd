// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../core/utils/korean_string_utils.dart';
import '../../../shared/models/user.dart';
import '../../../shared/widgets/animated_toast.dart';
import '../provider/friend_list_provider.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/friend_edit_tile.dart';

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
  void showDeleteDialog(User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteConfirmDialog(
        userNickname: user.nickname,
        onDelete: () async {
          try {
            // 새로 생성한 Provider의 Notifier를 통한 삭제 로직 호출
            await ref
                .read(friendListProvider.notifier)
                .removeFriend(user.nickname);

            if (!mounted) return;

            // 삭제 성공 시 로컬 리스트에서 제거 및 UI 업데이트
            setState(() {
              totalList.removeWhere((u) => u.nickname == user.nickname);
              filterList(searchController.text);
            });

            // 다이얼로그가 아직 열려있는지 확인 후 닫기
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }

            displayToast(context, '${user.nickname} 님이 삭제되었습니다.');
          } catch (e) {
            if (!mounted) return;
            // 다이얼로그가 아직 열려있는지 확인 후 닫기
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
            displayToast(context, '삭제에 실패했습니다. 다시 시도해 주세요.');
            debugPrint('친구 삭제 실패: $e'); // 디버그 로그
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
          _buildSearchHeader(),
          Expanded(child: _buildEditListView()),
        ],
      ),
    );
  }

  // 검색창 영역 빌드
  Widget _buildSearchHeader() {
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

  // 편집 리스트 빌드
  Widget _buildEditListView() {
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
          onDeleteTap: () => showDeleteDialog(user),
        );
      },
    );
  }
}
