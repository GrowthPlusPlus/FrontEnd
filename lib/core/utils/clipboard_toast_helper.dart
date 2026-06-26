// 최초 작성자: 김채영
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

// 초대 링크 복사할 경우, os 차원의 시스템 토스트 메시지와 해냄 커스텀 토스트 메시지가 겹치는 문제 해결
class ClipboardToastHelper {
  static bool? _isAndroid13Plus; // 한 번만 조회해서 캐싱

  /// "복사하기" 액션에 한해서만 커스텀 토스트를 보여줘야 하는지 여부
  /// Android 13+ 는 시스템이 자체 토스트를 띄우므로 false 반환
  static Future<bool> shouldShowCustomCopyToast() async {
    if (_isAndroid13Plus != null) return !_isAndroid13Plus!;

    if (!Platform.isAndroid) {
      _isAndroid13Plus = false;
      return true; // iOS 등은 그대로 커스텀 토스트 사용
    }

    final info = await DeviceInfoPlugin().androidInfo;
    _isAndroid13Plus = info.version.sdkInt >= 33; // Android 13 = API 33
    return !_isAndroid13Plus!;
  }
}
