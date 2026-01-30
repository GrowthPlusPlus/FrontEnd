/// 최초 작성자: 정승빈
library;

import 'social_model.dart';

/// 클래스의 용도: 친구 목록 및 친구 요청 데이터를 관리하는 리포지토리
class SocialRepository {
  static final SocialRepository instance = SocialRepository.internal();
  factory SocialRepository() => instance;
  SocialRepository.internal();

  // 실제 친구 목록 (SocialScreen에서 사용)
  final List<Friend> friends = [
    Friend(
      name: '지피티',
      title: '성실한 새싹',
      profileImage: "assets/images/profiles/user1.png",
    ),
    Friend(name: '이졸업', title: '코딩 마스터'),
    Friend(name: 'Apple', title: '아이폰 유저'),
    Friend(name: '박프로', title: '해냄의 기둥'),
    Friend(name: 'Gemini', title: 'AI 조력자'),
    Friend(name: '1등해냄', title: '숫자 우선?'),
  ];

  // 보낸 요청 리스트
  final List<SearchResultUser> sentRequests = [];

  // 받은 요청 리스트 (FriendAddScreen에서 이동)
  final List<ReceivedRequest> receivedRequests = [
    ReceivedRequest(
      name: '여하늘',
      mutualFriends: 2,
      time: '2025년 12월 24일 15:48',
      title: '코딩 천재',
    ),
    ReceivedRequest(
      name: '정승빈',
      mutualFriends: 5,
      profileImage: 'assets/images/profiles/user1.png',
      time: '2025년 12월 24일 15:48',
      title: '코딩 천재',
    ),
    ReceivedRequest(
      name: '강선욱',
      mutualFriends: 2,
      profileImage: 'assets/images/profiles/user1.png',
      time: '2025년 12월 24일 15:48',
      title: '플러터 개발자',
    ),
    ReceivedRequest(
      name: '정성우',
      mutualFriends: 2,
      time: '2025년 12월 23일 15:48',
      title: '플러터 개발자',
    ),
  ];

  /// 함수의 용도: 새로운 친구 신청을 보낸 요청 목록에 추가
  /// 매개 변수: SearchResultUser user (신청 대상 유저 정보)
  /// 반환 값: 없음
  void addRequest(SearchResultUser user) {
    if (!sentRequests.any((item) => item.name == user.name)) {
      sentRequests.add(user);
    }
  }

  /// 함수의 용도: 보낸 신청 목록에서 특정 유저의 요청을 삭제
  /// 매개 변수: String name (대상 유저 이름)
  /// 반환 값: 없음
  void removeRequest(String name) {
    sentRequests.removeWhere((item) => item.name == name);
  }

  /// 함수의 용도: 받은 친구 요청을 수락하여 친구 목록에 추가하고 요청 삭제
  /// 매개 변수: ReceivedRequest request (수락할 요청 정보)
  /// 반환 값: 없음
  void acceptFriendRequest(ReceivedRequest request) {
    // 친구 목록에 추가
    friends.add(
      Friend(
        name: request.name,
        title: request.title,
        profileImage: request.profileImage,
      ),
    );
    // 받은 요청에서 삭제
    receivedRequests.removeWhere((item) => item.name == request.name);
  }

  /// 함수의 용도: 받은 친구 요청을 거절하여 목록에서 삭제
  /// 매개 변수: ReceivedRequest request (거절할 요청 정보)
  /// 반환 값: 없음
  void rejectFriendRequest(ReceivedRequest request) {
    receivedRequests.removeWhere((item) => item.name == request.name);
  }
}
