// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../models/user_search_card.dart';
import '../provider/user_search_provider.dart';
import '../../../shared/widgets/animated_toast.dart';
import '../widgets/user_search_tile.dart';
import 'package:haenaem/shared/widgets/custom_search_bar.dart';

class UserSearchView extends ConsumerStatefulWidget {
  const UserSearchView({super.key});

  @override
  ConsumerState<UserSearchView> createState() => _UserSearchViewState();
}

class _UserSearchViewState extends ConsumerState<UserSearchView> {
  final TextEditingController searchController = TextEditingController();
  bool isSearchPerformed = false; // 검색창에 입력 후 엔터를 쳤는지 여부만 관리

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> performSearch() async {
    if (searchController.text.trim().isEmpty) return;

    setState(() => isSearchPerformed = true);

    // 비즈니스 로직은 Provider에게 위임
    await ref
        .read(userSearchProvider.notifier)
        .searchUsers(searchController.text);
  }

  Future<void> sendFriendRequestAction(UserSearchCard card) async {
    try {
      await ref.read(userSearchProvider.notifier).sendFriendRequest(card);
      if (mounted) {
        displayToast(context, '${card.user.nickname} 님에게 친구 신청을 보냈습니다!');
      }
    } catch (e) {
      if (mounted) {
        displayToast(context, '이미 신청되었거나 신청에 실패했습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. 검색 상태 구독
    final searchState = ref.watch(userSearchProvider);

    return Column(
      children: [
        _buildSearchInputSection(),

        // 2. 검색 상태에 따른 UI 렌더링
        Expanded(
          child: searchState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              // 검색 에러 시 토스트는 유지하되 화면에는 에러 문구 표시
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) displayToast(context, '검색 중 오류가 발생했습니다.');
              });
              return const Center(child: Text('검색 결과가 없거나 오류가 발생했습니다.'));
            },
            data: (results) {
              if (!isSearchPerformed) {
                return const SizedBox.expand();
              }
              return Column(
                children: [
                  _buildResultCountHeader(results.length),
                  Expanded(child: _buildSearchResultList(results)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInputSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: CustomSearchBar(
        controller: searchController,
        hintText: '닉네임을 검색하세요',
        onSubmitted: (_) => performSearch(), // onChanged 대신 엔터를 쳤을 때 작동
      ),
    );
  }

  Widget _buildResultCountHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text('검색 결과 $count명', style: AppTypography.b2),
    );
  }

  Widget _buildSearchResultList(List<UserSearchCard> results) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final card = results[index];
        return UserSearchTile(
          searchCard: card,
          onRequest: () => sendFriendRequestAction(card),
        );
      },
    );
  }
}
