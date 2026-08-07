// 최초 작성자 : 김채영
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto/crypto.dart'; // PKCE 해싱용
import 'package:webview_flutter/webview_flutter.dart'; // 웹뷰용
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:dio/dio.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';
import 'package:haenaem/features/auth/signup/screens/signup_main_screen.dart';
import 'package:haenaem/features/admin/screens/admin_login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform; // 기기 OS 확인용

// 소셜 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _logoClickCount = 0;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    // 공통으로 사용할 네비게이션 함수
    // void navigateToSignup() {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const SignupMainScreen()),
    //   );
    // }

    void navigateToAdminLogin() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
    }

    return Scaffold(
      body: SafeArea(
        // 스크롤 가능
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 160), // 상단 여백
                // 메인 타이틀 & 로고 영역
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _logoClickCount++;
                      if (_logoClickCount == 7) {
                        _logoClickCount = 0; // 횟수 초기화
                        navigateToAdminLogin();
                      }
                    });
                  },
                  child: SvgPicture.asset(
                    'assets/images/icons/sign_up_logo.svg',
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  "오늘의 '해냄'을 위해\n지금 시작해보세요",
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(
                    color: appColors.blackToWhite,
                  ),
                ),

                const SizedBox(height: 120), // 중간 여백
                // 로그인 버튼들
                Text(
                  '간편하게 시작하기',
                  textAlign: TextAlign.center,
                  style: AppTypography.b2.copyWith(color: appColors.gray3),
                ),
                const SizedBox(height: 10),

                // 카카오 로그인 버튼
                _buildSocialButton(
                  label: '카카오로 시작하기',
                  backgroundColor: const Color(0xFFFEE500),
                  textColor: Colors.black,
                  iconPath: 'assets/images/icons/kakao_logo.svg',
                  onTap: () async {
                    // 1. PKCE 데이터 및 URL 준비 (AuthService 이용)
                    final pkce = AuthService.generatePkcePair();
                    final authUrl = AuthService.getKakaoAuthUrl(
                      pkce['challenge']!,
                    );
                    String? kakaoAuthCode;

                    if (!context.mounted) return;

                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(ctx).viewInsets.bottom,
                        ),
                        child: SocialLoginWebView(
                          authUrl: authUrl,
                          onCodeCaptured: (code) => kakaoAuthCode = code,
                        ),
                      ),
                    );

                    if (kakaoAuthCode != null && context.mounted) {
                      await AuthService.sendKakaoAuthToBackend(
                        code: kakaoAuthCode!,
                        codeVerifier: pkce['codeVerifier']!,
                        context: context,
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),

                // 구글 로그인 버튼
                _buildSocialButton(
                  label: '구글로 시작하기',
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF0A0A0A),
                  iconPath: 'assets/images/icons/google_logo.svg',
                  borderColor: const Color(0xFFD1D5DC),
                  onTap: () async {
                    try {
                      final authResult = await AuthService.signInWithGoogle();

                      if (authResult != null) {
                        await AuthService.sendTokenToBackend(
                          code: authResult['code']!,
                          codeVerifier: authResult['codeVerifier']!,
                          context: context,
                        );
                      }
                    } catch (e) {
                      debugPrint('========= [UI 레이어] 에러 포착 =========');
                      debugPrint('에러 내용: $e');
                      if (e is DioException) {
                        debugPrint('서버가 준 데이터: ${e.response?.data}');
                      }
                      debugPrint('=======================================');
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  label: '네이버로 시작하기',
                  backgroundColor: const Color(0xFF03C75A),
                  textColor: Colors.white,
                  iconPath: 'assets/images/icons/naver_logo.svg',
                  onTap: () async {
                    // 1. 상태(state) 문자열 생성 (카카오의 PKCE 함수를 재사용하여 임의의 문자열 15자리 생성)
                    final state = AuthService.generatePkcePair()['challenge']!
                        .substring(0, 15);
                    final authUrl = AuthService.getNaverAuthUrl(state);
                    String? naverAuthCode;

                    if (!context.mounted) return;

                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(ctx).viewInsets.bottom,
                        ),
                        child: SocialLoginWebView(
                          authUrl: authUrl,
                          onCodeCaptured: (code) => naverAuthCode = code,
                        ),
                      ),
                    );

                    if (naverAuthCode != null && context.mounted) {
                      await AuthService.sendNaverAuthToBackend(
                        code: naverAuthCode!,
                        state: state,
                        context: context,
                      );
                    }
                  },
                ),

                const SizedBox(height: 30),

                // 하단 안내 문구
                Text(
                  '계속 진행하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다',
                  textAlign: TextAlign.center,
                  style: AppTypography.b2.copyWith(color: appColors.gray3),
                ),
                const SizedBox(height: 40), // 하단 여백
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 소셜 버튼 위젯
  Widget _buildSocialButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required String iconPath,
    required VoidCallback onTap,
    Color? borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: borderColor != null
                ? BorderSide(width: 2, color: borderColor)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 24, height: 24),
            const SizedBox(width: 12),
            Text(label, style: AppTypography.b1.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}

