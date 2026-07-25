import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/calendar_share_response.dart';
import 'package:haenaem/core/network/dio_provider.dart';

part 'calendar_share_repository.g.dart'; // 💡 build_runner용 part 추가

// 💡 Repository 전용 Provider를 Repository 파일 내부로 이동!
@riverpod
CalendarShareRepository calendarShareRepository(
  CalendarShareRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider);
  return CalendarShareRepository(dio);
}

class CalendarShareRepository {
  final Dio _dio;
  CalendarShareRepository(this._dio);

  Future<CalendarShareResponse> requestCalendarShare({
    required int challengeId,
    required int year,
    required int month,
  }) async {
    final response = await _dio.post(
      '/api/share/challenges/$challengeId/calendar',
      queryParameters: {'year': year, 'month': month},
    );

    print('📦 [Share API Raw Response Data]: ${response.data}');
    return CalendarShareResponse.fromJson(response.data);
  }
}
