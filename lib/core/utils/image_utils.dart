// 최초 작성자: 김채영
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

// 클라우더리 용량 이슈 때문에 필요한 인증글의 이미지 압축 유틸 함수
Future<File> compressImageFile(File file) async {
  final tempDir = await getTemporaryDirectory();
  final targetPath =
      '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

  final XFile? result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 80, // 80 정도면 육안상 차이 거의 없음
    minWidth: 1080, // 긴 쪽 기준 최대 해상도
    minHeight: 1080,
    format: CompressFormat.jpeg,
  );

  // ✅ 압축 전후 크기 비교 로그
  final int originalSize = await file.length();
  final int compressedSize = result != null
      ? await File(result.path).length()
      : 0;

  debugPrint('🖼️ 압축 전: ${(originalSize / 1024).toStringAsFixed(1)} KB');
  debugPrint('🖼️ 압축 후: ${(compressedSize / 1024).toStringAsFixed(1)} KB');
  debugPrint(
    '🖼️ 압축률: ${((1 - compressedSize / originalSize) * 100).toStringAsFixed(1)}%',
  );

  return result != null ? File(result.path) : file; // 실패 시 원본 반환
}
