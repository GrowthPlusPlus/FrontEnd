/// 최초 작성자: 정승빈
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// 새 모델들 Import
import '../../../shared/models/user.dart';
import '../models/user_search_card.dart';
import '../models/friend_request_card.dart';
import '../../auth/services/auth_service.dart';

// Dio Provider with Interceptor for adding Authorization header
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://hanaem.onrender.com', // 서버 주소
      //baseUrl: 'https://ungenially-undebatable-sindy.ngrok-free.dev',
      connectTimeout: const Duration(seconds: 5),
      //headers: {'ngrok-skip-browser-warning': 'true'},
    ),
  );

  // 요청 인터셉터 추가
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. 저장소에서 액세스 토큰 읽기
        final String? accessToken = await AuthService.getAccessToken();
        debugPrint("🔍 저장소에서 꺼낸 토큰: $accessToken"); // 이 값이 null인지 확인!

        // 2. 토큰이 있다면 헤더에 Bearer 토큰 주입
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
          debugPrint("🔑 API 요청에 토큰 주입 완료");
        }

        return handler.next(options); // 다음 단계로 진행
      },
      onError: (DioException e, handler) async {
        // 만약 401 에러가 나면 여기서 refreshTokens()를 호출하는 로직을 추가할 수도 있습니다.
        return handler.next(e);
      },
    ),
  );

  return dio;
});

// Repository Provider
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository(ref.watch(dioProvider));
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
              'profileUrl': e['profileImageUrl'],
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

    return (response.data as List?)?.map((e) {
          return FriendRequestCard(
            user: User.fromJson({
              'id': e['userId'] ?? 0, // 보낸 대상의 id (서버 응답 확인 필요)
              'nickname': e['nickname'],
              'profileUrl': e['profileImageUrl'],
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

    return (response.data as List?)?.map((e) {
          return FriendRequestCard(
            user: User.fromJson({
              'id': e['fromUserId'],
              'nickname': e['nickname'],
              'profileUrl': e['profileImageUrl'],
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
