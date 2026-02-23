// 최초 작성자: 김채영
import 'dart:typed_data';
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
}
