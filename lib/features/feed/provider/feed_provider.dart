import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:haenaem/features/feed/data/feed_repository.dart';
import 'package:haenaem/features/feed/model/feed_model.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';

// 1. Repository Provider 추가 (Dio 객체는 별도의 공통 Provider에서 가져오는 것이 좋습니다)
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      // Render.com 서버 주소를 베이스로 넣어두면 편리합니다
      baseUrl: 'https://hanaem.onrender.com',
    ),
  );

  // 💡 모든 API 요청에 자동으로 토큰을 가로채서(Intercept) 넣어줍니다.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // AuthService에 만들어두신 메서드로 토큰을 읽어옵니다.
        final token = await AuthService.getAccessToken();

        if (token != null) {
          // 헤더에 Bearer 토큰 삽입
          options.headers['Authorization'] = 'Bearer $token';
          print("🔑 [Dio Interceptor] 토큰 삽입 완료");
        } else {
          print("⚠️ [Dio Interceptor] 토큰을 찾을 수 없습니다.");
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // 만약 401 에러(토큰 만료)가 나면 여기서 토큰 재발급 로직을 연결할 수도 있습니다.
        if (e.response?.statusCode == 401) {
          print("🚨 [Dio Interceptor] 401 에러 발생: 토큰이 만료되었을 수 있습니다.");
        }
        return handler.next(e);
      },
    ),
  );

  return FeedRepository(dio);
});

// 2. Notifier 수정 (Repository 주입)
class FeedNotifier extends StateNotifier<FeedState> {
  final String apiPath;
  final FeedRepository _repository; // 추가

  FeedNotifier({
    required this.apiPath,
    required FeedRepository repository, // 추가
  }) : _repository = repository,
       super(FeedState());

  Future<void> fetchFeeds() async {
    // [수정] 1. 중복 호출 방지 가드: 이미 로딩 중이거나 데이터가 있으면 중단
    // (새로고침이 필요한 경우를 대비해 posts.isNotEmpty 조건은 상황에 따라 조절하세요)
    if (state.isLoading) return;

    // [수정] 2. 호출 시작 즉시 로딩 상태로 변경
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 0,
      isLastPage: false,
      // posts: [], // 필요하다면 초기화
    );

    try {
      print("📡 [FeedNotifier] Repository 데이터 요청 중...");
      final result = await _repository.getFeeds(apiPath, 0);

      print("✅ [FeedNotifier] 데이터 수신 성공: ${result['posts'].length}개의 포스트");

      state = state.copyWith(
        posts: result['posts'],
        isLastPage: result['isLast'],
        isLoading: false, // 로딩 완료
      );
    } catch (e, stacktrace) {
      print("❌ [FeedNotifier] 에러 발생: $e");
      state = state.copyWith(
        isLoading: false, // 에러 발생 시에도 로딩은 꺼줘야 함
        errorMessage: e.toString(),
      );
    }
  }

  // 다음 페이지 추가 로드 (무한 스크롤)
  Future<void> loadMore() async {
    // 이미 로딩 중이거나 마지막 페이지면 중단
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getFeeds(apiPath, nextPage);

      state = state.copyWith(
        posts: [...state.posts, ...result['posts']], // 기존 데이터 + 새 데이터 합치기
        currentPage: nextPage,
        isLastPage: result['isLast'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// 3. Provider 정의 부분 수정
final friendFeedProvider =
    StateNotifierProvider.autoDispose<FeedNotifier, FeedState>((
      ref, //
    ) {
      final repository = ref.watch(feedRepositoryProvider); // 리포지토리 구독
      return FeedNotifier(apiPath: '/api/feed/friends', repository: repository);
    });

final exploreFeedProvider =
    StateNotifierProvider.autoDispose<FeedNotifier, FeedState>((
      ref, //
    ) {
      final repository = ref.watch(feedRepositoryProvider); // 리포지토리 구독
      return FeedNotifier(apiPath: '/api/feed/public', repository: repository);
    });
