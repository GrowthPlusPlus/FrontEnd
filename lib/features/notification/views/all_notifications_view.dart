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

class AllNotificationsView extends ConsumerStatefulWidget {
  final VoidCallback? onMoveToInviteTab; // 알림 화면에서 친구 초대 탭으로 이동할 때 호출되는 콜백

  const AllNotificationsView({super.key, this.onMoveToInviteTab});

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
              // 🐞 디버깅 시작 (클릭 시 터미널(Run 탭)을 확인하세요!)
              print('====================================');
              print('🐞 [디버그] 알림 카드 클릭됨!');
              print('🐞 [디버그] 알림 타입(type): ${noti.type}');
              print('🐞 [디버그] 목적지 ID(targetId): ${noti.targetId}');
              print('🐞 [디버그] 알림 메시지: ${noti.message}');
              // 알림 타입(type)별 페이지 이동 분기
              if (noti.type == 'FRIEND_REQUEST') {
                // 친구 요청 알림 -> 소셜(친구추가) 페이지로 이동
                print('🐞 [디버그] 친구 요청 탭으로 이동');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const FriendAddScreen(initialTabIndex: 1),
                  ),
                );
                return;
              }

              // 💡 2. [수정됨] CHALLENGE 분기를 targetId null 체크 밖으로 분리!
              if (noti.type == 'CHALLENGE') {
                print(
                  '🐞 [디버그] CHALLENGE 타입 분기 진입 (성공:$isChallengeSuccess, 실패:$isChallengeFail)',
                );

                if (isChallengeSuccess || isChallengeFail) {
                  print('🐞 [디버그] 성공/실패 알림 (이동 로직 주석 처리됨)');
                  // 성공/실패 챌린지 이동은 targetId가 필요하므로 내부에서 체크
                  if (noti.targetId != null) {
                    // Navigator.push( ... );
                  } else {
                    print('🐞 [디버그] ❌ 에러: 성공/실패 알림인데 targetId가 null입니다!');
                  }
                } else {
                  print('🐞 [디버그] 초대 알림 -> 탭 이동 시도');
                  if (widget.onMoveToInviteTab != null) {
                    print('🐞 [디버그] onMoveToInviteTab 콜백 호출 완료!');
                    widget.onMoveToInviteTab!();
                  } else {
                    print(
                      '🐞 [디버그] ❌ 에러: onMoveToInviteTab 콜백이 부모로부터 전달되지 않았습니다!',
                    );
                  }
                }
                return; // CHALLENGE 처리가 끝났으므로 종료
              }

              // targetId가 있는 경우 (댓글, 좋아요, 챌린지 관련)
              if (noti.targetId != null) {
                switch (noti.type) {
                  case 'LIKE':
                  case 'COMMENT':
                    print('🐞 [디버그] 피드 상세(PostDetailScreen)로 이동');
                    // 피드 인증글로 이동 (postId 전달)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PostDetailScreen(postId: noti.targetId!),
                      ),
                    );
                    break;
                }
              } else {
                print('🐞 [디버그] ❌ 에러: targetId가 null이므로 이동할 수 없습니다.');
              }
              print('====================================');
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
