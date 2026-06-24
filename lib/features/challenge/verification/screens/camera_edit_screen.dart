// 최초 작성자 : 김채영
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:image/image.dart' as img;

final GlobalKey _repaintKey = GlobalKey();

// 카메라로 촬영했을 때의 편집 화면
class CameraEditScreen extends StatefulWidget {
  final File imageFile;
  const CameraEditScreen({super.key, required this.imageFile});

  @override
  State<CameraEditScreen> createState() => _CameraEditScreenState();
}

class _CameraEditScreenState extends State<CameraEditScreen> {
  final _cropController = CropController();
  int _rotationTurns = 0;
  bool _isCropping = false; // 자르기 모드 상태
  Uint8List? _imageData; // 편집할 이미지 바이트 데이터

  final String _timestamp = DateFormat(
    'yyyy년 MM월 dd일\na hh시 mm분',
    'ko_KR',
  ).format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadImageBytes();
  }

  // 파일에서 바이트 데이터 로드
  Future<void> _loadImageBytes() async {
    final bytes = await widget.imageFile.readAsBytes();
    setState(() {
      _imageData = bytes;
    });
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
                const SizedBox(height: 120),

                // 자르기 모드일 때와 아닐 때의 화면 분기
                Expanded(
                  flex: 10,
                  child: _isCropping ? _buildCropWidget() : _buildImageArea(),
                ),

                const SizedBox(height: 42),
                // 자르기 모드일 때는 도구와 버튼 숨김
                if (!_isCropping) ...[
                  _buildEditTools(),
                  _buildBottomAction(),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 상단 바
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
                setState(() => _isCropping = false); // 자르기 취소
              } else {
                Navigator.pop(context);
              }
            },
            child: _isCropping
                ? Text(
                    '취소',
                    style: AppTypography.b3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
          Text('카메라', style: AppTypography.h3.copyWith(color: Colors.white)),
          GestureDetector(
            onTap: () async {
              if (_isCropping) {
                _cropController.crop(); // 자르기 실행
              } else {
                _saveAndReturn(); // 최종 결과 반환
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

  // 자르기 위젯
  Widget _buildCropWidget() {
    if (_imageData == null)
      return const Center(child: CircularProgressIndicator());

    return Crop(
      image: _imageData!,
      controller: _cropController,
      onCropped: (result) {
        if (result is CropSuccess) {
          setState(() {
            _imageData = result.croppedImage; // 잘린 이미지로 데이터 업데이트
            _isCropping = false;
          });
        }
      },
      maskColor: Colors.black54,
      radius: 12,
      interactive: true,
    );
  }

  // 이미지 영역 (정사각형 사진 + 타임스탬프)
  Widget _buildImageArea() {
    if (_imageData == null) return const SizedBox();

    // 현재 기기의 화면 너비 가져오기
    final double screenWidth = MediaQuery.of(context).size.width;

    return RepaintBoundary(
      // ✅ 추가
      key: _repaintKey, // ✅ 추가
      child: Container(
        width: screenWidth, // 너비: 화면 가득
        height: screenWidth,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            // 배경 이미지 (회전 적용)
            Positioned.fill(
              child: RotatedBox(
                quarterTurns: _rotationTurns,
                child: Image.memory(_imageData!, fit: BoxFit.cover),
              ),
            ),
            // 타임스탬프 (자르기 모드가 아닐 때만 보임)
            Positioned(
              right: 40,
              bottom: 16,
              child: Text(
                _timestamp,
                textAlign: TextAlign.right,
                style: AppTypography.h1.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 편집 도구 (회전, 자르기)
  Widget _buildEditTools() {
    return SizedBox(
      height: 92,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToolButton('assets/images/icons/rotate.svg', '회전', () {
            setState(() => _rotationTurns = (_rotationTurns + 1) % 4);
          }),
          const SizedBox(width: 150), // Raw 코드의 넓은 간격 반영
          _buildToolButton('assets/images/icons/cut.svg', '자르기', () {
            setState(() => _isCropping = true);
          }),
        ],
      ),
    );
  }

  Widget _buildToolButton(String path, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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

  // 다시 촬영하기 버튼
  Widget _buildBottomAction() {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: screenWidth - 36,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Colors.white),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              '다시 촬영하기',
              style: AppTypography.h3.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // 최종 편집본을 파일로 저장 후 반환
  Future<void> _saveAndReturn() async {
    if (_imageData == null) return;

    try {
      // RepaintBoundary로 화면에 보이는 그대로 캡처 (타임스탬프 포함)
      final RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // pixelRatio를 높이면 캡처 해상도가 올라감 (3.0 권장)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return;
      final Uint8List finalData = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/camera_edited_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(finalData);

      if (mounted) Navigator.pop(context, file);
    } catch (e) {
      debugPrint('이미지 캡처 에러: $e');
    }
  }
}

// 이미지 바이트와 회전 횟수를 받아 회전된 바이트를 반환
Uint8List rotateImageBytes(Uint8List imageBytes, int turns) {
  if (turns == 0) return imageBytes;

  // 바이트를 이미지 객체로 디코딩
  img.Image? originalImage = img.decodeImage(imageBytes);
  if (originalImage == null) return imageBytes;

  // 회전 실행 (turns 1당 90도)
  // image 패키지는 시계 방향 회전을 지원함
  img.Image rotatedImage = img.copyRotate(originalImage, angle: turns * 90);

  // 다시 PNG나 JPG로 인코딩하여 반환
  return Uint8List.fromList(img.encodePng(rotatedImage));
}
