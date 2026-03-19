import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/features/home/models/home_response.dart';

part 'home_repository.g.dart';

class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  Future<HomeResponse> getHomeData(String date) async {
    try {
      final response = await _dio.get(
        '/api/mainHome',
        queryParameters: {'date': date},
      );

      if (response.statusCode == 200) {
        debugPrint('📥 [HomeRepository] 서버 응답 원본: ${response.data}');

        // HomeResponse.fromJson 안에서 myChallenges, notificationNumber 분리
        return HomeResponse.fromJson(response.data);
      } else {
        throw Exception(
          '홈 데이터를 불러오는데 실패했습니다. (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception('서버 연결 실패: ${e.response?.statusMessage}');
    }
  }
}

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return HomeRepository(dio);
}
