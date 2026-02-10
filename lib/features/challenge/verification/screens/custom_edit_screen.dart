// 최초 작성자 : 김채영
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:image/image.dart' as img;

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

  late List<int> _rotationTurns; // 각 이미지별 회전 각도
  late List<Uint8List?> _imageDataList; // 로드된 원본 이미지 데이터 리스트

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _rotationTurns = List.generate(widget.selectedAssets.length, (_) => 0);
    _imageDataList = List.generate(widget.selectedAssets.length, (_) => null);
    _loadAllImageData();
  }

  Future<void> _loadAllImageData() async {
    for (int i = 0; i < widget.selectedAssets.length; i++) {
      final bytes = await widget.selectedAssets[i].originBytes;
      if (mounted) setState(() => _imageDataList[i] = bytes);
    }
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
              // 자르기 모드 여부에 따라 다른 위젯 표시
              child: _isCropping ? _buildCropWidget() : _buildImageSlider(),
            ),
            const Spacer(),
            // 자르기 모드가 아닐 때만 하단 편집 도구 표시
            if (!_isCropping) _buildEditTools(),
            const SizedBox(height: 20),
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
            child: Text(
              _isCropping ? '취소' : '×',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
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
              style: AppTypography.b1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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

    return Crop(
      image: _imageDataList[_currentIndex]!,
      controller: _cropController,

      onCropped: (result) {
        if (result is CropSuccess) {
          setState(() {
            _imageDataList[_currentIndex] = result.croppedImage; // 잘린 이미지로 교체
            _isCropping = false; // 자르기 모드 종료
          });
        }
      },

      maskColor: Colors.black54,
      radius: 12,
      interactive: true,
      fixCropRect: false,
    );
  }

  // 2~3장의 이미지를 좌우로 스와이프 위젯
  Widget _buildImageSlider() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.selectedAssets.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            if (_imageDataList[index] == null) return const SizedBox();
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RotatedBox(
                    quarterTurns: _rotationTurns[index],
                    child: Image.memory(
                      _imageDataList[index]!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // 현재 이미지 번호 표시
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
              '${_currentIndex + 1}',
              style: AppTypography.h3.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // 회전, 자르기 버튼
  Widget _buildEditTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSvgButton('assets/images/icons/rotate.svg', '회전', () {
          setState(
            () => _rotationTurns[_currentIndex] =
                (_rotationTurns[_currentIndex] + 1) % 4,
          );
        }),
        const SizedBox(width: 120),
        _buildSvgButton('assets/images/icons/cut.svg', '자르기', () {
          setState(() => _isCropping = true);
        }),
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
  Future<void> _returnEditedImages() async {
    List<File> finalFiles = [];
    final tempDir = await getTemporaryDirectory();

    for (int i = 0; i < _imageDataList.length; i++) {
      if (_imageDataList[i] != null) {
        Uint8List currentData = _imageDataList[i]!;

        // 각 이미지의 회전 값 적용
        if (_rotationTurns[i] != 0) {
          currentData = rotateImageBytes(currentData, _rotationTurns[i]);
        }

        // 임시 파일로 저장
        final file = File(
          '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}_$i.png',
        );
        await file.writeAsBytes(currentData); // 수정된 데이터 저장
        finalFiles.add(file);
      }
    }
    if (mounted) Navigator.pop(context, finalFiles);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// 이미지 바이트와 회전 횟수를 받아 회전된 바이트를 반환
// TODO: camera edit screen에도 있는 함수. 리팩토링 필요.
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
