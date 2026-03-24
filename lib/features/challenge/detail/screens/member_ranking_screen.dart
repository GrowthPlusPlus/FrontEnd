// 최초 작성자: 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/detail/provider/ranking_provider.dart';
import 'package:haenaem/features/challenge/detail/models/ranking_model.dart';

class MemberRankingScreen extends ConsumerWidget {
  final int challengeId;
  const MemberRankingScreen({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 프로바이더 구독 (API 호출 및 상태 관리)
    final rankingAsync = ref.watch(
      challengeRankingNotifierProvider(challengeId),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/images/icons/arrow_left.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '멤버 순위',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: rankingAsync.when(
        // 로딩 중일 때
        loading: () => const Center(child: CircularProgressIndicator()),
        // 에러 발생 시
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다.\n$err')),
        // 데이터 로드 성공 시
        data: (rankingData) {
          // 💡 데이터가 없는 경우 처리
          if (rankingData.topRankings.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref
                  .read(challengeRankingNotifierProvider(challengeId).notifier)
                  .refresh(),
              child: Stack(
                children: [
                  ListView(), // RefreshIndicator를 동작하게 하기 위한 빈 리스트뷰
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.leaderboard_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '아직 랭킹 데이터가 없어요!\n첫 번째로 인증을 완료해 보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // 💡 데이터가 있는 경우
          return RefreshIndicator(
            onRefresh: () => ref
                .read(challengeRankingNotifierProvider(challengeId).notifier)
                .refresh(),
            child: CustomScrollView(
              slivers: [
                const SizedBox(height: 20).toSliver(),

                SliverPadding(
                  padding: const EdgeInsets.all(0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final user = rankingData.topRankings[index];
                      return _buildRankingItem(
                        rank: user.rank,
                        userName: user.nickname,
                        profileImageUrl: user.profileImageUrl,
                        totalCount: user.totalCount,
                        streakCount: user.streakCount,
                        isMe: user.userId == rankingData.myRanking.userId,
                      );
                    }, childCount: rankingData.topRankings.length),
                  ),
                ),
                const SizedBox(height: 40).toSliver(),
              ],
            ),
          );
        },
      ),
    );
  }

  // 랭킹 아이템 리스트 위젯
  Widget _buildRankingItem({
    required int rank,
    required String userName,
    required String? profileImageUrl,
    required int totalCount,
    required int streakCount,
    required bool isMe,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        left: isMe ? 15 : 20,
        right: isMe ? 15 : 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isMe ? AppColors.selected : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMe ? AppColors.primaryAble : AppColors.gray4,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40), // 일반 아이템은 은은한 검정 그림자
            blurRadius: 8, // 그림자의 퍼짐 정도
            offset: const Offset(0, 4), // 그림자의 위치 (아래로 4만큼)
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: _buildRankBadge(rank)),
          const SizedBox(width: 13),
          _buildProfileImage(profileImageUrl, isMe: isMe),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              userName,
              style: TextStyle(
                fontSize: 15,
                color: isMe ? AppColors.primaryAble : Colors.black,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatInfo(
                svgAsset: 'assets/images/icons/mini_success_icon.svg',
                value: totalCount,
                color: AppColors.primaryAble,
                isActive: totalCount > 0,
              ),
              const SizedBox(height: 6),
              _buildStatInfo(
                svgAsset: 'assets/images/icons/small_fire_icon.svg',
                value: streakCount,
                color: AppColors.fire,
                isActive: streakCount > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 헬퍼 메서드들
  Widget _buildProfileImage(String? url, {required bool isMe}) {
    // isMe 여부에 따라 사이즈 결정
    final double size = isMe ? 50 : 40;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        // 내 순위일 때만 테두리 적용
        border: Border.all(
          color: isMe ? AppColors.disable : Colors.transparent,
          width: isMe ? 1 : 0,
        ),
      ),
      // 테두리와 이미지 사이의 간격 (isMe일 때만 살짝 띄움)
      padding: isMe ? const EdgeInsets.all(2) : EdgeInsets.zero,
      child: ClipRRect(
        // 원형을 유지하기 위해 borderInherited가 아닌 size의 절반 이상을 적용
        borderRadius: BorderRadius.circular(size),
        child: _buildImageContent(url, size),
      ),
    );
  }

  // 이미지 콘텐츠를 결정하는 헬퍼 메서드
  Widget _buildImageContent(String? url, double size) {
    // 1. URL이 있는 경우 네트워크 이미지 표시
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        // 네트워크 에러 발생 시에도 기본 SVG를 보여줌
        errorBuilder: (context, error, stackTrace) => _buildDefaultSvg(size),
      );
    }

    // 2. URL이 없는 경우 기본 SVG 표시
    return _buildDefaultSvg(size);
  }

  // 기본 프로필 SVG 렌더링
  Widget _buildDefaultSvg(double size) {
    return SvgPicture.asset(
      'assets/images/icons/default_profile_icon.svg', // 실제 에셋 경로로 수정하세요
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank <= 3)
      return SvgPicture.asset(_getMedalSvg(rank), width: 30, height: 30);

    return Text(
      rank.toString(),
      style: AppTypography.b3.copyWith(color: AppColors.gray2),
      textAlign: TextAlign.center,
    );
  }

  String _getMedalSvg(int rank) {
    switch (rank) {
      case 1:
        return 'assets/images/icons/first_rank_medal.svg';
      case 2:
        return 'assets/images/icons/second_rank_medal.svg';
      case 3:
        return 'assets/images/icons/third_rank_medal.svg';
      default:
        return '';
    }
  }

  Widget _buildStatInfo({
    required String svgAsset,
    required int value,
    required Color color,
    required bool isActive,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgAsset,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            isActive ? color : AppColors.gray4,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$value일',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? color : AppColors.gray4,
          ),
        ),
      ],
    );
  }
}

// 간단한 Sliver 변환 확장함수
extension on Widget {
  Widget toSliver() => SliverToBoxAdapter(child: this);
}
