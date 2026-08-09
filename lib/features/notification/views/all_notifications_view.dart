// 최초 작성자: 정승빈
// '모두' 탭 화면 (날짜별 그룹화 리스트)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/notification_provider.dart';
import '../models/notification_model.dart';
import '../widgets/notification_date_header.dart';
import '../widgets/notification_list_tile.dart';
import '../../../core/theme/app_colors.dart';

import 'package:haenaem/features/social/screens/friend_add_screen.dart';
import 'package:haenaem/features/feed/screens/post_detail_screen.dart';
import 'package:haenaem/features/notification/screens/challenge_invite_detail_screen.dart';

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
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final state = ref.watch(notificationProvider);

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: appColors.primaryAble),
      );
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Text('새로운 알림이 없습니다.', style: TextStyle(color: appColors.gray2)),
      );
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

        // 성공/실패 상태를 저장해둘 변수
        bool isChallengeSuccess = false;
        bool isChallengeFail = false;

        // API에서 정의한 type 값에 따라 아이콘 분기 처리
        if (noti.type == 'CHALLENGE') {
          if (noti.message.contains('축하합니다') || noti.message.contains('훌륭하게')) {
            iconType = NotiIconType.success;
            isChallengeSuccess = true;
          } else if (noti.message.contains('아쉬워요') ||
              noti.message.contains('실패')) {
            iconType = NotiIconType.fail;
            isChallengeFail = true;
          } else {
            // 키워드가 없으면 일반 챌린지 초대 알림으로 간주
            iconType = NotiIconType.profile;
          }
        } else if (noti.type == 'FRIEND_REQUEST' ||
            noti.type == 'COMMENT' ||
            noti.type == 'LIKE' ||
            noti.type == 'FRIEND_ACCEPT') {
          iconType = NotiIconType.profile;
        }

        listItems.add(
          InkWell(
            onTap: () {
              // 알림 타입(type)별 페이지 이동 분기
              if (noti.type == 'FRIEND_REQUEST') {
                // 친구 요청 알림 -> 소셜(친구추가) 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const FriendAddScreen(initialTabIndex: 1),
                  ),
                );
                return;
              }

              // targetId가 있는 경우 (댓글, 좋아요, 챌린지 관련)
              if (noti.targetId != null) {
                switch (noti.type) {
                  case 'LIKE':
                  case 'COMMENT':
                    // 피드 인증글로 이동 (postId 전달)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PostDetailScreen(postId: noti.targetId!),
                      ),
                    );
                    break;

                  case 'CHALLENGE':
                    // 챌린지 초대 알림 -> 알림 전용 챌린지 상세(수락/거절) 페이지로 이동
                    // message("눅님이 친구 초대...")에서 "눅"이라는 이름만 파싱해서 전달
                    String inviterName = '친구';
                    if (noti.message.contains('님이')) {
                      inviterName = noti.message.split('님이').first.trim();
                    }

                  // TODO: 챌린지 성공/실패 알림 타입 추가 시 여기에 케이스 추가
                  /*
                  case 'CHALLENGE_SUCCESS':
                  case 'CHALLENGE_FAIL':
                    // 챌린지 성공/실패 -> 기존 챌린지 메인 탭(소개/현황/멤버)으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChallengeMainScreen(challengeId: noti.targetId!),
                      ),
                    );
                    break;
                    */
                }
              }
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
      color: appColors.primaryAble,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: listItems.length + (state.isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // 마지막 아이템이고 추가 로딩 중이면 로딩 인디케이터 표시
          if (index == listItems.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: appColors.primaryAble),
              ),
            );
          }
          return listItems[index];
        },
      ),
    );
  }
}
