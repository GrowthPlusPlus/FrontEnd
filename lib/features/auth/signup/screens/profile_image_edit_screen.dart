// 최초 작성자 : 김채영
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:image/image.dart' as img;
import 'package:haenaem/shared/widgets/animated_toast.dart';

import '../widgets/circular_overlay_painter.dart';
import '../widgets/profile_edit_tools.dart';
import '../utils/profile_image_utils.dart';

// 프로필 사진 편집 화면
class ProfileImageEditScreen extends StatefulWidget {
  final File imageFile;

  const ProfileImageEditScreen({super.key, required this.imageFile});

  @override
  State<ProfileImageEditScreen> createState() => _ProfileImageEditScreenState();
}

class _ProfileImageEditScreenState extends State<ProfileImageEditScreen> {
  final _cropController = CropController();
  final TransformationController _transformController =
      TransformationController();
  bool _isProcessing = false; // 사용자가 회전 후 자르기 버튼을 누를 경우, 로딩 중임을 알리기 위함

  int _rotationTurns = 0;
  bool _isCropping = false;
  Uint8List? _originalImageData;
  Uint8List? _imageData;
  double _imgWidth = 0;
  double _imgHeight = 0;
  Size? _lastViewportSize; // 미리보기 영역의 실제 크기 기억

  double _scale = 1.0; // ✅ TransformationController 대신 직접 관리
  Offset _pan = Offset.zero;

  // 제스처 진행 중 임시 추적용
  double? _gestureStartScale;
  Offset? _gestureStartPan;
  Offset? _gestureStartFocal;

  @override
  void initState() {
    super.initState();

    _loadImageBytes();
  }

