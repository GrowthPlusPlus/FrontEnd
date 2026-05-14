// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/feed/screens/challenge_detail_screen.dart'; // 챌린지 소개 화면 뷰 재활용
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/challenge_search_provider.dart';
import 'package:haenaem/shared/models/search_challenge_card.dart';
import '../widgets/challenge_search_card.dart';
import 'package:haenaem/shared/models/user.dart';
import 'package:haenaem/features/user/provider/user_provider.dart';
import 'package:haenaem/features/feed/provider/feed_provider.dart';

class ChallengeSearchScreen extends ConsumerStatefulWidget {
  const ChallengeSearchScreen({super.key});
  @override
  ConsumerState<ChallengeSearchScreen> createState() =>
      _ChallengeSearchScreenState();
}

class _ChallengeSearchScreenState extends ConsumerState<ChallengeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentKeyword = "";

  @override
  Widget build(BuildContext context) {
    // 사용자 프로필 정보 가져오기 (헤더 이름용)
    final currentUser = ref.watch(currentUserProvider);

    // 검색어가 있을 때만 api 호출
    final searchResults = ref.watch(
      searchChallengesProvider(keyword: _currentKeyword),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.black,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '챌린지 탐색',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: AppColors.gray4),
          // 검색창 영역
          _buildSearchBar(),

          // 챌린지 카드 리스트 영역
          Expanded(
            child: _currentKeyword.isEmpty
                ? _buildRecommendationSection(
                    currentUser,
                  ) // 💡 검색어 없을 때 추천 섹션 노출
                : _buildSearchResults(searchResults), // 검색어 있을 때 결과 노출
          ),
        ],
      ),
    );
  }

  // ── AI 추천 섹션 구현 ────────────────────────────
  Widget _buildRecommendationSection(User? currentUser) {
    final userName = currentUser?.nickname ?? "해냄";

    // 💡 AI 추천 데이터 구독 (feed_provider에 정의한 FutureProvider)
    final aiAsync = ref.watch(aiRecommendationProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. 상단 그라데이션 배너
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C769), Color(0xFF357FFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/icons/sparkle_icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // 공간이 부족하면 비율을 맞춰 줄임
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$userName 님의 관심 태그 기반 추천',
                        style: AppTypography.h3.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. AI 추천 카드 리스트
          aiAsync.when(
            data: (list) {
              if (list.isEmpty) return const SizedBox.shrink();
              return ListView.builder(
                shrinkWrap: true, // 💡 SingleChildScrollView 내 중첩을 위해 필수
                physics: const NeverScrollableScrollPhysics(), // 💡 부모 스크롤 사용
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return ChallengeSearchCard(challenge: list[index]);
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: CircularProgressIndicator(color: AppColors.primaryAble),
            ),
            error: (err, _) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text("추천 정보를 불러올 수 없습니다."),
            ),
          ),

          const SizedBox(height: 20),

          // 3. 하단 안내 문구
          const Center(
            child: Text(
              "원하시는 챌린지를 검색해보세요!",
              style: TextStyle(color: AppColors.gray2),
            ),
          ),
          const SizedBox(height: 60), // 하단 여백 확보
        ],
      ),
    );
  }

  // 검색창 위젯 분리 (가독성용)
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      child: TextField(
        controller: _searchController,

        // 검색 액션 추가: 엔터를 누르면 상태 업데이트
        onSubmitted: (value) {
          setState(() {
            _currentKeyword = value;
          });
        },

        decoration: InputDecoration(
          hintText: '이름으로 탐색하기',
          hintStyle: AppTypography.b2.copyWith(color: AppColors.gray3),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14.0),
            child: SvgPicture.asset('assets/images/icons/search_icon.svg'),
          ),
          // UX 개선: 검색어 삭제 버튼 추가
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                    color: AppColors.gray3,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _currentKeyword = "");
                  },
                )
              : null,

          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.5),
            borderSide: const BorderSide(color: AppColors.gray4),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.5),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  // 검색 결과 리스트 위젯 분리
  Widget _buildSearchResults(AsyncValue<List<SearchChallengeCard>> results) {
    return results.when(
      data: (list) => list.isEmpty
          ? const Center(child: Text("검색 결과가 없습니다."))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: list.length,
              itemBuilder: (context, index) =>
                  ChallengeSearchCard(challenge: list[index]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("검색 중 오류 발생: $err")),
    );
  }
}
