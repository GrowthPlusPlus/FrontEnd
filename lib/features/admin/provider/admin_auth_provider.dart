// 최초 작성자 : 강선욱
// 관리자 인증 상태 관리 프로바이더 (로그인 / 회원가입 / 이메일 인증)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/admin_auth_repository.dart';

// ─────────────────────────────────────────
// State 클래스
// ─────────────────────────────────────────

enum AdminAuthStatus { idle, loading, success, failure }

class AdminLoginState {
  final AdminAuthStatus status;
  final String? errorMessage;

  const AdminLoginState({
    this.status = AdminAuthStatus.idle,
    this.errorMessage,
  });

  AdminLoginState copyWith({AdminAuthStatus? status, String? errorMessage}) {
    return AdminLoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class AdminSignupState {
  final AdminAuthStatus status;

  // false = Step1(이메일/비밀번호 입력), true = Step2(인증번호 입력)
  final bool isVerificationStep;
  final String? errorMessage;
  final String? successMessage;

  const AdminSignupState({
    this.status = AdminAuthStatus.idle,
    this.isVerificationStep = false,
    this.errorMessage,
    this.successMessage,
  });

  AdminSignupState copyWith({
    AdminAuthStatus? status,
    bool? isVerificationStep,
    String? errorMessage,
    String? successMessage,
  }) {
    return AdminSignupState(
      status: status ?? this.status,
      isVerificationStep: isVerificationStep ?? this.isVerificationStep,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// ─────────────────────────────────────────
// Notifier - 로그인
// ─────────────────────────────────────────

class AdminLoginNotifier extends StateNotifier<AdminLoginState> {
  final AdminAuthRepository _repository;

  AdminLoginNotifier(this._repository) : super(const AdminLoginState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AdminAuthStatus.loading, errorMessage: null);
    try {
      final data = await _repository.login(
        email: email,
        password: password,
        fcmToken: '',
      );

      const storage = FlutterSecureStorage();
      await storage.write(key: 'accessToken', value: data['accessToken']);
      if (data['refreshToken'] != null) {
        await storage.write(key: 'refreshToken', value: data['refreshToken']);
      }

      state = state.copyWith(status: AdminAuthStatus.success);
    } catch (e) {
      final statusCode = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        status: AdminAuthStatus.failure,
        errorMessage: statusCode == '401' || statusCode == '403'
            ? '이메일 또는 비밀번호가 올바르지 않습니다.'
            : '로그인에 실패했습니다. 다시 시도해주세요.',
      );
    }
  }

  void reset() {
    state = const AdminLoginState();
  }
}

// ─────────────────────────────────────────
// Notifier - 회원가입
// ─────────────────────────────────────────

class AdminSignupNotifier extends StateNotifier<AdminSignupState> {
  final AdminAuthRepository _repository;

  AdminSignupNotifier(this._repository) : super(const AdminSignupState());

  // Step 1: 회원가입 → 인증 메일 발송
  Future<void> signup({
    required String email,
    required String password,
    required String passwordVerify,
    required String nickName,
  }) async {
    state = state.copyWith(status: AdminAuthStatus.loading, errorMessage: null);
    try {
      await _repository.signup(
        email: email,
        password: password,
        passwordVerify: passwordVerify,
        nickName: nickName,
      );
      state = state.copyWith(
        status: AdminAuthStatus.success,
        isVerificationStep: true,
        successMessage: '인증 메일이 발송되었습니다.\n이메일을 확인하고 인증번호를 입력해주세요.',
      );
    } catch (e) {
      final statusCode = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        status: AdminAuthStatus.failure,
        errorMessage: statusCode == '409'
            ? '이미 가입된 이메일입니다.'
            : statusCode == '400'
            ? '올바른 이메일 형식을 입력해주세요.'
            : '회원가입에 실패했습니다. 다시 시도해주세요.',
      );
    }
  }

  // Step 2: 인증번호 확인
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    state = state.copyWith(status: AdminAuthStatus.loading, errorMessage: null);
    try {
      await _repository.verifyEmail(email: email, code: code);
      state = state.copyWith(status: AdminAuthStatus.success);
    } catch (e) {
      final statusCode = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        status: AdminAuthStatus.failure,
        errorMessage: statusCode == '400'
            ? '인증번호가 올바르지 않습니다.'
            : statusCode == '410'
            ? '인증번호가 만료되었습니다. 재발송 후 다시 시도해주세요.'
            : '인증에 실패했습니다. 다시 시도해주세요.',
      );
    }
  }

  // Step 2: 인증번호 재발송
  Future<void> resendCode({required String email}) async {
    state = state.copyWith(
      status: AdminAuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    );
    try {
      await _repository.resendCode(email: email);
      state = state.copyWith(
        status: AdminAuthStatus.idle,
        successMessage: '인증번호가 재발송되었습니다.',
      );
    } catch (e) {
      state = state.copyWith(
        status: AdminAuthStatus.failure,
        errorMessage: '재발송에 실패했습니다. 잠시 후 다시 시도해주세요.',
      );
    }
  }

  // 인증 단계 → 입력 단계로 되돌리기
  void backToSignupStep() {
    state = state.copyWith(
      isVerificationStep: false,
      errorMessage: null,
      successMessage: null,
      status: AdminAuthStatus.idle,
    );
  }

  void reset() {
    state = const AdminSignupState();
  }
}

// ─────────────────────────────────────────
// Provider 인스턴스
// ─────────────────────────────────────────

final adminLoginProvider =
    StateNotifierProvider<AdminLoginNotifier, AdminLoginState>((ref) {
      final repository = ref.watch(adminAuthRepositoryProvider);
      return AdminLoginNotifier(repository);
    });

final adminSignupProvider =
    StateNotifierProvider<AdminSignupNotifier, AdminSignupState>((ref) {
      final repository = ref.watch(adminAuthRepositoryProvider);
      return AdminSignupNotifier(repository);
    });
