// 최초 작성자: 김채영
import 'package:flutter/material.dart';

// 정사각형 가이드 오버레이 (인증 사진 편집 부분)
class SquareOverlayPainter extends CustomPainter {
  final Rect guideRect;

  SquareOverlayPainter({required this.guideRect});

  @override
  void paint(Canvas canvas, Size size) {
    if (guideRect == Rect.zero) return;

    final outer = Rect.fromLTWH(0, 0, size.width, size.height);

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(outer),
      Path()..addRect(guideRect),
    );

    canvas.drawPath(path, Paint()..color = Colors.black54);

    canvas.drawRect(
      guideRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant SquareOverlayPainter oldDelegate) {
    return oldDelegate.guideRect != guideRect;
  }
}
