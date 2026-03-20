import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/shared/models/post.dart';
import 'package:haenaem/features/feed/screens/post_detail_screen.dart';

// 최초 작성자 : 강선욱
// 챌린지 인증 달력 그리드 위젯
// - 특정 연월의 날짜를 7열 그리드로 표시
// - 인증한 날짜는 초록색으로 표시되며, 사진이 있으면 썸네일로 표시
// - 인증한 날짜 셀을 탭하면 해당 포스트 상세 화면으로 이동

class CalendarGrid extends StatelessWidget {
  /// 현재 표시 중인 연월
  final DateTime focusedDay;

  /// 해당 월의 포스트 목록 (post_provider에서 전달)
  final List<Post> posts;

  const CalendarGrid({
    super.key,
    required this.focusedDay,
    required this.posts,
  });

  @override
  Widget build(BuildContext context) {
    // 해당 월 1일의 요일 (0: 일요일 기준으로 맞추기 위해 % 7 처리)
    // ex) 1일이 화요일이면 skipDays = 2 → 앞에 빈 셀 2개 추가
    final int skipDays =
        DateTime(focusedDay.year, focusedDay.month, 1).weekday % 7;

    // 해당 월의 마지막 날짜
    // ex) 3월이면 31, 4월이면 30
    final int lastDayOfMonth = DateTime(
      focusedDay.year,
      focusedDay.month + 1,
      0,
    ).day;

    final now = DateTime.now();

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // 빈 셀(skipDays) + 실제 날짜 셀(lastDayOfMonth)
      itemCount: skipDays + lastDayOfMonth,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 일~토 7열
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        // 1일 이전 빈 셀 처리
        if (index < skipDays) return const SizedBox();

        final int day = index - skipDays + 1;

        // 오늘 날짜 여부 확인 (테두리 표시용)
        final bool isToday =
            now.year == focusedDay.year &&
            now.month == focusedDay.month &&
            now.day == day;

        // 해당 날짜에 인증 포스트가 있는지 확인
        final Post? post = posts.firstWhereOrNull(
          (p) =>
              p.date.year == focusedDay.year &&
              p.date.month == focusedDay.month &&
              p.date.day == day,
        );
        final bool isCertified = post != null;

        return _CalendarCell(
          day: day,
          isToday: isToday,
          isCertified: isCertified,
          imageUrl: post?.pictureUrl,
          // 인증한 날짜만 탭 가능, 포스트 상세 화면으로 이동
          onTap: isCertified
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(postId: post.id),
                  ),
                )
              : null,
        );
      },
    );
  }
}

/// 달력 개별 셀 위젯
///
/// - 인증 여부에 따라 배경색 및 썸네일 표시
/// - 오늘 날짜이고 미인증이면 회색 테두리 표시
class _CalendarCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isCertified;

  /// 인증 사진 URL (없으면 단색 배경으로 표시)
  final String? imageUrl;
  final VoidCallback? onTap;

  const _CalendarCell({
    required this.day,
    required this.isToday,
    required this.isCertified,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // 인증: 초록색 / 미인증: 회색
          color: isCertified ? AppColors.primaryAble : AppColors.gray5,
          borderRadius: BorderRadius.circular(5),
          // 오늘이면서 미인증인 경우 테두리 표시
          border: (isToday && !isCertified)
              ? Border.all(color: AppColors.gray2, width: 1)
              : null,
          // 인증 사진이 있으면 썸네일로 표시
          image: (isCertified && imageUrl != null)
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Text(
          '$day',
          style: TextStyle(
            // 인증: 흰색 / 미인증: 회색
            color: isCertified ? Colors.white : AppColors.gray2,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