  Future<void> _loadImageBytes() async {
    final bytes = await widget.imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded != null) {
      setState(() {
        _originalImageData = bytes;
        _imageData = bytes;
        _imgWidth = decoded.width.toDouble();
        _imgHeight = decoded.height.toDouble();
      });
    }
  }

  // 회전 -> 자르기 로딩 처리
  // 프로필 이미지를 회전한 후, 자르기 버튼을 눌렀을 때 자르기 화면으로 넘어가는 게 오래 걸려서
  Future<void> _onCropPressed() async {
    if (_rotationTurns != 0) {
      setState(() => _isProcessing = true); // ✅ 로딩 시작

      final turns = _rotationTurns;

      // ✅ 별도 isolate에서 처리 → 메인 스레드 안 막힘 → 인디케이터 정상 애니메이션
      final rotatedOriginal = await compute(
        rotateImageBytesForIsolate,
        RotateParams(_originalImageData!, turns),
      );

      if (!mounted) return;

      setState(() {
        _originalImageData = rotatedOriginal;
        _imageData = rotatedOriginal;
        if (turns % 2 == 1) {
          final temp = _imgWidth;
          _imgWidth = _imgHeight;
          _imgHeight = temp;
        }
        _rotationTurns = 0;
        _isProcessing = false; // 로딩 끝
        _scale = 1.0; // 회전 시 줌/팬 리셋
        _pan = Offset.zero;
      });
    }

    setState(() => _isCropping = true);
  }

  // 미리보기 모드: BoxFit.contain 상태에서 화면에 실제로 그려지는 사진의 영역(Rect) 계산
  Rect _calculateImageRect(BoxConstraints constraints) {
    if (_imgWidth == 0 || _imgHeight == 0) return Rect.zero;

    double screenAspectRatio = constraints.maxWidth / constraints.maxHeight;

    // 회전 상태(홀수/짝수)에 따라 가로세로 비율 반전 반영
    double imageAspectRatio = (_rotationTurns % 2 == 0)
        ? _imgWidth / _imgHeight
        : _imgHeight / _imgWidth;

    double renderWidth, renderHeight;

    if (imageAspectRatio > screenAspectRatio) {
      renderWidth = constraints.maxWidth;
      renderHeight = constraints.maxWidth / imageAspectRatio;
    } else {
      renderHeight = constraints.maxHeight;
      renderWidth = constraints.maxHeight * imageAspectRatio;
    }

    return Rect.fromCenter(
      center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
      width: renderWidth,
      height: renderHeight,
    );
  }

  // 자르기 모드: 화면 너비 기준 고정된 정사각형 영역 계산
  Rect _calculateFullCropRect(BoxConstraints constraints) {
    final double side = constraints.maxWidth - 40;
    final double left = (constraints.maxWidth - side) / 2;
    final double top = (constraints.maxHeight - side) / 2;

    return Rect.fromLTWH(left, top, side, side);
  }

  // 원형 가이드가 항상 사진 안에 있도록 팬 값을 직접 클램핑
  Offset _clampPan(Offset pan, double scale, Size viewport) {
    final baseRect = _calculateImageRect(BoxConstraints.tight(viewport));
    if (baseRect == Rect.zero) return Offset.zero;

    final guideSide = baseRect.shortestSide;
    final halfW = baseRect.width * scale / 2;
    final halfH = baseRect.height * scale / 2;

    final maxDx = (halfW - guideSide / 2).clamp(0.0, double.infinity);
    final maxDy = (halfH - guideSide / 2).clamp(0.0, double.infinity);

    return Offset(pan.dx.clamp(-maxDx, maxDx), pan.dy.clamp(-maxDy, maxDy));
  }

  // 화면에 보이는 원형 가이드 영역 → 실제 이미지 픽셀 좌표로 역산
  Rect? _calculateVisibleImageRect(Size viewportSize) {
    final baseRect = _calculateImageRect(BoxConstraints.tight(viewportSize));
    if (baseRect == Rect.zero) return null;

    final center = Offset(viewportSize.width / 2, viewportSize.height / 2);

    final displayedRect = Rect.fromCenter(
      center: center + _pan,
      width: baseRect.width * _scale,
      height: baseRect.height * _scale,
    );

    final guideSide = baseRect.shortestSide;
    final guideRect = Rect.fromCenter(
      center: center,
      width: guideSide,
      height: guideSide,
    );

    final relLeft = (guideRect.left - displayedRect.left) / displayedRect.width;
    final relTop = (guideRect.top - displayedRect.top) / displayedRect.height;
    final relRight =
        (guideRect.right - displayedRect.left) / displayedRect.width;
    final relBottom =
        (guideRect.bottom - displayedRect.top) / displayedRect.height;

    return Rect.fromLTRB(
      (relLeft * _imgWidth).clamp(0, _imgWidth),
      (relTop * _imgHeight).clamp(0, _imgHeight),
      (relRight * _imgWidth).clamp(0, _imgWidth),
      (relBottom * _imgHeight).clamp(0, _imgHeight),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopNavBar(),
                const Spacer(),
                Expanded(
                  flex: 10,
                  child: _isCropping ? _buildCropWidget() : _buildImageArea(),
                ),

                const Spacer(),

                if (!_isCropping) ...[
                  _buildEditTools(),
                  const SizedBox(height: 40),
                ],
              ],
            ),

            // 로딩 인디케이터
            if (_isProcessing)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAble,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      width: double.infinity,
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (_isCropping) {
                setState(() => _isCropping = false);
              } else {
                Navigator.pop(context);
              }
            },

            child: _isCropping
                ? Text(
                    '취소',
                    style: AppTypography.b3.copyWith(color: Colors.white),
                  )
                : SvgPicture.asset(
                    'assets/images/icons/arrow_left.svg',
                    width: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
          ),

          Text('프로필 편집', style: AppTypography.h3.copyWith(color: Colors.white)),

          GestureDetector(
            onTap: () {
              if (_isCropping) {
                _cropController.crop();
              } else {
                _saveAndReturn();
              }
            },

            child: Text(
              _isCropping ? '적용' : '완료',
              style: AppTypography.b3.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropWidget() {
    if (_originalImageData == null)
      return const Center(child: CircularProgressIndicator());

    return LayoutBuilder(
      builder: (context, constraints) {
        final Rect largeCropRect = _calculateFullCropRect(constraints);

        return Stack(
          fit: StackFit.expand,
          children: [
            Crop(
              key: ValueKey(_originalImageData),
              image: _originalImageData!,
              controller: _cropController,
              onCropped: (result) {
                if (result is CropSuccess) {
                  setState(() {
                    _imageData = result.croppedImage;
                    _isCropping = false;
                    final decoded = img.decodeImage(result.croppedImage);
                    if (decoded != null) {
                      _imgWidth = decoded.width.toDouble();
                      _imgHeight = decoded.height.toDouble();
                    }
                    _scale = 1.0;
                    _pan = Offset.zero;
                  });
                }
              },
              aspectRatio: 1 / 1,
              maskColor: Colors.transparent,
              radius: 0,
              initialRectBuilder: InitialRectBuilder.withBuilder(
                (viewRect, imageRect) => largeCropRect,
              ),
              interactive: true,
              fixCropRect: true,
              baseColor: AppColors.black,
            ),
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: CircularOverlayPainter(cropRect: largeCropRect),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageArea() {
    if (_imageData == null) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        _lastViewportSize = viewport;
        final Rect imageRect = _calculateImageRect(constraints);

        return ClipRect(
          child: GestureDetector(
            onScaleStart: (details) {
              _gestureStartScale = _scale;
              _gestureStartPan = _pan;
              _gestureStartFocal = details.localFocalPoint;
            },
            onScaleUpdate: (details) {
              final newScale = (_gestureStartScale! * details.scale).clamp(
                1.0,
                4.0,
              );
              final focalDelta = details.localFocalPoint - _gestureStartFocal!;
              final rawPan = _gestureStartPan! + focalDelta;
              setState(() {
                _scale = newScale;
                _pan = _clampPan(rawPan, newScale, viewport);
              });
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(_pan.dx, _pan.dy)
                      ..scale(_scale),
                    child: RotatedBox(
                      quarterTurns: _rotationTurns,
                      child: Image.memory(
                        _imageData!,
                        key: ValueKey(_imageData),
                        width: viewport.width,
                        height: viewport.height,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: CircularOverlayPainter(cropRect: imageRect),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        _buildToolButton('assets/images/icons/rotate.svg', '회전', () {
          setState(() => _rotationTurns = (_rotationTurns + 1) % 4);
          // 회전하면 비율이 바뀌므로 줌/팬 리셋
          _scale = 1.0;
          _pan = Offset.zero;
        }),

        const SizedBox(width: 155),
        _buildToolButton('assets/images/icons/cut.svg', '자르기', _onCropPressed),
      ],
    );
  }

  Widget _buildToolButton(String path, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          SvgPicture.asset(
            path,
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Arimo',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndReturn() async {
    if (_imageData == null) return;
    setState(() => _isProcessing = true);

    try {
      Uint8List finalData = _imageData!;
      if (_rotationTurns != 0) {
        finalData = await compute(
          rotateImageBytesForIsolate,
          RotateParams(finalData, _rotationTurns),
        );
      } else if (_lastViewportSize != null &&
          (_scale != 1.0 || _pan != Offset.zero)) {
        final visibleRect = _calculateVisibleImageRect(_lastViewportSize!);
        if (visibleRect != null &&
            visibleRect.width > 1 &&
            visibleRect.height > 1) {
          finalData = await compute(
            cropImageBytesForIsolate,
            CropParams(finalData, visibleRect),
          );
        }
      }

      if (!mounted) return;

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/profile_edited_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(finalData);

      if (mounted) Navigator.pop(context, file);
    } catch (e) {
      debugPrint('프로필 이미지 저장 실패: $e');
      if (mounted) {
        setState(() => _isProcessing = false); // 실패해도 로딩 풀어줌
        displayToast(context, '이미지 처리 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
    }
  }
}
