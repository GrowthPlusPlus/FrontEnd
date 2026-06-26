// 최초 작성자: 정승빈
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

// 토스트를 띄우기 위한 공통 함수
void displayToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => AnimatedToast(
      message: message,
      onDismissed: () {
        overlayEntry.remove();
      },
    ),
  );

  overlay.insert(overlayEntry);
}

bool? _isAndroid13Plus;

// os 시스템 링크 복사 토스트 메시지와 해냄 커스텀 토스트 메시지가
// 겹치는 거 막는 코드
Future<bool> _shouldShowCustomCopyToast() async {
  if (_isAndroid13Plus != null) return !_isAndroid13Plus!;
  if (!Platform.isAndroid) {
    _isAndroid13Plus = false;
    return true;
  }
  final info = await DeviceInfoPlugin().androidInfo;
  _isAndroid13Plus = info.version.sdkInt >= 33;
  return !_isAndroid13Plus!;
}

// 클립보드 복사 전용 — Android 13+ 에서는 시스템 토스트와 중복되니 건너뜀
Future<void> displayCopyToast(BuildContext context, String message) async {
  if (await _shouldShowCustomCopyToast()) {
    if (context.mounted) displayToast(context, message);
  }
}

class AnimatedToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const AnimatedToast({
    super.key,
    required this.message,
    required this.onDismissed,
  });

  @override
  State<AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutQuart));

    opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    controller.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        await controller.reverse();
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: opacityAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC1A1D1B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: AppTypography.b1.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
