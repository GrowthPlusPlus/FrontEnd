import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import '../data/calendar_share_repository.dart';
import '../models/calendar_share_response.dart';

part 'calendar_share_provider.g.dart';

@riverpod
class CalendarShareNotifier extends _$CalendarShareNotifier {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  /// 캘린더 공유 이미지 생성 API 호출 및 폴링(Polling) 처리
  Future<String?> generateCalendarShareImage({
    required int challengeId,
    required int year,
    required int month,
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(calendarShareRepositoryProvider);

      // 1. 최초 이미지 생성 요청
      CalendarShareResponse response = await repository.requestCalendarShare(
        challengeId: challengeId,
        year: year,
        month: month,
      );

      print(
        '[Share API Log] 최초 status: ${response.status}, imageUrl: ${response.imageUrl}',
      );

      int retryCount = 0;
      const maxRetries = 20;

      // 2. PROCESSING 상태이고 아직 imageUrl이 없는 경우에만 폴링 실행
      while (response.status == ShareStatus.processing &&
          (response.imageUrl == null || response.imageUrl!.isEmpty) &&
          retryCount < maxRetries) {
        print(
          '[Share API Log] 이미지 생성 중 (PROCESSING)... 2초 후 재요청 ($retryCount)',
        );
        await Future.delayed(const Duration(seconds: 2));
        response = await repository.requestCalendarShare(
          challengeId: challengeId,
          year: year,
          month: month,
        );
        retryCount++;
      }

      // 3. FAILED 상태 처리
      if (response.status == ShareStatus.failed) {
        throw Exception('서버에서 이미지 생성에 실패했습니다.');
      }

      // 4. imageUrl이 존재하는 경우 (COMPLETED 상태이거나 imageUrl이 정상 수령된 경우)
      if (response.imageUrl != null && response.imageUrl!.isNotEmpty) {
        print('[Share API Success] 최종 URL 수령: ${response.imageUrl}');
        return response.imageUrl;
      }

      // 5. 그 외 (타임아웃 등)
      throw Exception('이미지 생성 시간이 오래 걸리고 있습니다. 잠시 후 다시 공유 버튼을 눌러주세요.');
    });

    state = result;

    return result.when(
      data: (imageUrl) => imageUrl,
      error: (err, stack) {
        print('[ShareProvider Error] $err');
        return null;
      },
      loading: () => null,
    );
  }
}
