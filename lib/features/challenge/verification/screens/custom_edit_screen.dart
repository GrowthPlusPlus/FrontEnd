// 최초 작성자 : 김채영
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/auth/signup/utils/profile_image_utils.dart';
import '../widgets/square_overlay_painter.dart';
import 'package:haenaem/shared/widgets/animated_toast.dart';

// 갤러리에서 선택한 사진 편집 화면
class CustomEditScreen extends StatefulWidget {
  final List<AssetEntity> selectedAssets;
  const CustomEditScreen({super.key, required this.selectedAssets});

  @override
  State<CustomEditScreen> createState() => _CustomEditScreenState();
}

class _CustomEditScreenState extends State<CustomEditScreen> {
  final _cropController = CropController();
  late PageController _pageController;
  int _currentIndex = 0; // 현재 보고 있는 이미지 인덱스
  bool _isCropping = false; // 자르기 모드 활성화 여부
  bool _isProcessing = false; // 회전/저장 처리 중 로딩 표시

  late List<int> _rotationTurns; // 각 이미지별 회전 각도
  late List<Uint8List?> _imageDataList; // 로드된 원본 이미지 데이터 리스트
  late List<double> _imgWidths; // 사진별 가로 크기
  late List<double> _imgHeights; // 사진별 세로 크기
  late List<double> _scales; // 사진별 확대 비율 (1.0 = 기본)
  late List<Offset> _pans; // 사진별 이동 거리 (화면 픽셀 단위)

  // 제스처 진행 중 임시 추적용 (한 번에 한 페이지만 조작 가능)
  int? _gestureIndex;
  double? _gestureStartScale;
  Offset? _gestureStartPan;
  Offset? _gestureStartFocal;

