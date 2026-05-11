// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/feed/screens/challenge_detail_screen.dart'; // 챌린지 소개 화면 뷰 재활용
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
// import 'package:haenaem/features/challenge/models/challenge_model.dart';
// import 'package:haenaem/features/user/models/user_model.dart';
import '../provider/challenge_search_provider.dart';
import 'package:haenaem/shared/models/search_challenge_card.dart';
import '../widgets/challenge_search_card.dart';
import 'package:haenaem/shared/models/user.dart';
import 'package:haenaem/features/user/provider/user_provider.dart';

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
          Padding(
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
                  child: SvgPicture.asset(
                    'assets/images/icons/search_icon.svg',
                  ),
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
          ),
          // 챌린지 카드 리스트
          Expanded(
            child: _currentKeyword.isEmpty
                ? _buildRecommendationSection(currentUser)
                : searchResults.when(
                    data: (list) => list.isEmpty
                        ? const Center(child: Text("검색 결과가 없습니다."))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              // 분리한 ChallengeSearchCard 위젯 사용
                              return ChallengeSearchCard(
                                challenge: list[index],
                              );
                            },
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        Center(child: Text("검색 중 오류 발생: $err")),
                  ),
          ),
        ],
      ),
    );
  }

  // 추천 섹션 (기존 코드의 그라데이션 박스 부분 분리)
  Widget _buildRecommendationSection(User? currentUser) {
    final userName = currentUser?.nickname ?? "해냄";

    return SingleChildScrollView(
      child: Column(
        children: [
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
                  Text(
                    '$userName 님의 관심 태그 기반 추천',
                    style: AppTypography.h3.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100), // 적절한 여백
          const Center(
            child: Text(
              "원하시는 챌린지를 검색해보세요!",
              style: TextStyle(color: AppColors.gray2),
            ),
          ),
        ],
      ),
    );
  }
}
