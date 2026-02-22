// 최초 작성자 : 김채영
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:image/image.dart' as img;

import '../widgets/circular_overlay_painter.dart';
import '../widgets/profile_edit_tools.dart';
import '../utils/profile_image_utils.dart';

class ProfileImageEditScreen extends StatefulWidget {
  final File imageFile;

  const ProfileImageEditScreen({super.key, required this.imageFile});

  @override
  State<ProfileImageEditScreen> createState() => _ProfileImageEditScreenState();
}

class _ProfileImageEditScreenState extends State<ProfileImageEditScreen> {
  final _cropController = CropController();

  int _rotationTurns = 0;

  bool _isCropping = false;

  Uint8List? _originalImageData;

  Uint8List? _imageData;

  double _imgWidth = 0;

  double _imgHeight = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,

      body: SafeArea(
        child: Column(
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
                ? const Text(
                    '취소',

                    style: TextStyle(color: Colors.white, fontSize: 18),
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

              style: AppTypography.b3.copyWith(
                color: Colors.white,

                fontWeight: FontWeight.bold,
              ),
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
        // 실시간 회전 상태가 반영된 이미지 영역 계산

        final Rect imageRect = _calculateImageRect(constraints);

        return Stack(
          fit: StackFit.expand,

          children: [
            Center(
              child: RotatedBox(
                quarterTurns: _rotationTurns,

                child: Image.memory(
                  _imageData!,

                  key: ValueKey(_imageData),

                  fit: BoxFit.contain,
                ),
              ),
            ),

            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,

                // 계산된 이미지 영역을 전달하여 원형 가이드를 그립니다.
                painter: CircularOverlayPainter(cropRect: imageRect),
              ),
            ),
          ],
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
        }),

        const SizedBox(width: 155),

        _buildToolButton('assets/images/icons/cut.svg', '자르기', () {
          if (_rotationTurns != 0) {
            final rotatedOriginal = rotateImageBytes(
              _originalImageData!,

              _rotationTurns,
            );

            setState(() {
              _originalImageData = rotatedOriginal;

              _rotationTurns = 0;
            });
          }

          setState(() => _isCropping = true);
        }),
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

    Uint8List finalData = _imageData!;

    if (_rotationTurns != 0) {
      finalData = rotateImageBytes(finalData, _rotationTurns);
    }

    final tempDir = await getTemporaryDirectory();

    final file = File(
      '${tempDir.path}/profile_edited_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(finalData);

    if (mounted) Navigator.pop(context, file);
  }
}

Uint8List rotateImageBytes(Uint8List imageBytes, int turns) {
  if (turns == 0) return imageBytes;

  img.Image? originalImage = img.decodeImage(imageBytes);

  if (originalImage == null) return imageBytes;

  img.Image rotatedImage = img.copyRotate(originalImage, angle: turns * 90);

  return Uint8List.fromList(img.encodePng(rotatedImage));
}
