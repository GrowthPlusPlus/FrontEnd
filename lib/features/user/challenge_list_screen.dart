/// 최초 작성자: 정승빈
/// 작성일: 2026-02-03
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// 클래스의 용도: 챌린지의 진행 상태를 정의하는 열거형
enum ChallengeStatus { ongoing, success, fail }

/// 클래스의 용도: 챌린지 개별 항목의 데이터와 정렬 로직을 관리하는 모델
class ChallengeModel {
  final String title;
  final ChallengeStatus status;
  final double progress;
  final String dateInfo;
  final String countInfo;
  final DateTime sortDate;
  final int streak;

  /// 함수의 용도: ChallengeModel 생성자
  /// 매개 변수: title, status, progress, dateInfo, sortDate, streak, countInfo
  /// 반환 값: 없음
  ChallengeModel({
    required this.title,
    required this.status,
    required this.progress,
    required this.dateInfo,
    required this.sortDate,
    required this.streak,
    this.countInfo = '0/0명',
  });

  /// 함수의 용도: 제공된 리스트를 상태에 따라 필터링하고 정렬 규칙을 적용하여 반환
  /// 매개 변수: List<ChallengeModel> list, ChallengeStatus status
  /// 반환 값: List<ChallengeModel> (정렬된 결과 리스트)
  static List<ChallengeModel> getSortedList(
    List<ChallengeModel> list,
    ChallengeStatus status,
  ) {
    // 1. 해당 상태의 아이템만 필터링
    final filtered = list.where((item) => item.status == status).toList();

    // 2. 정렬 규칙 적용
    filtered.sort((a, b) {
      if (status == ChallengeStatus.ongoing) {
        // 진행중: 달성률 높은 순 (내림차순)
        return b.progress.compareTo(a.progress);
      } else {
        // 완료 및 실패: 최근 날짜순 (내림차순)
        return b.sortDate.compareTo(a.sortDate);
      }
    });

    return filtered;
  }
}

/// 상수명: 대문자와 언더스코어 사용 (정렬 테스트용 데이터)
final List<ChallengeModel> ALL_CHALLENGES_DATA = [
  ChallengeModel(
    title: '물 마시기',
    status: ChallengeStatus.ongoing,
    progress: 0.35,
    dateInfo: '매일, 완료까지 D-10',
    countInfo: '3/5명',
    sortDate: DateTime(2026, 2, 1),
    streak: 5,
  ),
  ChallengeModel(
    title: '러닝하기',
    status: ChallengeStatus.ongoing,
    progress: 0.85,
    dateInfo: '매일, 완료까지 D-03',
    countInfo: '1/2명',
    sortDate: DateTime(2026, 2, 3),
    streak: 12,
  ),
  ChallengeModel(
    title: '코딩 공부',
    status: ChallengeStatus.ongoing,
    progress: 0.10,
    dateInfo: '평일, 완료까지 D-20',
    countInfo: '5/10명',
    sortDate: DateTime(2026, 1, 20),
    streak: 2,
  ),
  ChallengeModel(
    title: '영양제 먹기',
    status: ChallengeStatus.ongoing,
    progress: 0.60,
    dateInfo: '매일, 완료까지 D-05',
    countInfo: '2/2명',
    sortDate: DateTime(2026, 1, 30),
    streak: 20,
  ),
  ChallengeModel(
    title: '명상하기',
    status: ChallengeStatus.success,
    progress: 1.0,
    dateInfo: '완료일 2025/12/25',
    sortDate: DateTime(2025, 12, 25),
    streak: 30,
  ),
  ChallengeModel(
    title: '아침 기상',
    status: ChallengeStatus.success,
    progress: 1.0,
    dateInfo: '완료일 2026/01/20',
    sortDate: DateTime(2026, 1, 20),
    streak: 15,
  ),
  ChallengeModel(
    title: '책 읽기',
    status: ChallengeStatus.success,
    progress: 1.0,
    dateInfo: '완료일 2026/02/02',
    sortDate: DateTime(2026, 2, 2),
    streak: 7,
  ),
  ChallengeModel(
    title: '플러터 강의 완강',
    status: ChallengeStatus.success,
    progress: 1.0,
    dateInfo: '완료일 2026/01/05',
    sortDate: DateTime(2026, 1, 5),
    streak: 21,
  ),
  ChallengeModel(
    title: '금주 챌린지',
    status: ChallengeStatus.fail,
    progress: 0.2,
    dateInfo: '실패일 2026/01/10',
    sortDate: DateTime(2026, 1, 10),
    streak: 3,
  ),
  ChallengeModel(
    title: '유튜브 안보기',
    status: ChallengeStatus.fail,
    progress: 0.5,
    dateInfo: '실패일 2026/01/28',
    sortDate: DateTime(2026, 1, 28),
    streak: 10,
  ),
  ChallengeModel(
    title: '다이어트 챌린지',
    status: ChallengeStatus.fail,
    progress: 0.0,
    dateInfo: '실패일 2026/02/01',
    sortDate: DateTime(2026, 2, 1),
    streak: 0,
  ),
  ChallengeModel(
    title: '매일 일기 쓰기',
    status: ChallengeStatus.fail,
    progress: 0.1,
    dateInfo: '실패일 2026/01/15',
    sortDate: DateTime(2026, 1, 15),
    streak: 4,
  ),
];

