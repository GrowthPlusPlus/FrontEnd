// 최초 작성자 : 강선욱
// 관리자 회원가입 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../provider/admin_auth_provider.dart';

class AdminSignupScreen extends ConsumerStatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  ConsumerState<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends ConsumerState<AdminSignupScreen> {
  // Step 1 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordVerifyController =
      TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordVerifyFocusNode = FocusNode();
  final FocusNode _nickNameFocusNode = FocusNode();

  // Step 2 컨트롤러
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  bool _isPasswordObscured = true;
  bool _isPasswordVerifyObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordVerifyController.dispose();
    _nickNameController.dispose();
    _codeController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordVerifyFocusNode.dispose();
    _nickNameFocusNode.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  // Step 1: 가입하기 → 인증 메일 발송
  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final passwordVerify = _passwordVerifyController.text.trim();
    final nickName = _nickNameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        passwordVerify.isEmpty ||
        nickName.isEmpty)
      return;

    await ref
        .read(adminSignupProvider.notifier)
        .signup(
          email: email,
          password: password,
          passwordVerify: passwordVerify,
          nickName: nickName,
        );

    // 인증 단계 전환 시 코드 입력창 자동 포커스
    if (mounted && ref.read(adminSignupProvider).isVerificationStep) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _codeFocusNode.requestFocus(),
      );
    }
  }

  // Step 2: 인증번호 확인
  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    await ref
        .read(adminSignupProvider.notifier)
        .verifyEmail(email: _emailController.text.trim(), code: code);
  }

  // Step 2: 인증번호 재발송
  Future<void> _resendCode() async {
    await ref
        .read(adminSignupProvider.notifier)
        .resendCode(email: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // 인증 완료 시 로그인 화면으로 복귀
    ref.listen(adminSignupProvider, (previous, next) {
      final wasVerifying =
          previous?.isVerificationStep == true &&
          previous?.status != AdminAuthStatus.success;
      final nowSuccess = next.status == AdminAuthStatus.success;

      if (wasVerifying && nowSuccess) {
        ref.read(adminSignupProvider.notifier).reset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 인증이 완료되었습니다. 로그인해주세요.')),
        );
        Navigator.pop(context);
      }
    });

    final signupState = ref.watch(adminSignupProvider);
    final isLoading = signupState.status == AdminAuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () {
            if (signupState.isVerificationStep) {
              ref.read(adminSignupProvider.notifier).backToSignupStep();
              _codeController.clear();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: signupState.isVerificationStep
                ? _buildVerificationStep(signupState, isLoading)
                : _buildSignupStep(signupState, isLoading),
          ),
        ),
      ),
    );
  }

  // ─── Step 1: 이메일 / 비밀번호 / 비밀번호 확인 / 닉네임 입력 ───

  Widget _buildSignupStep(AdminSignupState state, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          '관리자 회원가입',
          style: AppTypography.h2.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 8),
        Text(
          '팀 공용 메일로 인증 후 가입할 수 있습니다.',
          style: AppTypography.b2.copyWith(color: AppColors.gray4),
        ),
        const SizedBox(height: 40),

        // 이메일
        Text('이메일', style: AppTypography.b2.copyWith(color: AppColors.black)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          hintText: '이메일을 입력하세요',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _passwordFocusNode.requestFocus(),
        ),
        const SizedBox(height: 20),

        // 비밀번호
        Text('비밀번호', style: AppTypography.b2.copyWith(color: AppColors.black)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          hintText: '비밀번호를 입력하세요',
          obscureText: _isPasswordObscured,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _passwordVerifyFocusNode.requestFocus(),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.gray4,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _isPasswordObscured = !_isPasswordObscured),
          ),
        ),
        const SizedBox(height: 20),

        // 비밀번호 확인
        Text(
          '비밀번호 확인',
          style: AppTypography.b2.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _passwordVerifyController,
          focusNode: _passwordVerifyFocusNode,
          hintText: '비밀번호를 다시 입력하세요',
          obscureText: _isPasswordVerifyObscured,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _nickNameFocusNode.requestFocus(),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVerifyObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.gray4,
              size: 20,
            ),
            onPressed: () => setState(
              () => _isPasswordVerifyObscured = !_isPasswordVerifyObscured,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 닉네임
        Text('닉네임', style: AppTypography.b2.copyWith(color: AppColors.black)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _nickNameController,
          focusNode: _nickNameFocusNode,
          hintText: '닉네임을 입력하세요',
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _signup(),
        ),

        // 에러 메시지
        if (state.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            state.errorMessage!,
            style: AppTypography.b2.copyWith(color: Colors.red),
          ),
        ],

        const SizedBox(height: 32),

        // 가입하기 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _signup,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAble,
              disabledBackgroundColor: AppColors.primaryAble.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    '가입하기',
                    style: AppTypography.b1.copyWith(color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── Step 2: 인증번호 입력 ───

  Widget _buildVerificationStep(AdminSignupState state, bool isLoading) {
    final isResendLoading = isLoading && state.successMessage == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          '이메일 인증',
          style: AppTypography.h2.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: AppTypography.b2.copyWith(color: AppColors.gray4),
            children: [
              TextSpan(
                text: _emailController.text.trim(),
                style: AppTypography.b2.copyWith(color: AppColors.black),
              ),
              const TextSpan(text: ' 으로\n인증번호가 발송되었습니다.'),
            ],
          ),
        ),
        const SizedBox(height: 40),

        Text('인증번호', style: AppTypography.b2.copyWith(color: AppColors.black)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _codeController,
          focusNode: _codeFocusNode,
          hintText: '인증번호를 입력하세요',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _verifyCode(),
        ),

        if (state.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            state.errorMessage!,
            style: AppTypography.b2.copyWith(color: Colors.red),
          ),
        ],
        if (state.successMessage != null && state.errorMessage == null) ...[
          const SizedBox(height: 12),
          Text(
            state.successMessage!,
            style: AppTypography.b2.copyWith(color: AppColors.primaryAble),
          ),
        ],

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAble,
              disabledBackgroundColor: AppColors.primaryAble.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    '인증하기',
                    style: AppTypography.b1.copyWith(color: Colors.white),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        Center(
          child: TextButton(
            onPressed: isResendLoading ? null : _resendCode,
            child: isResendLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAble,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    '인증번호 다시 받기',
                    style: AppTypography.b2.copyWith(
                      color: AppColors.primaryAble,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    ValueChanged<String>? onSubmitted,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: AppTypography.b1.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.b1.copyWith(color: AppColors.gray4),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryAble,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
