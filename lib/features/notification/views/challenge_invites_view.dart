// 최초 작성자: 정승빈
// '챌린지 초대' 탭 화면
import 'package:flutter/material.dart';
import '../widgets/challenge_invite_card.dart';

class ChallengeInvitesView extends StatelessWidget {
  const ChallengeInvitesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 10, bottom: 40),
      children: const [
        // 디자인처럼 임시 데이터로 카드를 4개 정도 배치합니다.
        ChallengeInviteCard(
          inviterName: '홍길동',
          challengeName: '챌린지 이름',
          participantCount: 0,
          dDay: 'D-000',
          labels: ['label', 'label'],
        ),
        ChallengeInviteCard(
          inviterName: '홍길동',
          challengeName: '아침 기상 챌린지',
          participantCount: 12,
          dDay: 'D-005',
          labels: ['기상', '습관'],
        ),
        ChallengeInviteCard(
          inviterName: '홍길동',
          challengeName: '매일 달리기 3km',
          participantCount: 5,
          dDay: 'D-012',
          labels: ['운동', '건강'],
        ),
        ChallengeInviteCard(
          inviterName: '홍길동',
          challengeName: '책 읽기 프로젝트',
          participantCount: 8,
          dDay: 'D-030',
          labels: ['독서', '자기계발'],
        ),
      ],
    );
  }
}