/// 클래스의 용도: 챌린지 목록을 진행중, 완료, 실패 탭으로 구분하여 보여주는 화면
class ChallengeListScreen extends StatelessWidget {
  final List<ChallengeModel> challenges;

  const ChallengeListScreen({super.key, required this.challenges});

  /// 함수의 용도: 화면 UI 전체 빌드
  /// 매개 변수: BuildContext context
  /// 반환 값: Widget
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '나의 챌린지',
            style: AppTypography.h2.copyWith(color: AppColors.black),
          ),
        ),
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.gray4, width: 1),
                ),
              ),
              child: TabBar(
                indicatorColor: AppColors.primaryAble,
                indicatorWeight: 2,
                labelColor: AppColors.primaryAble,
                labelStyle: AppTypography.b1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelColor: AppColors.gray2,
                unselectedLabelStyle: AppTypography.b1.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: '진행중'),
                  Tab(text: '완료'),
                  Tab(text: '실패'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.gray5,
                child: TabBarView(
                  children: [
                    buildFilteredList(ChallengeStatus.ongoing),
                    buildFilteredList(ChallengeStatus.success),
                    buildFilteredList(ChallengeStatus.fail),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 함수의 용도: 상태값에 따라 필터링된 리스트뷰 위젯 생성
  /// 매개 변수: ChallengeStatus status (진행, 성공, 실패 상태)
  /// 반환 값: Widget
  Widget buildFilteredList(ChallengeStatus status) {
    final sortedList = ChallengeModel.getSortedList(challenges, status);

    if (sortedList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 48,
              color: AppColors.gray4,
            ),
            const SizedBox(height: 16),
            Text(
              '해당하는 챌린지가 없습니다.',
              style: AppTypography.b1.copyWith(color: AppColors.gray3),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: sortedList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          buildFullChallengeCard(sortedList[index]),
    );
  }

  /// 함수의 용도: 개별 챌린지 항목의 상세 카드 위젯 빌드
  /// 매개 변수: ChallengeModel item (챌린지 데이터 모델)
  /// 반환 값: Widget
  Widget buildFullChallengeCard(ChallengeModel item) {
    Color themeColor;
    String statusText;
    switch (item.status) {
      case ChallengeStatus.ongoing:
        themeColor = AppColors.blue;
        statusText = '진행중';
        break;
      case ChallengeStatus.success:
        themeColor = AppColors.primaryAble;
        statusText = '완료';
        break;
      case ChallengeStatus.fail:
        themeColor = AppColors.notification;
        statusText = '실패';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item.title,
                    style: AppTypography.b1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: AppTypography.c1.copyWith(color: themeColor),
                    ),
                  ),
                ],
              ),
              Text(
                '${(item.progress * 100).toInt()}%',
                style: AppTypography.h3.copyWith(
                  color: themeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.dateInfo,
            style: AppTypography.b2.copyWith(color: AppColors.gray2),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/icons/small_fire_icon.svg',
                width: 16,
                height: 16,
              ),
              Text(
                item.status == ChallengeStatus.ongoing
                    ? ' ${item.streak}일째'
                    : ' 최대 ${item.streak}일',
                style: AppTypography.b2,
              ),
              const SizedBox(width: 12),
              if (item.status == ChallengeStatus.ongoing) ...[
                SvgPicture.asset(
                  'assets/images/icons/mini_success_icon.svg',
                  width: 16,
                  height: 16,
                ),
                Text(' ${item.countInfo}', style: AppTypography.b2),
              ],
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: item.progress,
            backgroundColor: AppColors.gray5,
            color: themeColor,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
