import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import '../models/challenge_stats.dart';

part 'stats_repository.g.dart';

class StatsRepository {
  final Dio _dio;

  StatsRepository(this._dio);

  // 실제 API 연동 로직 (Dio 사용 예시)
  Future<ChallengeStats> getChallengeStats(int challengeId) async {
    final response = await _dio.get('/api/challenges/$challengeId/calendar');
    return ChallengeStats.fromJson(response.data);
  }
}

@riverpod
StatsRepository statsRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return StatsRepository(dio);
}
