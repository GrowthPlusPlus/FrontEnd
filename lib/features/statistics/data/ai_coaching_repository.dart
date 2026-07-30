// 최초 작성자: 김채영
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import '../models/ai_coaching_data.dart';

class AiCoachingRepository extends AsyncNotifier<List<AiCoachingCardModel>> {
  @override
  Future<List<AiCoachingCardModel>> build() async {
    return _fetch();
  }

  Future<List<AiCoachingCardModel>> _fetch() async {
    final dio = ref.read(dioProvider);

    final response = await dio.post('/api/v1/rag/coach/query');

    // Swagger media type이 */* + schema string 이라, 서버 응답이
    // 1) dio가 이미 Map으로 파싱해준 경우
    // 2) JSON을 담은 순수 문자열(String)로 오는 경우
    // 둘 다 방어적으로 처리합니다.
    final rawData = response.data;
    final Map<String, dynamic> json = rawData is String
        ? jsonDecode(rawData) as Map<String, dynamic>
        : rawData as Map<String, dynamic>;

    return parseCoachQueryResponse(json);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final aiCoachingRepositoryProvider =
    AsyncNotifierProvider<AiCoachingRepository, List<AiCoachingCardModel>>(
      AiCoachingRepository.new,
    );
