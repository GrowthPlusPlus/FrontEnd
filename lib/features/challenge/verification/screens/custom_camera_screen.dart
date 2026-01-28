// 최초 작성자 : 김채영
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'custom_edit_screen.dart';
import 'package:native_camera_sound/native_camera_sound.dart';
import 'camera_edit_screen.dart';

// 커스텀 카메라 화면
class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0; // 0: 후면, 1: 전면
  bool _isCameraInitialized = false;
  FlashMode _currentFlashMode = FlashMode.off; // 플래시 상태 관리

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // 카메라 초기화 로직
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _onNewCameraSelected(_cameras![_selectedCameraIndex]);
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      // 초기 플래시 모드 설정
      await _controller!.setFlashMode(_currentFlashMode);
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("카메라 초기화 에러: $e");
    }
  }

  // 카메라 전환 (앞/뒤)
  void _toggleCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    _onNewCameraSelected(_cameras![_selectedCameraIndex]);
  }

  // 플래시 모드 (Off -> On)
  void _toggleFlash() async {
    if (_controller == null || !_isCameraInitialized) return;

    // 현재가 꺼져있으면 켜고, 켜져있으면 끄기
    FlashMode nextMode = (_currentFlashMode == FlashMode.off)
        ? FlashMode.always
        : FlashMode.off;

    try {
      await _controller!.setFlashMode(nextMode);
      setState(() => _currentFlashMode = nextMode);

      // 로그로 상태 확인
      debugPrint("플래시 모드 변경: $nextMode");
    } catch (e) {
      debugPrint("플래시 설정 에러: $e");
    }
  }

  // 사진 촬영
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // 촬영 직전 셔터음 재생
      NativeCameraSound.playShutter();

      final XFile photo = await _controller!.takePicture();
      if (!mounted) return;

      // 카메라 전용 편집 화면으로 이동
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraEditScreen(imageFile: File(photo.path)),
        ),
      );

      // 편집 화면에서 '완료'를 눌러 돌아오면 인증 화면으로 데이터 전달
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      debugPrint("사진 촬영 중 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 120),
            _buildCameraPreview(),
            const SizedBox(height: 42),
            _buildBottomControls(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // 상단 바
  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/images/icons/arrow_left.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          Text('카메라', style: AppTypography.h3.copyWith(color: Colors.white)),
          const SizedBox(width: 24), // 대칭
        ],
      ),
    );
  }

  // 카메라 프리뷰 (정사각형)
  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _controller == null) {
      // 화면 너비를 가져와서 로딩 중일 때도 정사각형 영역 유지
      final double screenWidth = MediaQuery.of(context).size.width;
      return Container(
        width: screenWidth,
        height: screenWidth,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // 현재 기기의 화면 너비 가져오기
    final double size = MediaQuery.of(context).size.width;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        //clipBehavior: Clip.antiAlias,
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover, // 이미지가 찌그러지지 않게 꽉 채움
            child: SizedBox(
              width: size,
              // 카메라의 실제 종횡비(aspectRatio)를 반영하여 높이 계산
              height: size / _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
      ),
    );
  }

  // 하단 컨트롤
  Widget _buildBottomControls() {
    return Container(
      width: 307,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 플래시
          GestureDetector(
            onTap: _toggleFlash,
            child: SizedBox(
              width: 32,
              height: 32,
              child: SvgPicture.asset(
                'assets/images/icons/flash.svg',
                colorFilter: ColorFilter.mode(
                  _currentFlashMode == FlashMode.off
                      ? Colors.white.withAlpha(150)
                      : Colors.yellow,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 64),

          // 셔터 버튼
          GestureDetector(
            onTap: _takePicture,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/icons/shutter.svg',
                width: 68,
                height: 68,
              ),
            ),
          ),
          const SizedBox(width: 64),

          // 카메라 전환 아이콘
          GestureDetector(
            onTap: _toggleCamera,
            child: SizedBox(
              width: 32,
              height: 32,
              child: SvgPicture.asset(
                'assets/images/icons/rotate_camera.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
