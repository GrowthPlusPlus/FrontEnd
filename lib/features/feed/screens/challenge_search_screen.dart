// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/challenge_search_provider.dart';
import '../widgets/challenge_search_card.dart';
import 'package:haenaem/shared/models/user.dart';
import 'package:haenaem/features/user/provider/user_provider.dart';
import 'package:haenaem/features/feed/provider/feed_provider.dart';
import 'package:haenaem/shared/models/search_challenge_card.dart';
import 'package:haenaem/shared/widgets/slider_indicator.dart';
import '../widgets/recommended_challenge_card.dart';
import '../widgets/gradation_banner.dart';
import '../provider/recommended_challenge_provider.dart';
import 'package:haenaem/shared/widgets/custom_search_bar.dart';

class ChallengeSearchScreen extends ConsumerStatefulWidget {
  const ChallengeSearchScreen({super.key});

  static const String routeName = '/challengeSearch';

  @override
  ConsumerState<ChallengeSearchScreen> createState() =>
      _ChallengeSearchScreenState();
}

class _ChallengeSearchScreenState extends ConsumerState<ChallengeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentKeyword = "";

  // AI 추천 챌린지 요청 여부를 추적하는 상태 변수
  bool _isRecommendationRequested = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // 사용자 프로필 정보 가져오기 (헤더 이름용)
    final currentUser = ref.watch(currentUserProvider);

    // 검색어가 있을 때만 api 호출
    final searchResults = ref.watch(
      searchChallengesProvider(keyword: _currentKeyword),
    );

    return Scaffold(
      backgroundColor: appColors.gray5,
      appBar: AppBar(
        backgroundColor: appColors.whiteToBlack,
        elevation: 0,
        surfaceTintColor: appColors.whiteToBlack,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              appColors.blackToWhite,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '챌린지 탐색',
          style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 검색창 영역
          _buildSearchBar(),
          // 챌린지 카드 리스트 영역
          Expanded(
            child: _currentKeyword.isEmpty
                ? _buildRecommendationSection(
                    currentUser,
                    appColors,
                  ) // 💡 검색어 없을 때 추천 섹션 노출
                : _buildSearchResults(searchResults), // 검색어 있을 때 결과 노출
          ),
        ],
      ),
    );
  }

  // ── AI 추천 섹션 구현 ────────────────────────────
  Widget _buildRecommendationSection(
    User? currentUser,
    AppColorsExtension appColors,
  ) {
    final userName = currentUser?.nickname ?? "해냄";

    // 추천받기 버튼을 아직 누르지 않은 초기 상태
    if (!_isRecommendationRequested) {
      return SingleChildScrollView(
        child: Column(
          children: [
            GradationBanner(
              userName: userName,
              onRequest: () {
                // 버튼 클릭 시 Provider를 초기화하여 새 데이터를 불러오고 상태 변경
                ref.invalidate(recommendedChallengesProvider);
                setState(() {
                  _isRecommendationRequested = true;
                });
              },
            ),
          ],
        ),
      );
    }

    // 추천받기 버튼을 누른 후, Provider를 통해 데이터를 가져오는 상태
    final recommendedAsync = ref.watch(recommendedChallengesProvider);

    return recommendedAsync.when(
      data: (data) => SingleChildScrollView(
        child: Column(
          children: [
            GradationBanner(userName: userName, summary: data.summary),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "추천 챌린지",
                  style: AppTypography.h3.copyWith(
                    color: appColors.blackToWhite,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (data.challenges.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text("아직 추천 챌린지가 없어요."),
              )
            else
              RecommendedChallengeCard(items: data.challenges),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
      // 로딩 중 상태
      loading: () => SingleChildScrollView(
        child: Column(
          children: [GradationBanner(userName: userName, isLoading: true)],
        ),
      ),
      error: (err, _) => Center(child: Text("추천 챌린지를 불러오지 못했어요: $err")),
    );
  }

  // 커스텀 검색 바 위젯
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: CustomSearchBar(
        controller: _searchController,
        hintText: '이름으로 탐색하기',
        onSubmitted: (value) {
          setState(() {
            _currentKeyword = value;
          });
        },
        onChanged: (value) {
          // 검색어가 모두 지워졌을 때 바로 추천 챌린지 화면으로 돌아가도록 처리
          if (value.isEmpty) {
            setState(() {
              _currentKeyword = "";
            });
          }
        },
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
