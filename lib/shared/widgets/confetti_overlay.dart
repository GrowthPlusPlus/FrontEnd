import 'dart:math';
import 'package:flutter/material.dart';

// 색종이(컨페티) 애니메이션
// - Overlay에 직접 삽입해서 사용 (showConfetti 헬퍼 함수 참고)
class ConfettiOverlay extends StatefulWidget {
  final VoidCallback? onComplete;
  final Alignment origin; // 터지는 시작 위치 (기본: 화면 하단쪽)
  final bool allDirections; // true면 사방으로(불꽃놀이), false면 위로 부채꼴(분수)
  final int pieceCount;

  const ConfettiOverlay({
    super.key,
    this.onComplete,
    this.origin = const Alignment(0, 0.2),
    this.allDirections = false,
    this.pieceCount = 50,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1400);
  static const _colors = [
    Color(0xFF009951), // 해냄 그린
    Color(0xFF4589FF), // 블루
    Color(0xFFFFB020), // 골드
    Color(0xFFFF6F61), // 코랄
    Colors.white,
  ];

  late final AnimationController _controller;
  late final List<_ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _pieces = List.generate(widget.pieceCount, (_) => _createPiece(random));
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addListener(() => setState(() {}))
      ..forward().whenComplete(() => widget.onComplete?.call());
  }

  _ConfettiPiece _createPiece(Random random) {
    final double angle;
    if (widget.allDirections) {
      // ✅ 360도 전방향으로 (불꽃놀이 스타일)
      angle = random.nextDouble() * 2 * pi;
    } else {
      // 위쪽으로 부채꼴 형태로 퍼지도록 (-90도 기준 좌우로 퍼짐)
      angle = -pi / 2 + (random.nextDouble() - 0.5) * pi * 1.1;
    }
    return _ConfettiPiece(
      angle: angle,
      speed: 220 + random.nextDouble() * 260,
      color: _colors[random.nextInt(_colors.length)],
      size: 6 + random.nextDouble() * 6,
      rotationSpeed: (random.nextDouble() - 0.5) * 10,
      xJitter: (random.nextDouble() - 0.5) * 60,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final elapsedSeconds = _controller.value * _duration.inMilliseconds / 1000;

    // Alignment(-1~1, -1~1) -> 실제 픽셀 좌표로 변환
    final origin = Offset(
      size.width / 2 + widget.origin.x * size.width / 2,
      size.height / 2 + widget.origin.y * size.height / 2,
    );

    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: _ConfettiPainter(
          pieces: _pieces,
          elapsedSeconds: elapsedSeconds,
          origin: origin,
          progress: _controller.value,
        ),
      ),
    );
  }
}

class _ConfettiPiece {
  final double angle;
  final double speed;
  final Color color;
  final double size;
  final double rotationSpeed;
  final double xJitter;

  _ConfettiPiece({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.rotationSpeed,
    required this.xJitter,
  });
}

class _ConfettiPainter extends CustomPainter {
  static const _gravity = 480.0; // px/s^2
  static const _fadeStart = 0.65;

  final List<_ConfettiPiece> pieces;
  final double elapsedSeconds;
  final Offset origin;
  final double progress;

  _ConfettiPainter({
    required this.pieces,
    required this.elapsedSeconds,
    required this.origin,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = progress < _fadeStart
        ? 1.0
        : (1.0 - (progress - _fadeStart) / (1 - _fadeStart)).clamp(0.0, 1.0);

    for (final piece in pieces) {
      final vx = cos(piece.angle) * piece.speed;
      final vy = sin(piece.angle) * piece.speed;
      final dx = origin.dx + vx * elapsedSeconds + piece.xJitter;
      final dy =
          origin.dy +
          vy * elapsedSeconds +
          0.5 * _gravity * elapsedSeconds * elapsedSeconds;

      if (dy > size.height + 20) continue;

      final paint = Paint()..color = piece.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(piece.rotationSpeed * elapsedSeconds);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: piece.size,
          height: piece.size * 0.5,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

// 어디서든 간단히 호출할 수 있는 헬퍼 함수
void showConfetti(
  BuildContext context, {
  Alignment origin = const Alignment(0, 0.2),
  bool allDirections = false,
  int pieceCount = 50,
}) {
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => ConfettiOverlay(
      origin: origin,
      allDirections: allDirections,
      pieceCount: pieceCount,
      onComplete: () => entry.remove(),
    ),
  );
  Overlay.of(context).insert(entry);
}
