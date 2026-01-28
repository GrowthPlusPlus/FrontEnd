import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/feed/screens/ChallengeDetailScreen.dart';

class ChallengeSearchScreen extends StatelessWidget {
  const ChallengeSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Divider(
            height: 1,
            color: AppColors.gray4, //
          ),
          // 검색창 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: '이름으로 탐색하기',
                hintStyle: AppTypography.b2.copyWith(color: AppColors.gray3),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SvgPicture.asset(
                    'assets/images/icons/search_icon.svg',
                  ),
                ),
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

          // 추천 텍스트
          // 추천 텍스트 영역 (이미지 시안 반영)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              width: double.infinity, // 가로 꽉 차게
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // 그라데이션 배경 적용
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00C769), // 왼쪽 초록
                    Color(0xFF357FFF), // 오른쪽 파랑
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                // 하단 그림자
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
                  // 반짝이는 아이콘
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
                    // 유저 이름 넣기
                    '김채영 님의 관심 태그 기반 추천',
                    style: AppTypography.h3.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // 챌린지 카드 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 8,
              itemBuilder: (context, index) => const ChallengeCard(),
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 챌린지 정보로 채우기
                  Text(
                    '챌린지 이름',
                    style: AppTypography.b3.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 10), // 이름과 정보 사이 간격 확대
                  // 인원수 및 완료일 정보
                  Row(
                    children: [
                      // 인원수
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/icons/person_icon.svg',
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gray2,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '00명',
                            style: AppTypography.b2.copyWith(
                              color: AppColors.gray2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15), // 인원수와 완료일 사이 간격
                      // 완료일
                      Text(
                        '완료까지 D-000',
                        style: AppTypography.b2.copyWith(
                          color: AppColors.gray2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 챌린지 태그 정보
                  Row(
                    children: [
                      _buildTag('label'),
                      const SizedBox(width: 10),
                      _buildTag('label'),
                    ],
                  ),
                ],
              ),
            ),

            // 오른쪽 화살표 아이콘
            Align(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () {
                  // 상세 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChallengeDetailPage(),
                    ),
                  );
                },
                icon: SvgPicture.asset(
                  'assets/images/icons/thick_right_arrow_icon.svg',
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray2,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.selected,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: AppTypography.b2.copyWith(color: AppColors.primaryAble),
      ),
    );
  }
}