  Size? _lastViewportSize;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final count = widget.selectedAssets.length;
    _rotationTurns = List.generate(count, (_) => 0);
    _imageDataList = List.generate(count, (_) => null);
    _imgWidths = List.generate(count, (_) => 0);
    _imgHeights = List.generate(count, (_) => 0);
    _scales = List.generate(count, (_) => 1.0);
    _pans = List.generate(count, (_) => Offset.zero);
    _loadAllImageData();
  }

  Future<void> _loadAllImageData() async {
    for (int i = 0; i < widget.selectedAssets.length; i++) {
      final bytes = await widget.selectedAssets[i].originBytes;
      if (bytes == null) continue;
      final decoded = img.decodeImage(bytes);
      if (mounted) {
        setState(() {
          _imageDataList[i] = bytes;
          if (decoded != null) {
            _imgWidths[i] = decoded.width.toDouble();
            _imgHeights[i] = decoded.height.toDouble();
          }
        });
      }
    }
  }

  // 특정 인덱스 이미지가, 뷰포트에 BoxFit.contain으로 그려질 때의 영역 계산
  Rect _calculateImageRectFor(Size viewport, int index) {
    final w = _imgWidths[index];
    final h = _imgHeights[index];
    if (w == 0 || h == 0) return Rect.zero;

    final double screenAspect = viewport.width / viewport.height;
    final double imageAspect = (_rotationTurns[index] % 2 == 0) ? w / h : h / w;

    double renderWidth, renderHeight;
    if (imageAspect > screenAspect) {
      renderWidth = viewport.width;
      renderHeight = viewport.width / imageAspect;
    } else {
      renderHeight = viewport.height;
      renderWidth = viewport.height * imageAspect;
    }

    return Rect.fromCenter(
      center: Offset(viewport.width / 2, viewport.height / 2),
      width: renderWidth,
      height: renderHeight,
    );
  }

  // 화면에 고정으로 보이는 정사각형 가이드 (화면 좌표)
  Rect _squareGuideRect(Size viewport, int index) {
    final base = _calculateImageRectFor(viewport, index);
    if (base == Rect.zero) return Rect.zero;
    final side = base.shortestSide;
    return Rect.fromCenter(
      center: Offset(viewport.width / 2, viewport.height / 2),
      width: side,
      height: side,
    );
  }

  // 가이드가 항상 사진 안에 있도록 팬 값을 직접 클램핑
  Offset _clampPan(int index, Offset pan, double scale, Size viewport) {
    final baseRect = _calculateImageRectFor(viewport, index);
    if (baseRect == Rect.zero) return Offset.zero;

    final guideSide = baseRect.shortestSide;
    final halfW = baseRect.width * scale / 2;
    final halfH = baseRect.height * scale / 2;

    final maxDx = ((halfW - guideSide / 2)).clamp(0.0, double.infinity);
    final maxDy = ((halfH - guideSide / 2)).clamp(0.0, double.infinity);

    return Offset(pan.dx.clamp(-maxDx, maxDx), pan.dy.clamp(-maxDy, maxDy));
  }

  // 화면에 보이는 정사각형 가이드 → 실제 이미지 픽셀 좌표로 역산
  Rect? _calculateVisibleImageRectFor(Size viewport, int index) {
    final baseRect = _calculateImageRectFor(viewport, index);
    if (baseRect == Rect.zero) return null;

    final scale = _scales[index];
    final pan = _pans[index];
    final center = Offset(viewport.width / 2, viewport.height / 2);

    final displayedRect = Rect.fromCenter(
      center: center + pan,
      width: baseRect.width * scale,
      height: baseRect.height * scale,
    );

    final guideRect = _squareGuideRect(viewport, index);

    final relLeft = (guideRect.left - displayedRect.left) / displayedRect.width;
    final relTop = (guideRect.top - displayedRect.top) / displayedRect.height;
    final relRight =
        (guideRect.right - displayedRect.left) / displayedRect.width;
    final relBottom =
        (guideRect.bottom - displayedRect.top) / displayedRect.height;

    final w = _imgWidths[index];
    final h = _imgHeights[index];

    return Rect.fromLTRB(
      (relLeft * w).clamp(0, w),
      (relTop * h).clamp(0, h),
      (relRight * w).clamp(0, w),
      (relBottom * h).clamp(0, h),
    );
  }

  // 인덱스의 회전을 실제로 굽고, 상태 동기화
  Future<void> _bakeRotation(int index) async {
    final turns = _rotationTurns[index];
    if (turns == 0 || _imageDataList[index] == null) return;

    final rotated = await compute(
      rotateImageBytesForIsolate,
      RotateParams(_imageDataList[index]!, turns),
    );

    _imageDataList[index] = rotated;
    if (turns % 2 == 1) {
      final temp = _imgWidths[index];
      _imgWidths[index] = _imgHeights[index];
      _imgHeights[index] = temp;
    }
    _rotationTurns[index] = 0;
  }

  // 인덱스의 줌/팬을 실제로 잘라내고, 상태 동기화
  Future<void> _bakeZoomPanCrop(int index) async {
    if (_lastViewportSize == null) return;
    if (_scales[index] == 1.0 && _pans[index] == Offset.zero) return;
    if (_imageDataList[index] == null) return;

    final rect = _calculateVisibleImageRectFor(_lastViewportSize!, index);
    if (rect == null || rect.width <= 1 || rect.height <= 1) return;

    final cropped = await compute(
      cropImageBytesForIsolate,
      CropParams(_imageDataList[index]!, rect),
    );

    _imageDataList[index] = cropped;
    final decoded = img.decodeImage(cropped);
    if (decoded != null) {
      _imgWidths[index] = decoded.width.toDouble();
      _imgHeights[index] = decoded.height.toDouble();
    }
    _scales[index] = 1.0;
    _pans[index] = Offset.zero;
  }

  // 회전 -> 자르기 버그 수정 + 줌/팬도 같이 구워서 넘김
  Future<void> _onCropPressed() async {
    setState(() => _isProcessing = true);

    try {
      await _bakeRotation(_currentIndex);
      await _bakeZoomPanCrop(_currentIndex);

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _isCropping = true;
      });
    } catch (e) {
      debugPrint('회전/줌 처리 실패: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        displayToast(context, '이미지 처리 중 오류가 발생했습니다.');
      }
    }
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
                  // 자르기 모드 여부에 따라 다른 위젯 표시
                  child: _isCropping ? _buildCropWidget() : _buildImageSlider(),
                ),
                const Spacer(),
                // 자르기 모드가 아닐 때만 하단 편집 도구 표시
                if (!_isCropping) _buildEditTools(),
                const SizedBox(height: 20),
              ],
            ),

            // 로딩 오버레이
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

  // 상단 내비게이션 바
  Widget _buildTopNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 46,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 취소 버튼
          GestureDetector(
            onTap: () {
              if (_isCropping)
                setState(() => _isCropping = false);
              else
                Navigator.pop(context);
            },
            child: _isCropping
                ? Text(
                    '취소',
                    style: AppTypography.b1.copyWith(color: Colors.white),
                  )
                : const Icon(Icons.close, color: Colors.white, size: 26),
          ),
          if (!_isCropping)
            Text(
              '${_currentIndex + 1} / ${widget.selectedAssets.length}',
              style: AppTypography.h3.copyWith(color: Colors.white),
            ),
          // 완료/적용 버튼
          GestureDetector(
            onTap: () {
              if (_isCropping) {
                _cropController.crop(); // 자르기 실행
              } else {
                _returnEditedImages(); // 편집 완료 후 결과 반환
              }
            },
            child: Text(
              _isCropping ? '적용' : '완료',
              style: AppTypography.b1.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 자르기 기능 위젯
  Widget _buildCropWidget() {
    if (_imageDataList[_currentIndex] == null)
      return const Center(child: CircularProgressIndicator());

    return LayoutBuilder(
      builder: (context, constraints) {
        final double side = constraints.maxWidth - 40;
        final double left = (constraints.maxWidth - side) / 2;
        final double top = (constraints.maxHeight - side) / 2;
        final Rect squareRect = Rect.fromLTWH(left, top, side, side);

        return Crop(
          key: ValueKey(_imageDataList[_currentIndex]),
          image: _imageDataList[_currentIndex]!,
          controller: _cropController,
          onCropped: (result) {
            if (result is CropSuccess) {
              final decoded = img.decodeImage(result.croppedImage);
              setState(() {
                _imageDataList[_currentIndex] = result.croppedImage;
                if (decoded != null) {
                  _imgWidths[_currentIndex] = decoded.width.toDouble();
                  _imgHeights[_currentIndex] = decoded.height.toDouble();
                }
                _isCropping = false;
              });
            }
          },
          aspectRatio: 1 / 1, // 정사각형 고정
          maskColor: Colors.black54,
          radius: 0,
          initialRectBuilder: InitialRectBuilder.withBuilder(
            (viewRect, imageRect) => squareRect,
          ),
          interactive: true,
          fixCropRect: true,
          baseColor: AppColors.black,
        );
      },
    );
  }

  // 2~3장의 이미지를 좌우로 스와이프 위젯
  // ✅ 줌/팬 가능한 미리보기 슬라이더
  Widget _buildImageSlider() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.selectedAssets.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        if (_imageDataList[index] == null) return const SizedBox();

        return LayoutBuilder(
          builder: (context, constraints) {
            final viewport = Size(constraints.maxWidth, constraints.maxHeight);
            _lastViewportSize = viewport;
            final guideRect = _squareGuideRect(viewport, index);

            return ClipRect(
              child: GestureDetector(
                onScaleStart: (details) {
                  _gestureIndex = index;
                  _gestureStartScale = _scales[index];
                  _gestureStartPan = _pans[index];
                  _gestureStartFocal = details.localFocalPoint;
                },
                onScaleUpdate: (details) {
                  if (_gestureIndex != index) return;
                  final newScale = (_gestureStartScale! * details.scale).clamp(
                    1.0,
                    4.0,
                  );
                  final focalDelta =
                      details.localFocalPoint - _gestureStartFocal!;
                  final rawPan = _gestureStartPan! + focalDelta;
                  setState(() {
                    _scales[index] = newScale;
                    _pans[index] = _clampPan(index, rawPan, newScale, viewport);
                  });
                },
                onScaleEnd: (_) {
                  _gestureIndex = null;
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(_pans[index].dx, _pans[index].dy)
                          ..scale(_scales[index]),
                        child: RotatedBox(
                          quarterTurns: _rotationTurns[index],
                          child: Image.memory(
                            _imageDataList[index]!,
                            key: ValueKey(_imageDataList[index]),
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
                        painter: SquareOverlayPainter(guideRect: guideRect),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 32,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const ShapeDecoration(
                          color: AppColors.primaryAble,
                          shape: OvalBorder(
                            side: BorderSide(width: 2, color: Colors.white),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.h3.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 회전, 자르기 버튼
  Widget _buildEditTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSvgButton('assets/images/icons/rotate.svg', '회전', () {
          setState(() {
            _rotationTurns[_currentIndex] =
                (_rotationTurns[_currentIndex] + 1) % 4;
            // ✅ 회전하면 비율이 바뀌므로 줌/팬 리셋
            _scales[_currentIndex] = 1.0;
            _pans[_currentIndex] = Offset.zero;
          });
        }),
        const SizedBox(width: 120),
        _buildSvgButton('assets/images/icons/cut.svg', '자르기', _onCropPressed),
      ],
    );
  }

  // svg 아이콘 + 텍스트 버튼 위젯
  Widget _buildSvgButton(String path, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SvgPicture.asset(
            path,
            width: 32,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // 모든 편집이 완료된 이미지 파일들을 생성하고 이전 화면으로 반환
  // ✅ 완료 시: 모든 사진에 대해 회전 + 줌/팬 크롭을 각각 구워서 저장
  Future<void> _returnEditedImages() async {
    setState(() => _isProcessing = true);

    try {
      List<File> finalFiles = [];
      final tempDir = await getTemporaryDirectory();

      for (int i = 0; i < _imageDataList.length; i++) {
        if (_imageDataList[i] == null) continue;

        await _bakeRotation(i);
        await _bakeZoomPanCrop(i);

        final file = File(
          '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}_$i.png',
        );
        await file.writeAsBytes(_imageDataList[i]!);
        finalFiles.add(file);
      }

      if (mounted) Navigator.pop(context, finalFiles);
    } catch (e) {
      debugPrint('이미지 저장 실패: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        displayToast(context, '이미지 저장 중 오류가 발생했습니다.');
      }
    }
  }
}
