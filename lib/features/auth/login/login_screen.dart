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

// 소셜 로그인 화면
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 공통으로 사용할 네비게이션 함수
    void navigateToSignup() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupMainScreen()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
                SvgPicture.asset('assets/images/icons/sign_up_logo.svg'),
                const SizedBox(height: 26),
                Text(
                  "오늘의 '해냄'을 위해\n지금 시작해보세요",
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(color: Colors.black),
                ),

                const SizedBox(height: 120), // 중간 여백
                // 로그인 버튼들
                Text(
                  '간편하게 시작하기',
                  textAlign: TextAlign.center,
                  style: AppTypography.b2.copyWith(
                    color: const Color(0xFf6A7282),
                  ),
                ),
                const SizedBox(height: 10),

                // 버튼들 사이의 간격을 SizedBox로 조정 (버전 호환성)
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

                    // 2. 웹뷰 실행 (UI 부분이라 Screen에 두는 게 적절합니다)
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(ctx).viewInsets.bottom,
                        ),
                        child: _buildKakaoWebView(
                          context: ctx,
                          authUrl: authUrl,
                          onCodeCaptured: (code) => kakaoAuthCode = code,
                        ),
                      ),
                    );

                    // 3. 획득한 코드가 있다면 백엔드로 전송
                    if (kakaoAuthCode != null && context.mounted) {
                      await AuthService.sendKakaoAuthToBackend(
                        code: kakaoAuthCode!,
                        codeVerifier: pkce['codeVerifier']!, // 원본 열쇠 전송
                        context: context,
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
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
                  onTap: navigateToSignup,
                  //onTap = () {},
                ),

                const SizedBox(height: 30),

                // 하단 안내 문구
                Text(
                  '계속 진행하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다',
                  textAlign: TextAlign.center,
                  style: AppTypography.b2.copyWith(
                    color: const Color(0xFF6A7282),
                  ),
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

  Widget _buildKakaoWebView({
    required BuildContext context,
    required String authUrl,
    required Function(String) onCodeCaptured,
  }) {
    late final WebViewController controller;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
    ⚠️ 웹뷰 로딩 에러 발생!
    - 코드: ${error.errorCode}
    - 설명: ${error.description}
    - URL: ${error.url}
  ''');
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;

            // 📍 [중요] 주소 감지 로그 추가
            if (url.contains('/oauth/kakao/callback')) {
              debugPrint('🎣 [감지 성공] 카카오 콜백 주소가 포착되었습니다!');
              final uri = Uri.parse(url);
              final code = uri.queryParameters['code'];

              if (code != null) {
                debugPrint('✅ 획득한 인가 코드: $code');
                onCodeCaptured(code);
                Navigator.pop(context); // 웹뷰 닫기
                return NavigationDecision.prevent; // 페이지 이동 중단
              }
            }

            // 2️⃣ 카카오톡 앱 호출 주소 처리
            if (url.startsWith('kakaotalk://') || url.startsWith('intent://')) {
              try {
                debugPrint('📱 카카오톡 앱 실행 시도: $url');

                // intent:// 스킴인 경우 안드로이드용 특수 처리가 필요할 수 있지만,
                // url_launcher가 대부분 해결해줍니다.
                final canLaunch = await canLaunchUrl(Uri.parse(url));
                if (canLaunch) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                  return NavigationDecision.prevent;
                }
              } catch (e) {
                debugPrint('🚨 앱 실행 실패: $e');
                // 앱 실행 실패 시 웹에서 로그인하도록 유지 (prevent 하지 않음)
              }
            }

            // 리다이렉트 및 기타 주소 처리
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            debugPrint("🚀 웹뷰 로딩 시작됨: $url");
            // ✅ AuthService.kakaoRedirectUri로 시작하는지 감시
            if (url.startsWith(AuthService.kakaoRedirectUri)) {
              debugPrint('🎣 리다이렉트 감지!');
              final uri = Uri.parse(url);
              final code = uri.queryParameters['code'];
              if (code != null) {
                onCodeCaptured(code);
                Navigator.pop(context);
              }
            }
          },
          onPageFinished: (url) {
            debugPrint("✅ 웹뷰 로딩 완료됨: $url");
          },
        ),
      )
      ..loadRequest(Uri.parse(authUrl));

    // 📍 로드하기 직전에 실제 어떤 주소를 부르는지 확인!
    debugPrint("🌍 웹뷰 로딩 시도 URL: $authUrl");

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: WebViewWidget(controller: controller),
    );
  }
}
