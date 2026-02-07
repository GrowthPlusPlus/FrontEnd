/// 최초 작성자: 정승빈
library;

import 'package:flutter/material.dart';

/// 클래스의 용도: 친구 정보를 관리하는 데이터 모델
class Friend {
  final int id;
  final String nickname;
  final String? profileImageUrl;
  final String title; // UI 연동용 (API에 없을 시 기본값 처리)

  /// 함수의 용도: Friend 클래스의 생성자
  /// 매개 변수: String nickname, String title, String? profileImage
  Friend({
    required this.id,
    required this.nickname,
    this.profileImageUrl,
    this.title = '해냄 메이트',
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}

/// 클래스의 용도: 검색 결과 유저 정보 및 요청 상태를 저장하는 모델
class SearchResultUser {
  final int? userId; // 검색 시 사용
  final int? requestId; // 요청 취소 시 사용
  final String nickname;
  final String? profileImageUrl;
  final String? createdAt;
  bool isRequested;

  /// 함수의 용도: SearchResultUser 클래스의 생성자
  /// 매개 변수: nickname, title, profileImage, isRequested, requestTime
  SearchResultUser({
    this.userId,
    this.requestId,
    required this.nickname,
    this.profileImageUrl,
    this.createdAt,
    this.isRequested = false,
  });

  factory SearchResultUser.fromSearchJson(Map<String, dynamic> json) {
    // 🔥 [디버깅용 로그] 서버가 주는 실제 상태값 확인하기
    // 나중에 해결되면 이 줄은 지우셔도 됩니다.
    debugPrint(
      "닉네임: ${json['nickname']} / 서버상태값: ${json['relationshipStatus']}",
    );

    return SearchResultUser(
      userId: json['userId'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
      // 🔥 서버 응답 상태가 'PENDING_SENT'인 경우 신청 완료 상태로 판단
      isRequested: json['relationshipStatus'] == 'PENDING_SENT',
      requestId: json['requestId'], // 취소를 위해 ID도 저장
    );
  }

  factory SearchResultUser.fromSentJson(Map<String, dynamic> json) {
    return SearchResultUser(
      requestId: json['requestId'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
      createdAt: json['createdAt'],
      isRequested: true,
    );
  }
}

/// 클래스의 용도: 받은 친구 요청의 상세 정보를 관리하는 데이터 모델
class ReceivedRequest {
  final int requestId;
  final int fromUserId;
  final String nickname;
  final String? profileImageUrl;
  final String createdAt;
  final String title;

  /// 함수의 용도: ReceivedRequest 클래스의 생성자
  /// 매개 변수: nickname, title, mutualFriends, time, profileImage
  ReceivedRequest({
    required this.requestId,
    required this.fromUserId,
    required this.nickname,
    this.profileImageUrl,
    required this.createdAt,
    this.title = '새로운 친구 요청',
  });

  factory ReceivedRequest.fromJson(Map<String, dynamic> json) {
    return ReceivedRequest(
      requestId: json['requestId'],
      fromUserId: json['fromUserId'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
      createdAt: json['createdAt'],
    );
  }
}
