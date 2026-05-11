// 최초 작성자: 정승빈
// 유저 검색 상태 관리
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/social_repository.dart';
import '../models/user_search_card.dart';
import '../../../core/utils/korean_string_utils.dart';

part 'user_search_provider.g.dart';

@riverpod
class UserSearch extends _$UserSearch {
  @override
  FutureOr<List<UserSearchCard>> build() {
    // 초기 상태는 검색 결과가 없는 빈 리스트
    return [];
  }

  // 사용자 검색 로직 (필터링 및 정렬 포함)
  Future<void> searchUsers(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    // 로딩 상태 시작
    state = const AsyncValue.loading();

    try {
      // 1. 서버로부터 검색 결과 리스트를 받아옴
      // 서버 API가 초성 검색을 지원하지 않더라도, 결과 목록을 받아온 뒤
      // 클라이언트에서 2차 필터링을 수행할 수 있도록 raw 데이터를 받습니다.
      final rawResults = await ref
          .read(socialRepositoryProvider)
          .searchUsers(trimmedQuery);
      // TODO: [성능 최적화 필요] 현재 서버 API가 초성 검색을 지원하지 않아,
      // 임시로 전체 유저 목록을 받아와 클라이언트에서 필터링하고 있습니다.
      // 유저 수가 늘어나면 앱 속도가 느려질 수 있으므로,
      // 추후 백엔드에 초성 검색 기능(DB 쿼리 수정 등)을 요청하여
      // 서버 사이드 필터링으로 교체해야 합니다.

      // 클라이언트 사이드 초성 및 닉네임 필터링
      final filtered = rawResults.where((card) {
        final name = card.user.nickname.toLowerCase();
        final searchLower = trimmedQuery.toLowerCase();

        // 닉네임 전체 또는 초성 문자열에 검색어가 포함되는지 체크
        return name.contains(searchLower) ||
            KoreanStringUtils.getChoseongString(name).contains(searchLower);
      }).toList();

      // 가나다순 정렬
      // 순서: 한글 > 영문 대문자 > 영문 소문자 > 숫자 > 특수문자
      filtered.sort(
        (a, b) => KoreanStringUtils.compareKoreanFirst(
          a.user.nickname,
          b.user.nickname,
        ),
      );

      // 결과 상태 반영
      state = AsyncValue.data(filtered);
    } catch (e, stack) {
      // 🐛 디버깅 로그 추가: DioException인지 확인하여 상세 에러 출력
      if (e is DioException) {
        debugPrint('---------- [검색 오류 발생] ----------');
        debugPrint('상태 코드: ${e.response?.statusCode}');
        debugPrint('에러 데이터: ${e.response?.data}');
        debugPrint('에러 메시지: ${e.message}');
        debugPrint('------------------------------------');
      } else {
        debugPrint('시스템 오류: $e');
      }

      // 에러 상태 반영
      state = AsyncValue.error(e, stack);
    }
  }

  // 친구 신청 및 결과 리스트 내 상태 즉시 갱신
  Future<void> sendFriendRequest(UserSearchCard card) async {
    // 이미 친구 신청이 진행 중인 경우 중복 요청 방지
    if (card.state == FriendState.pending) return;

    final previousState = state.value ?? []; // 현재 검색 결과 리스트

    try {
      await ref
          .read(socialRepositoryProvider)
          .sendFriendRequest(card.user.nickname);

      // 성공 시 해당 카드의 상태만 FriendState.pending으로 변경하여 UI 즉각 갱신
      state = AsyncValue.data([
        for (final c in previousState)
          if (c.user.nickname == card.user.nickname)
            c.copyWith(state: FriendState.pending)
          else
            c,
      ]);
    } catch (e) {
      // 🐛 디버깅 로그 추가: 친구 신청 실패 시 상세 원인 파악
      if (e is DioException) {
        debugPrint('---------- [친구 신청 실패] ----------');
        debugPrint('대상 닉네임: ${card.user.nickname}');
        debugPrint('상태 코드: ${e.response?.statusCode}');
        debugPrint('서버 응답: ${e.response?.data}');
        debugPrint('------------------------------------');
      } else {
        debugPrint('친구 신청 중 알 수 없는 에러: $e');
      }

      // 에러는 UI에서 토스트를 띄우도록 rethrow
      rethrow;
    }
  }
}
