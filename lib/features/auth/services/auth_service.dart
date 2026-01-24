// 최초 작성자 : 김채영
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthService {
//   static final GoogleSignIn _googleSignIn = GoogleSignIn(
//     // 여기서 Web 클라이언트 ID를 사용
//     // 이렇게 해야 백엔드에서 검증 가능한 'idToken'이 정상적으로 발급됩니다.
//     serverClientId: '방금-복사한-WEB-클라이언트-ID.apps.googleusercontent.com',
//   );

//   static Future<void> handleSignIn() async {
//     try {
//       final GoogleSignInAccount? user = await _googleSignIn.signIn();
//       if (user != null) {
//         final GoogleSignInAuthentication auth = user.authentication;

//         // 백엔드에게 넘겨줄 핵심 데이터
//         print("ID Token: ${auth.idToken}");

//         // TODO: Dio나 Http를 사용하여 백엔드 API에 auth.idToken 전송
//       }
//     } catch (error) {
//       print("로그인 실패: $error");
//     }
//   }
// }
