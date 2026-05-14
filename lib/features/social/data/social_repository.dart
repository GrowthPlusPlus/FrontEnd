// 최초 작성자: 정승빈
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 새 모델들 Import
import '../../../shared/models/user.dart';
import '../models/user_search_card.dart';
import '../models/friend_request_card.dart';

// Dio Provider with Interceptor for adding Authorization header
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  // [리팩토링] 자체 정의한 dioProvider 대신 공통 dioProvider를 watch 합니다.
  final dio = ref.watch(dioProvider);
  return SocialRepository(dio);
});

class SocialRepository {
  final Dio _dio;
  SocialRepository(this._dio);

  // 1. 친구 목록 조회 (GET /api/users/friend/list)
  Future<List<User>> getFriendList() async {
    final response = await _dio.get('/api/users/friend/list');
    // 응답 데이터가 null일 경우를 대비해 빈 리스트 처리를 추가합니다.
    return (response.data as List?)?.map((e) => User.fromJson(e)).toList() ??
        [];
  }

  // 2. 유저 검색 (GET /api/users/search)
  Future<List<UserSearchCard>> searchUsers(String nickname) async {
    final response = await _dio.get(
      '/api/users/search',
      queryParameters: {'nickname': nickname},
    );
    debugPrint('검색 유저 응답: ${response.data.toString()}');
    return (response.data as List?)?.map((e) {
          // 서버의 relationshipStatus를 FriendState enum으로 변환
          FriendState state = FriendState.stranger;
          if (e['relationshipStatus'] == 'FRIEND') {
            state = FriendState.friend;
          } else if (e['relationshipStatus'] == 'PENDING_SENT') {
            state = FriendState.pending;
          }

          return UserSearchCard(
            user: User.fromJson({
              'id': e['userId'],
              'nickname': e['nickname'],
              'profileImageUrl': e['profileImageUrl'],
            }),
            state: state,
          );
        }).toList() ??
        [];
  }

  // 3. 친구 신청 보내기 (POST /api/users/friend/request/{toUserNickName})
  Future<void> sendFriendRequest(String nickname) async {
    // Swagger operationId: sendFriendRequest
    await _dio.post('/api/users/friend/request/$nickname');
  }

  // 4. 보낸 신청 목록 조회 (GET /api/users/friend/request/sent)
  Future<List<FriendRequestCard>> getSentRequests() async {
    // Swagger operationId: getSentRequests
    final response = await _dio.get('/api/users/friend/request/sent');
    debugPrint(response.data.toString());

    return (response.data as List?)?.map((e) {
          return FriendRequestCard(
            user: User.fromJson({
              'id': e['userId'] ?? 0, // 보낸 대상의 id (서버 응답 확인 필요)
              'nickname': e['nickname'],
              'profileImageUrl': e['profileImageUrl'],
            }),
            requestId: e['requestId'],
            requestDate: e['createdAt'] != null
                ? DateTime.parse(e['createdAt'])
                : DateTime.now(),
          );
        }).toList() ??
        [];
  }

  // 5. 보낸 신청 취소 (PATCH /api/users/friend/request/sent/cancel/{requestId})
  Future<void> cancelRequest(int requestId) async {
    // Swagger operationId: cancelFriendRequest
    await _dio.patch('/api/users/friend/request/sent/cancel/$requestId');
  }

  // 6. 받은 신청 목록 조회 (GET /api/users/friend/request/received)
  Future<List<FriendRequestCard>> getReceivedRequests() async {
    // Swagger operationId: getReceivedRequests
    final response = await _dio.get('/api/users/friend/request/received');
    debugPrint(response.data.toString());

    return (response.data as List?)?.map((e) {
          return FriendRequestCard(
            user: User.fromJson({
              'id': e['fromUserId'],
              'nickname': e['nickname'],
              'profileImageUrl': e['profileImageUrl'],
            }),
            requestId: e['requestId'],
            requestDate: e['createdAt'] != null
                ? DateTime.parse(e['createdAt'])
                : DateTime.now(),
          );
        }).toList() ??
        [];
  }

  // 7. 친구 신청 수락 (PATCH /api/users/friend/request/accept/{requestId})
  Future<void> acceptRequest(int requestId) async {
    // Swagger operationId: acceptRequest
    await _dio.patch('/api/users/friend/request/accept/$requestId');
  }

  // 8. 친구 신청 거절 (PATCH /api/users/friend/request/reject/{rejectId})
  Future<void> rejectRequest(int rejectId) async {
    // Swagger operationId: rejectRequest
    await _dio.patch('/api/users/friend/request/reject/$rejectId');
  }

  // 9. 친구 삭제 (DELETE /api/users/friend/delete/{friendNickname})
  Future<void> deleteFriend(String nickname) async {
    // Swagger operationId: deleteFriend
    await _dio.delete('/api/users/friend/delete/$nickname');
  }
}
