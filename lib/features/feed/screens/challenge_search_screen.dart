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

  @override
  Widget build(BuildContext context) {
    // 사용자 프로필 정보 가져오기 (헤더 이름용)
    final currentUser = ref.watch(currentUserProvider);

    // 검색어가 있을 때만 api 호출
    final searchResults = ref.watch(
      searchChallengesProvider(keyword: _currentKeyword),
    );

    return Scaffold(
      backgroundColor: Color(0xFFE0E2DC).withValues(alpha: 50),
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
  // TODO: api 수정 시 코드 수정
  Widget _buildRecommendationSection(User? currentUser) {
    final userName = currentUser?.nickname ?? "해냄";

    // 🎨 [UI 전용] 피그마 컴포넌트에 딱 맞는 더미 데이터
    final List<Map<String, dynamic>> dummyList = [
      {
        'title': '만보 걷기',
        'description': '챌린지 설명',
        'detail': '헬스장 운동 인증샷 업로드',
        'participantCount': '142명',
        'remainingDays': '완료까지 D-14',
        'tags': ['갓생', '20대'],
        'recommendReason':
            '사용자가 운동에 관심이 많고 러닝 챌린지에 참여한 경험이 있기 때문에, 걷기 또한 운동의 일환으로 쉽게 접근할 수 있습니다. 만보 걷기는 일상에서 쉽게 실천할 수 있으며, 걸음 수를 기록하고 공유함으로써 성취감을 느낄 수 있습니다.',
      },
      {
        'title': '아침 기상 인증',
        'description': '매일 아침 7시 기상',
        'detail': '침대 밖을 나온 사진 업로드',
        'participantCount': '45명',
        'remainingDays': '완료까지 D-7',
        'tags': ['운동', '자기계발'],
        'recommendReason':
            '규칙적인 기상 습관을 원하셨던 요구사항과 미라클 모닝 태그 기록을 바탕으로 추천합니다. 아침 시간을 확보하여 하루를 주도적으로 시작해보세요!',
      },
      {
        'title': '독서 30분',
        'description': '책 읽는 습관 기르기',
        'detail': '페이지 번호가 보이는 인증샷',
        'participantCount': '88명',
        'remainingDays': '완료까지 D-3',
        'tags': ['취미', '독서'],
        'recommendReason':
            '최근 자기계발 카테고리에 높은 관심을 보이셨기 때문에 독서 챌린지를 제안합니다. 작은 목표부터 채워나가며 루틴을 완성할 수 있습니다.',
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          GradationBanner(userName: userName),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "추천 챌린지",
                style: AppTypography.h3.copyWith(color: AppColors.black),
              ),
            ),
          ),
          const SizedBox(height: 10),
          RecommendedChallengeCard(items: dummyList),
        ],
      ),
    );
  }

  // 검색창 위젯 분리 (가독성용)
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
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
          filled: true,
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
