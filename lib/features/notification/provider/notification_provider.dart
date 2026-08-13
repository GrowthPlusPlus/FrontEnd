// 최초 작성자: 정승빈
// 알림 목록 상태 및 탭 상태 관리
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_repository.dart';
import '../models/notification_model.dart';
import '../models/notification_state.dart';
import 'package:haenaem/features/notification/models/invite_challenge_card.dart';

// 홈 화면 새로고침이 필요한지 여부를 저장하는 스위치 (초기값: false)
final needsHomeRefreshProvider = StateProvider<bool>((ref) => false);

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationNotifier(repository: repository);
    });

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository repository;

  NotificationNotifier({required this.repository})
    : super(NotificationState(notifications: [])) {
    fetchInitial(); // 초기 데이터 로드
  }

  // 첫 페이지 로드
  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await repository.getNotifications(page: 0);

      final content = data['content'] as List<dynamic>? ?? [];
      final List<NotificationModel> initialItems = content
          .map((e) => NotificationModel.fromJson(e))
          .toList();

      state = state.copyWith(
        notifications: initialItems,
        currentPage: 0,
        hasMore: !(data['last'] as bool? ?? true),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print(e);
    }
  }

  // 다음 페이지 로드 (무한 스크롤용)
  Future<void> fetchMore() async {
    if (!state.hasMore || state.isFetchingMore || state.isLoading) return;

    state = state.copyWith(isFetchingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final data = await repository.getNotifications(page: nextPage);

      final content = data['content'] as List<dynamic>? ?? [];
      final List<NotificationModel> moreItems = content
          .map((e) => NotificationModel.fromJson(e))
          .toList();

      state = state.copyWith(
        notifications: [...state.notifications, ...moreItems],
        currentPage: nextPage,
        hasMore: !(data['last'] as bool? ?? true),
        isFetchingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isFetchingMore: false);
      print(e);
    }
  }

  // 새로고침
  Future<void> refresh() async {
    await fetchInitial();
  }
}

class ChallengeInviteState {
  final List<InviteChallengecard> invites;
  final bool isLoading;

  ChallengeInviteState({required this.invites, this.isLoading = false});

  ChallengeInviteState copyWith({
    List<InviteChallengecard>? invites,
    bool? isLoading,
  }) {
    return ChallengeInviteState(
      invites: invites ?? this.invites,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final challengeInviteProvider =
    StateNotifierProvider<ChallengeInviteNotifier, ChallengeInviteState>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return ChallengeInviteNotifier(repository: repository);
    });

class ChallengeInviteNotifier extends StateNotifier<ChallengeInviteState> {
  final NotificationRepository repository;

  ChallengeInviteNotifier({required this.repository})
    : super(ChallengeInviteState(invites: [])) {
    fetchInvites();
  }

  Future<void> fetchInvites() async {
    state = state.copyWith(isLoading: true);
    try {
      final invites = await repository.getChallengeInvites();
      state = state.copyWith(invites: invites, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print(e);
    }
  }

  // 수락 처리
  Future<void> acceptInvite(int challengeId) async {
    try {
      await repository.acceptChallengeInvite(challengeId);
      // 성공하면 UI 목록에서 해당 카드 즉시 제거
      state = state.copyWith(
        invites: state.invites
            .where((i) => i.challengeInfo.base.id != challengeId)
            .toList(),
      );
    } catch (e) {
      print('수락 에러: $e');
      rethrow;
    }
  }

  // 거절 처리
  Future<void> rejectInvite(int challengeId) async {
    try {
      await repository.rejectChallengeInvite(challengeId);
      // 성공하면 UI 목록에서 해당 카드 즉시 제거
      state = state.copyWith(
        invites: state.invites
            .where((i) => i.challengeInfo.base.id != challengeId)
            .toList(),
      );
    } catch (e) {
      print('거절 에러: $e');
      rethrow;
    }
  }
}
