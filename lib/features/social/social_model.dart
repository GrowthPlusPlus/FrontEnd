/// 최초 작성자: 정승빈
library;

/// 클래스의 용도: 친구 정보를 관리하는 데이터 모델
class Friend {
  final String name;
  final String title;
  final String? profileImage;

  /// 함수의 용도: Friend 클래스의 생성자
  /// 매개 변수: String name, String title, String? profileImage
  Friend({required this.name, required this.title, this.profileImage});
}

/// 클래스의 용도: 검색 결과 유저 정보 및 요청 상태를 저장하는 모델
class SearchResultUser {
  final String name;
  final String title;
  final String? profileImage;
  bool isRequested;
  String? requestTime;

  /// 함수의 용도: SearchResultUser 클래스의 생성자
  /// 매개 변수: name, title, profileImage, isRequested, requestTime
  SearchResultUser({
    required this.name,
    required this.title,
    this.profileImage,
    this.isRequested = false,
    this.requestTime,
  });
}

/// 클래스의 용도: 받은 친구 요청의 상세 정보를 관리하는 데이터 모델
class ReceivedRequest {
  final String name;
  final String title;
  final int mutualFriends;
  final String time;
  final String? profileImage;

  /// 함수의 용도: ReceivedRequest 클래스의 생성자
  /// 매개 변수: name, title, mutualFriends, time, profileImage
  ReceivedRequest({
    required this.name,
    required this.mutualFriends,
    required this.time,
    required this.title,
    this.profileImage,
  });
}
