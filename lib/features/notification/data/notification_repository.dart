// 최초 작성자: 정승빈
// 알림 조회, 읽음 처리, 수락/거절 API
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haenaem/features/notification/models/invite_challenge_card.dart';

// 1. SecureStorage 프로바이더 생성
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// 2. 알림 전용 Dio 프로바이더 (토큰 주입 로직 포함)
final notiDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://hanaem.onrender.com', // 확인된 백엔드 주소
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  // 토큰을 읽어오기 위해 storage 객체 가져오기
  final storage = ref.read(secureStorageProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // [중요] storage에서 토큰 꺼내기
        // 주의: 'accessToken' 이라는 키 이름은 auth_service.dart에서 저장할 때 쓴 이름과 일치해야 합니다.
        // 혹시 토큰 키가 'token'이나 'jwt'라면 그에 맞게 수정해 주세요.
        final String? token = await storage.read(key: 'accessToken');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        print('🌐 [Dio Request] ${options.method} ${options.uri}');
        print('🌐 [Dio Request Headers] ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
          '✅ [Dio Response] ${response.statusCode} ${response.requestOptions.path}',
        );
        print('📦 [Dio Response Data]: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('❌ [Dio Error] ${e.response?.statusCode} - ${e.message}');
        print('❌ [Dio Error URL] ${e.requestOptions.uri}');
        return handler.next(e);
      },
    ),
  );

  return dio;
});

// 3. 알림 레포지토리 프로바이더
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(notiDioProvider);
  return NotificationRepository(dio: dio);
});

// 4. 알림 레포지토리 클래스
class NotificationRepository {
  final Dio dio;

  NotificationRepository({required this.dio});

  Future<Map<String, dynamic>> getNotifications({required int page}) async {
    try {
      final response = await dio.get(
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
      final response = await dio.get('/api/challenges/invites');
      // 응답이 배열(List) 형태
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
      await dio.post('/api/challenges/$challengeId/invites/accept');
    } on DioException catch (e) {
      // 💡 1. 백엔드 에러 응답을 안전하게 가져옵니다.
      final data = e.response?.data;
      String errorMessage = '초대 수락에 실패했습니다.';

      // 💡 2. 데이터가 Map(JSON) 형태인지 확인 후 안전하게 파싱합니다. (앱 터짐 방지)
      if (data != null && data is Map<String, dynamic>) {
        final reason = data['reason'];

        // 💡 3. 백엔드 에러 메시지에 맞게 한글로 변환해 줍니다.
        if (reason == 'CHALLENGE_INVITE_NOT_FOUND') {
          errorMessage = '이미 취소되거나 존재하지 않는 초대입니다.';
        } else if (reason != null) {
          errorMessage = reason; // 예: "이미 처리된 초대입니다." 그대로 노출
        }
      }
      // UI 단으로 에러 메시지를 던집니다.
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다.');
    }
  }

  // 챌린지 초대 거절
  Future<void> rejectChallengeInvite(int challengeId) async {
    try {
      await dio.post('/api/challenges/$challengeId/invites/reject');
    } on DioException catch (e) {
      print('❌ [거절 에러]: ${e.response?.data}');
      throw Exception('초대 거절 실패');
    }
  }
}
