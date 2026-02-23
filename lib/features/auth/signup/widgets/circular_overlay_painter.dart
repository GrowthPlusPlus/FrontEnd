// 최초 작성자: 김채영
import 'package:flutter/material.dart';

// 원형 오버레이 페인터
class CircularOverlayPainter extends CustomPainter {
  final Rect cropRect;

  CircularOverlayPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    if (cropRect == Rect.zero) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 가로/세로 중 가장 짧은 변을 기준으로 반지름을 설정하여 사진 안에 가둡니다.

    final radius = cropRect.shortestSide / 2;

    final center = cropRect.center;

    final path = Path.combine(
      PathOperation.difference,

      Path()..addRect(rect),

      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawPath(path, Paint()..color = Colors.black54);

    canvas.drawCircle(
      center,

      radius,

      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CircularOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}
