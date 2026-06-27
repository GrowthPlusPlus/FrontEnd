// 최초 작성자 : 강선욱
// 관리자 인증 관련 API 레포지토리 (로그인 / 회원가입 / 이메일 인증)
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';

part 'admin_auth_repository.g.dart';

class AdminAuthRepository {
  final Dio _dio;

  AdminAuthRepository(this._dio);

  // 1. 로그인
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String fcmToken,
  }) async {
    try {
      final response = await _dio.post(
        '/api/admin/auth/login',
        data: {'email': email, 'password': password, 'fcmToken': fcmToken},
      );
      debugPrint('📥 관리자 로그인 응답: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('로그인 실패 (상태 코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 관리자 로그인 서버 에러: ${e.response?.data}');
      throw Exception(e.response?.statusCode);
    } catch (e) {
      debugPrint('❌ 관리자 로그인 에러: $e');
      throw Exception('데이터 처리 중 오류가 발생했습니다.');
    }
  }

  // 2. 회원가입 (인증 메일 발송)
  Future<void> signup({
    required String email,
    required String password,
    required String passwordVerify,
    required String nickName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/admin/auth/signup',
        data: {
          'email': email,
          'password': password,
          'passwordVerify': passwordVerify,
          'nickName': nickName,
        },
      );
      debugPrint('📥 관리자 회원가입 응답: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('회원가입 실패 (상태 코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 관리자 회원가입 서버 에러: ${e.response?.data}');
      throw Exception(e.response?.statusCode);
    } catch (e) {
      debugPrint('❌ 관리자 회원가입 에러: $e');
      throw Exception('데이터 처리 중 오류가 발생했습니다.');
    }
  }

  // 3. 이메일 인증번호 확인
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/api/admin/auth/verifyEmail',
        data: {'email': email, 'code': code},
      );
      debugPrint('📥 이메일 인증 응답: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('이메일 인증 실패 (상태 코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 이메일 인증 서버 에러: ${e.response?.data}');
      throw Exception(e.response?.statusCode);
    } catch (e) {
      debugPrint('❌ 이메일 인증 에러: $e');
      throw Exception('데이터 처리 중 오류가 발생했습니다.');
    }
  }

  // 4. 인증번호 재발송
  Future<void> resendCode({required String email}) async {
    try {
      final response = await _dio.post(
        '/api/admin/auth/resendCode',
        data: {'email': email},
      );
      debugPrint('📥 인증번호 재발송 응답: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('재발송 실패 (상태 코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 인증번호 재발송 서버 에러: ${e.response?.data}');
      throw Exception(e.response?.statusCode);
    } catch (e) {
      debugPrint('❌ 인증번호 재발송 에러: $e');
      throw Exception('데이터 처리 중 오류가 발생했습니다.');
    }
  }
}

// Provider 설정
@riverpod
AdminAuthRepository adminAuthRepository(AdminAuthRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return AdminAuthRepository(dio);
}
