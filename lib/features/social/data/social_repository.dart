/// 최초 작성자: 정승빈
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_model.dart';
import '../../auth/services/auth_service.dart';
import 'package:flutter/material.dart';

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
  Future<List<Friend>> getFriendList() async {
    final response = await _dio.get('/api/users/friend/list');
    // 응답 데이터가 null일 경우를 대비해 빈 리스트 처리를 추가합니다.
    return (response.data as List?)?.map((e) => Friend.fromJson(e)).toList() ??
        [];
  }

  // 2. 유저 검색 (GET /api/users/search)
  Future<List<SearchResultUser>> searchUsers(String nickname) async {
    final response = await _dio.get(
      '/api/users/search',
      queryParameters: {'nickname': nickname},
    );
    return (response.data as List?)
            ?.map((e) => SearchResultUser.fromSearchJson(e))
            .toList() ??
        [];
  }

  // 3. 친구 신청 보내기 (POST /api/users/friend/request/{toUserNickName})
  Future<void> sendFriendRequest(String nickname) async {
    // Swagger operationId: sendFriendRequest
    await _dio.post('/api/users/friend/request/$nickname');
  }

  // 4. 보낸 신청 목록 조회 (GET /api/users/friend/request/sent)
  Future<List<SearchResultUser>> getSentRequests() async {
    // Swagger operationId: getSentRequests
    final response = await _dio.get('/api/users/friend/request/sent');
    return (response.data as List?)
            ?.map((e) => SearchResultUser.fromSentJson(e))
            .toList() ??
        [];
  }

  // 5. 보낸 신청 취소 (PATCH /api/users/friend/request/sent/cancel/{requestId})
  Future<void> cancelRequest(int requestId) async {
    // Swagger operationId: cancelFriendRequest
    await _dio.patch('/api/users/friend/request/sent/cancel/$requestId');
  }

  // 6. 받은 신청 목록 조회 (GET /api/users/friend/request/received)
  Future<List<ReceivedRequest>> getReceivedRequests() async {
    // Swagger operationId: getReceivedRequests
    final response = await _dio.get('/api/users/friend/request/received');
    return (response.data as List?)
            ?.map((e) => ReceivedRequest.fromJson(e))
            .toList() ??
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

// 1. 친구 목록을 서버에서 가져오는 FutureProvider
// SocialScreen에서 ref.watch(friendListProvider)로 사용합니다.
final friendListProvider = FutureProvider<List<Friend>>((ref) async {
  final repo = ref.watch(socialRepositoryProvider);
  return await repo.getFriendList(); // GET /api/users/friend/list 호출
});

// 2. (옵션) 보낸/받은 요청 목록도 Provider로 관리하면 화면 갱신이 더 편해집니다.
final receivedRequestsProvider = FutureProvider<List<ReceivedRequest>>((
  ref,
) async {
  return await ref.watch(socialRepositoryProvider).getReceivedRequests();
});