class SocialLoginWebView extends StatefulWidget {
  final String authUrl;
  final Function(String) onCodeCaptured;

  const SocialLoginWebView({
    super.key,
    required this.authUrl,
    required this.onCodeCaptured,
  });

  @override
  State<SocialLoginWebView> createState() => _SocialLoginWebViewState();
}

class _SocialLoginWebViewState extends State<SocialLoginWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // 매번 새로운 로그인을 위해 쿠키와 캐시를 삭제합니다.
    // 코드 삭제시: 이전 로그인 세션이 남아있어 다른 계정으로 로그인 시도 시 문제가 발생할 수 있습니다.
    WebViewCookieManager().clearCookies();

    // 컨트롤러 초기화
    _controller = WebViewController();
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    // [크로스 플랫폼 설정] OS를 확인하여 User-Agent를 설정합니다.
    if (Platform.isIOS) {
      // iOS: 사파리 브라우저인 척 속여서 네이버 '웹 로그인'을 강제합니다.
      _controller.setUserAgent(
        "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1",
      );
    } else {
      // Android: 기존에 사용하던 안드로이드 브라우저 설정을 유지합니다.
      _controller.setUserAgent(
        "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
      );
    }

    // 3. 네비게이션 델리게이트 설정 (케스케이드 연산자 없이 호출)
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (error) {
          if (error.errorCode == -1002) return;
          debugPrint("🌐 웹 리소스 에러: ${error.description}");
        },
        onNavigationRequest: (NavigationRequest request) async {
          final url = request.url;
          debugPrint("🔗 현재 이동하려는 URL: $url");

          // ⭐️ [크로스 플랫폼 설정] 외부 앱(카카오톡 등) 실행 로직
          if (!url.startsWith('http://') && !url.startsWith('https://')) {
            debugPrint("🚀 외부 앱 실행 시도: $url");
            try {
              final Uri uri = Uri.parse(url);

              if (Platform.isIOS) {
                // iOS: 바로 앱 열기 시도
                final launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                if (launched) debugPrint("✅ iOS 외부 앱 실행 성공!");
              } else {
                // Android: 안전하게 실행 가능 여부 확인 후 실행
                if (await canLaunchUrl(uri)) {
                  final launched = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (launched) debugPrint("✅ Android 외부 앱 실행 성공!");
                }
              }
            } catch (e) {
              debugPrint('🚨 외부 앱 실행 중 예외 발생: $e');
            }
            return NavigationDecision.prevent;
          }

          // 콜백 주소 감지 로직 (기존과 동일)
          if (url.contains('/oauth/naver/callback') ||
              url.contains('/oauth/kakao/callback')) {
            final uri = Uri.parse(url);
            final code = uri.queryParameters['code'];
            if (code != null) {
              widget.onCodeCaptured(code);
              if (mounted) Navigator.pop(context);
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
      ),
    );

    // 4. 페이지 로드 요청
    _controller.loadRequest(Uri.parse(widget.authUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: WebViewWidget(controller: _controller),
    );
  }
}
