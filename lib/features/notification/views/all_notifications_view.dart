// '모두' 탭 화면 (날짜별 그룹화 리스트)
import 'package:flutter/material.dart';
import '../widgets/notification_date_header.dart';
import '../widgets/notification_list_tile.dart';

class AllNotificationsView extends StatelessWidget {
  const AllNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        NotificationDateHeader(dateText: '오늘'),
        NotificationListTile(
          message: '홍길동님이 내 \'[챌린지명][0일차]\' 인증글을 좋아해요.',
          isRead: false,
        ),
        NotificationListTile(
          message: '홍길동님이 내 \'[챌린지명][0일차]\'에 댓글을 달았어요: "[댓글 내용]"',
          isRead: false,
        ),
        NotificationListTile(message: '홍길동님과 친구가 되었어요.', isRead: false),
        NotificationListTile(
          message: '홍길동님이 친구 요청을 보냈어요.',
          isRead: true, // 읽은 상태 (흰색 배경)
        ),
        NotificationListTile(message: '홍길동님이 [챌린지명]에 초대했어요.', isRead: true),

        NotificationDateHeader(dateText: '어제'),
        NotificationListTile(message: '친구인 홍길동님이 [챌린지명]에 참여했어요!', isRead: true),
        NotificationListTile(message: '초대한 홍길동님이 [챌린지명]에 참여했어요!', isRead: true),
        NotificationListTile(
          message: '아쉬워요! \'[챌린지명]\' 달성에 실패했지만, 다음엔 꼭 해낼 수 있어요.',
          isRead: true,
          iconType: NotiIconType.fail, // 실패 아이콘 적용 예시
        ),

        NotificationDateHeader(dateText: '1월 2일'),
        NotificationListTile(
          message: '축하합니다! \'[챌린지명]\' 목표를 훌륭하게 해냈어요!',
          isRead: true,
          iconType: NotiIconType.success,
        ),
        NotificationListTile(
          message: '홍길동님이 내 \'[챌린지명][0일차]\'에 댓글을 달았어요: "[댓글 내용]"',
          isRead: true,
        ),
        NotificationListTile(
          message: '홍길동님이 내 댓글을 좋아해요: "[댓글 내용]"',
          isRead: true,
        ),
      ],
    );
  }
}
