// 최초 작성자: 김채영
import 'dart:typed_data';
import 'package:flutter/material.dart' show Rect;
import 'package:image/image.dart' as img;

// 이미지 물리 회전
class ImageUtils {
  static Uint8List rotateImageBytes(Uint8List imageBytes, int turns) {
    if (turns == 0) return imageBytes;

    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) return imageBytes;

    img.Image rotatedImage = img.copyRotate(originalImage, angle: turns * 90);

    return Uint8List.fromList(img.encodePng(rotatedImage));
  }

  // 픽셀 좌표 기준으로 잘라내기
  // 미리보기 프로필 편집 화면에서도 사진 확대/축소만으로 편집할 수 있게 하기 위한 코드
  static Uint8List cropImageBytes(Uint8List imageBytes, Rect rect) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) return imageBytes;

    final x = rect.left.round().clamp(0, decoded.width - 1);
    final y = rect.top.round().clamp(0, decoded.height - 1);
    final w = rect.width.round().clamp(1, decoded.width - x);
    final h = rect.height.round().clamp(1, decoded.height - y);

    final cropped = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
    return Uint8List.fromList(img.encodePng(cropped));
  }
}

// compute() 용 - 회전 후 자를 경우 로딩 인디케이터 표시를 위한 코드
class RotateParams {
  final Uint8List bytes;
  final int turns;
  RotateParams(this.bytes, this.turns);
}

// 미리보기 프로필 편집 화면에서도 사진 확대/축소만으로 편집할 수 있게 하기 위한 코드
class CropParams {
  final Uint8List bytes;
  final Rect rect;
  CropParams(this.bytes, this.rect);
}

Uint8List rotateImageBytesForIsolate(RotateParams params) =>
    ImageUtils.rotateImageBytes(params.bytes, params.turns);

Uint8List cropImageBytesForIsolate(CropParams params) =>
    ImageUtils.cropImageBytes(params.bytes, params.rect);
