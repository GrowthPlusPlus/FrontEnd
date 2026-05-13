// 최초 작성자: 정승빈
// 알림 조회, 읽음 처리, 수락/거절 API
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/features/notification/models/invite_challenge_card.dart';

part 'notification_repository.g.dart';

@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  final dio = ref.watch(dioProvider); // ← 공통 Dio 주입
  return NotificationRepository(dio);
}

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  // 알림 목록 조회
  Future<Map<String, dynamic>> getNotifications({required int page}) async {
    try {
      final response = await _dio.get(
        '/api/notification',
        queryParameters: {'page': page},
      );
      return response.data;
    } on DioException catch (e) {
      print('❌ [Noti Repo Error]: ${e.response?.data}');
      throw Exception('알림 목록을 불러오는데 실패했습니다: ${e.response?.statusCode}');
    } catch (e) {
      throw Exception('알 수 없는 오류 발생: $e');
    }
  }

  // 챌린지 초대 목록 조회
  Future<List<InviteChallengecard>> getChallengeInvites() async {
    try {
      final response = await _dio.get('/api/challenges/invites');
      final List<dynamic> data = response.data;
      return data
          .map(
            (e) => InviteChallengecard.fromResponse(
              InviteResponse.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } on DioException catch (e) {
      print('❌ [초대 조회 에러]: ${e.response?.data}');
      throw Exception('초대 목록을 불러오는데 실패했습니다.');
    } catch (e) {
      throw Exception('초대 조회 중 알 수 없는 오류 발생: $e');
    }
  }

  // 챌린지 초대 수락
  Future<void> acceptChallengeInvite(int challengeId) async {
    try {
      await _dio.post('/api/challenges/$challengeId/invites/accept');
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMessage = '초대 수락에 실패했습니다.';

      if (data != null && data is Map<String, dynamic>) {
        final reason = data['reason'];
        if (reason == 'CHALLENGE_INVITE_NOT_FOUND') {
          errorMessage = '이미 취소되거나 존재하지 않는 초대입니다.';
        } else if (reason != null) {
          errorMessage = reason;
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다.');
    }
  }

  // 챌린지 초대 거절
  Future<void> rejectChallengeInvite(int challengeId) async {
    try {
      await _dio.post('/api/challenges/$challengeId/invites/reject');
    } on DioException catch (e) {
      print('❌ [거절 에러]: ${e.response?.data}');
      throw Exception('초대 거절 실패');
    }
  }
}
