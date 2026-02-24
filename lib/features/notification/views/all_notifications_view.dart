// 최초 작성자: 정승빈
// '모두' 탭 화면 (날짜별 그룹화 리스트)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/notification_provider.dart';
import '../model/notification_model.dart';
import '../widgets/notification_date_header.dart';
import '../widgets/notification_list_tile.dart';
import '../../../core/theme/app_colors.dart';

class AllNotificationsView extends ConsumerStatefulWidget {
  const AllNotificationsView({super.key});

  @override
  ConsumerState<AllNotificationsView> createState() =>
      _AllNotificationsViewState();
}

class _AllNotificationsViewState extends ConsumerState<AllNotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 스크롤이 끝에 도달하면 다음 페이지 호출
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(notificationProvider.notifier).fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 날짜 문자열("YYYY-MM-DD")을 "오늘", "어제", "M월 D일"로 변환하는 유틸 함수
  String _formatDateHeader(String dateStr) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    try {
      final parts = dateStr.split('-');
      final parsedDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      if (parsedDate == today) return '오늘';
      if (parsedDate == yesterday) return '어제';

      return '${parsedDate.month}월 ${parsedDate.day}일';
    } catch (e) {
      return dateStr; // 파싱 실패 시 원본 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAble),
      );
    }

    if (state.notifications.isEmpty) {
      return const Center(child: Text('새로운 알림이 없습니다.'));
    }

    // 날짜별로 그룹화
    final groupedNotis = <String, List<NotificationModel>>{};
    for (var noti in state.notifications) {
      final formattedDate = _formatDateHeader(noti.created);
      if (!groupedNotis.containsKey(formattedDate)) {
        groupedNotis[formattedDate] = [];
      }
      groupedNotis[formattedDate]!.add(noti);
    }

    // 그룹화된 데이터를 기반으로 리스트 생성
    final listItems = <Widget>[];
    groupedNotis.forEach((dateText, notis) {
      listItems.add(NotificationDateHeader(dateText: dateText));

      for (var noti in notis) {
        NotiIconType iconType = NotiIconType.normal;

        // API에서 정의한 type 값에 따라 아이콘 분기 처리
        if (noti.type == 'CHALLENGE_SUCCESS') {
          iconType = NotiIconType.success;
        } else if (noti.type == 'CHALLENGE_FAIL') {
          iconType = NotiIconType.fail;
        } else if (noti.type == 'FRIEND_REQUEST' ||
            noti.type == 'COMMENT' ||
            noti.type == 'LIKE' ||
            noti.type == 'CHALLENGE' ||
            noti.type == 'FRIEND_ACCEPT') {
          iconType = NotiIconType.profile;
        }

        listItems.add(
          InkWell(
            onTap: () {
              ref.read(notificationProvider.notifier).markAsRead(noti);
            },
            child: NotificationListTile(
              message: noti.message,
              isRead: noti.read,
              iconType: iconType,
              profileImageUrl: noti.profileImageUrl,
            ),
          ),
        );
      }
    });

    return RefreshIndicator(
      onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
      color: AppColors.primaryAble,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: listItems.length + (state.isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // 마지막 아이템이고 추가 로딩 중이면 로딩 인디케이터 표시
          if (index == listItems.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryAble),
              ),
            );
          }
          return listItems[index];
        },
      ),
    );
  }
}
