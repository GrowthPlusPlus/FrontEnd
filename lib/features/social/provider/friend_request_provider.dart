// 최초 작성자: 정승빈
// 받은/보낸 요청 상태 관리
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/social_repository.dart';
import '../models/friend_request_card.dart';
import 'friend_list_provider.dart';

part 'friend_request_provider.g.dart';

// 받은 요청 상태 관리
@riverpod
class ReceivedRequests extends _$ReceivedRequests {
  @override
  Future<List<FriendRequestCard>> build() async {
    return ref.watch(socialRepositoryProvider).getReceivedRequests();
  }

  // 친구 요청 수락 로직
  Future<void> acceptRequest(int requestId) async {
    try {
      await ref.read(socialRepositoryProvider).acceptRequest(requestId);
      ref.invalidateSelf(); // 받은 요청 목록 새로고침
      ref.invalidate(friendListProvider); // 친구가 추가되었으니 친구 목록도 새로고침
    } catch (e) {
      if (e is DioException) {
      } else {}
      rethrow;
    }
  }

  // 친구 요청 거절 로직
  Future<void> rejectRequest(int requestId) async {
    try {
      await ref.read(socialRepositoryProvider).rejectRequest(requestId);
      ref.invalidateSelf();
    } catch (e) {
      if (e is DioException) {
      } else {}
      rethrow;
    }
  }
}

// 보낸 요청 상태 관리
@riverpod
class SentRequests extends _$SentRequests {
  @override
  Future<List<FriendRequestCard>> build() async {
    return ref.watch(socialRepositoryProvider).getSentRequests();
  }

  // 친구 요청 취소 로직
  Future<void> cancelRequest(int requestId) async {
    try {
      await ref.read(socialRepositoryProvider).cancelRequest(requestId);
      ref.invalidateSelf();
    } catch (e) {
      if (e is DioException) {
      } else {}
      rethrow;
    }
  }
}
