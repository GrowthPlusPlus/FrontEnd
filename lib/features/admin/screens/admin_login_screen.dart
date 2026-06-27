// 최초 작성자 : 강선욱
// 관리자 로그인 화면 - 아이디/비밀번호 입력 후 AdminScreen으로 이동
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import '../data/admin_auth_repository.dart';
import 'admin_main_screen.dart';
import 'admin_signup_screen.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _idFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '이메일과 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(adminAuthRepositoryProvider);

      const String fcmToken = '';

      final responseData = await repository.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

      const storage = FlutterSecureStorage();
      final accessToken = responseData['accessToken'];
      final refreshToken = responseData['refreshToken'];

      if (accessToken != null) {
        await storage.write(key: 'accessToken', value: accessToken);
      }
      if (refreshToken != null) {
        await storage.write(key: 'refreshToken', value: refreshToken);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminScreen()),
      );
    } catch (e) {
      setState(() {
        final message = e.toString().replaceAll('Exception: ', '');
        if (message.contains('401') || message.contains('403')) {
          _errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
        } else {
          _errorMessage = message;
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        // 빈 영역 탭 시 키보드 내리기
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // 타이틀
                Text(
                  '관리자 로그인',
                  style: AppTypography.h1.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  '관리자 계정으로 로그인하세요.',
                  style: AppTypography.b2.copyWith(color: AppColors.gray3),
                ),

                const SizedBox(height: 40),

                // 아이디 입력
                Text(
                  '이메일',
                  style: AppTypography.b2.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _idController,
                  focusNode: _idFocusNode,
                  hintText: '이메일을 입력하세요',
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),

                const SizedBox(height: 20),

                // 비밀번호 입력
                Text(
                  '비밀번호',
                  style: AppTypography.b2.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  hintText: '비밀번호를 입력하세요',
                  obscureText: _isPasswordObscured,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.gray4,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(
                        () => _isPasswordObscured = !_isPasswordObscured,
                      );
                    },
                  ),
                ),

                // 에러 메시지
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: AppTypography.b2.copyWith(color: Colors.red),
                  ),
                ],

                const SizedBox(height: 32),

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAble,
                      disabledBackgroundColor: AppColors.primaryAble
                          .withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '로그인',
                            style: AppTypography.b1.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // 회원가입 링크
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminSignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '회원가입',
                      style: AppTypography.b2.copyWith(
                        color: AppColors.primaryAble,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.done,
    ValueChanged<String>? onSubmitted,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
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
