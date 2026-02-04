// 최초 작성자 : 김채영
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/data/challenge_repository.dart';

import '../../../../shared/widgets/challenge_label.dart';
import '../../../../shared/widgets/challenge_input_box.dart';
import '../../../../shared/widgets/image_source_sheet.dart';
import 'custom_gallery_screen.dart';
import 'custom_camera_screen.dart';
import '../widgets/ai_verification_box.dart';
import '../widgets/verification_tip_box.dart';
import '../widgets/verification_info_box.dart';
import '../widgets/ai_success_box.dart';
import '../widgets/ai_fail_box.dart';
import 'package:haenaem/features/challenge/verification/widgets/reverification_guide_box.dart';
import '../widgets/verification_submit_button.dart';

// 챌린지 인증하기 화면
class ChallengeVerificationPage extends ConsumerStatefulWidget {
  final int challengeId;
  const ChallengeVerificationPage({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeVerificationPage> createState() =>
      _ChallengeVerificationPageState();
}

// 상태 관리를 위한 Enum
enum ImageVerificationStatus { idle, loading, success, fail }

class _ChallengeVerificationPageState
    extends ConsumerState<ChallengeVerificationPage> {
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<File> _cameraImages = []; // 카메라 전용 바구니
  final List<File> _galleryImages = []; // 갤러리 전용 바구니
  final List<AssetEntity> _selectedAssets = []; // 갤러리 체크 상태 유지용

  bool _showShadow = true;
  ImageVerificationStatus _verifyStatus = ImageVerificationStatus.idle;

  // 전체 이미지 리스트
  List<File> get _allImages => [..._cameraImages, ..._galleryImages];

  // 버튼 활성화 조건 : 사진이 1장 이상 있고 텍스트가 있을 때
  bool get _isFormValid =>
      _allImages.isNotEmpty && _contentController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _contentController.addListener(() => setState(() {}));
  }

  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_showShadow) setState(() => _showShadow = false);
    } else {
      if (!_showShadow) setState(() => _showShadow = true);
    }
  }

  // 사진 추가 시트 띄우기
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ImageSourceSheet(
          onSourceSelected: (source) async {
            Navigator.pop(context);
            dynamic result;
            if (source == ImageSource.camera) {
              // 카메라 촬영 플로우
              result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomCameraScreen(),
                ),
              );
            } else {
              result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomGalleryScreen(
                    initialSelectedAssets: _selectedAssets,
                  ),
                ),
              );
            }
            // 결과 처리 함수 호출
            if (result != null) {
              _handleImageResult(result);
            }
          },
        );
      },
    );
  }

  void _handleDeleteImage(int index) {
    setState(() {
      if (index < _cameraImages.length) {
        // 카메라 사진 삭제
        _cameraImages.removeAt(index);
      } else {
        // 갤러리 사진 삭제 (인덱스 보정)
        int galleryIndex = index - _cameraImages.length;
        _galleryImages.removeAt(galleryIndex);
        _selectedAssets.removeAt(galleryIndex); // 갤러리 체크 동기화
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  // 사진 업로드/미리보기
  Widget _buildPhotoUploadBox() {
    return SizedBox(
      height: 100, // 미리보기 영역 높이
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // 통합 리스트 + (3장 미만일 때만) 추가 버튼
        itemCount: _allImages.length + (_allImages.length < 3 ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _allImages.length) {
            return _buildImagePreview(index); // 통합 리스트 인덱스 전달
          } else {
            return _buildAddPhotoButton();
          }
        },
      ),
    );
  }

  // 사진 추가 버튼 (+)
  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray3, width: 1.08),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/icons/plus.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.gray3,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '사진 추가',
              style: AppTypography.c1.copyWith(color: AppColors.gray3),
            ),
          ],
        ),
      ),
    );
  }

  // 이미지 미리보기 (삭제 버튼 포함)
  Widget _buildImagePreview(int index) {
    final images = _allImages;

    if (index >= images.length) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _handleDeleteImage(index), // 스마트 삭제 함수 호출
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 입력창 하단 정보 영역
  Widget _buildInputFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 220,
            height: 18,
            child: Stack(
              children: [
                Positioned(
                  left: -1,
                  top: -3.19,
                  child: Text(
                    '챌린지 목표 달성을 자유롭게 표현해주세요',
                    style: AppTypography.c1.copyWith(color: AppColors.gray3),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${_contentController.text.length}/500',
              textAlign: TextAlign.right,
              style: AppTypography.c1.copyWith(color: AppColors.gray3),
            ),
          ),
        ],
      ),
    );
  }

  // 인증 사진 옆 사진 개수
  Widget _buildDynamicLabel(String label, int count) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8), // 아래 박스와의 간격
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.b3.copyWith(color: AppColors.black)),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: AppTypography.b1.copyWith(color: AppColors.primaryAble),
          ),
        ],
      ),
    );
  }

  // 이미지 검증 로직 함수
  Future<void> _runImageVerification(File file) async {
    setState(() => _verifyStatus = ImageVerificationStatus.loading);

    final repository = ref.read(challengeRepositoryProvider);
    final isSuccess = await repository.verifyImage(file);

    if (mounted) {
      setState(() {
        _verifyStatus = isSuccess
            ? ImageVerificationStatus.success
            : ImageVerificationStatus.fail;
      });
    }
  }

  // 사진 추가 후 검증 호출
  void _handleImageResult(dynamic result) async {
    File? selectedFile;
    if (result is File) {
      selectedFile = result;
      _cameraImages.add(selectedFile);
    } else if (result is Map<String, dynamic>) {
      _selectedAssets.clear();
      _selectedAssets.addAll(result['assets'] as List<AssetEntity>);
      _galleryImages.clear();
      _galleryImages.addAll(result['files'] as List<File>);
      selectedFile = _galleryImages.last;
    }

    if (selectedFile != null) {
      await _runImageVerification(selectedFile);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showCancelDialog(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => _showCancelDialog(context),
            icon: SvgPicture.asset(
              'assets/images/icons/arrow_left.svg',
              width: 24,
              height: 24,
            ),
          ),
          title: Text(
            "챌린지 인증하기",
            style: AppTypography.h3.copyWith(color: AppColors.black),
          ),
          centerTitle: true,
          scrolledUnderElevation: 0,
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDynamicLabel('인증 사진', _allImages.length),
                    _buildPhotoUploadBox(), // 헬퍼 함수 호출
                    const SizedBox(height: 8),

                    // 검증 상태에 따른 박스 교체 로직
                    if (_verifyStatus == ImageVerificationStatus.idle ||
                        _verifyStatus == ImageVerificationStatus.loading)
                      const VerificationInfoBox() // 기본 가이드
                    else if (_verifyStatus == ImageVerificationStatus.success)
                      const AiSuccessBox() // 성공 시 표시
                    else
                      const AiFailBox(), // 실패 시 표시

                    const SizedBox(height: 8),

                    // 실패 여부에 따른 하단 팁 박스 교체 로직
                    _verifyStatus == ImageVerificationStatus.fail
                        ? const ReverificationGuideBox() // 실패 시 재인증 가이드
                        : const VerificationTipBox(), // 평상시/성공 시 팁 박스

                    const SizedBox(height: 16),
                    const ChallengeLabel(label: '인증 내용'),
                    ChallengeInputBox(
                      controller: _contentController,
                      hintText:
                          '오늘의 챌린지를 어떻게 수행했나요?\n\n예시:\n• 아침 7시에 5km 달리기 완료!\n• 오늘도 목표 달성했습니다 💪\n• 점점 더 쉬워지는 것 같아요',
                      height: 176,
                    ),
                    const SizedBox(height: 8),
                    _buildInputFooter(), // 헬퍼 함수 호출
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: VerificationSubmitButton(
          label: '인증하기',
          showShadow: _showShadow,
          onPressed: _isFormValid
              ? () async {
                  // TODO: AI 검증 API를 먼저 호출하여 서버로부터 이미지 URL들을 받아와야 함
                  // List<String> verifiedUrls = await ref.read(verifyProvider).upload(_allImages);

                  // 인증글 생성 API 호출
                  final success = await ref
                      .read(articleCreateNotifierProvider.notifier)
                      .submitArticle(
                        challengeId: widget.challengeId,
                        content: _contentController.text,
                        verifiedImageUrls: [], // 여기에 실제 검증 완료된 URL 리스트가 들어가야 함
                      );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('인증글이 성공적으로 등록되었습니다!')),
                    );

                    // 성공 시 인증글(피드) 화면으로 이동하거나,
                    // 현재 화면을 닫아서 캘린더로 돌아감.
                    Navigator.pop(context);
                  }
                }
              : null, // 폼이 유효하지 않으면 버튼 비활성화
        ),
      ),
    );
  }
}

// 뒤로 가기 아이콘을 누르거나 시스템 바의 뒤로가기를 누를 경우 뜨는 안내 모달
void _showCancelDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: const Color(0x7F1A1D1B),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Text(
                '작성을 취소하시겠어요?',
                style: AppTypography.h3.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: 8),
              Text(
                '지금 나가면 작성 중인 내용은 저장되지 않고 모두 삭제됩니다.',
                textAlign: TextAlign.center,
                style: AppTypography.b1.copyWith(color: AppColors.gray2),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.gray5,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '계속 작성하기',
                          textAlign: TextAlign.center,
                          style: AppTypography.b1.copyWith(
                            color: AppColors.gray2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.gray5,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '작성 취소',
                          textAlign: TextAlign.center,
                          style: AppTypography.b1.copyWith(
                            color: AppColors.notification,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
