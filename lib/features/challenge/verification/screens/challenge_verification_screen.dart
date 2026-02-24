// 최초 작성자 : 김채영
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/model/image_model.dart';
import 'package:intl/intl.dart';

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
import 'package:haenaem/features/challenge/widgets/verification_cancel_dialog.dart';
import 'package:haenaem/features/feed/model/feed_model.dart';

// 챌린지 인증하기 화면
class ChallengeVerificationScreen extends ConsumerStatefulWidget {
  final int challengeId;
  final CertificationPostModel? existingPost; // 데이터가 있으면 수정 모드

  const ChallengeVerificationScreen({
    super.key,
    required this.challengeId,
    this.existingPost,
  });

  @override
  ConsumerState<ChallengeVerificationScreen> createState() =>
      _ChallengeVerificationScreenState();
}

// 상태 관리를 위한 Enum
enum ImageVerificationStatus { idle, loading, success, fail }

class _ChallengeVerificationScreenState
    extends ConsumerState<ChallengeVerificationScreen> {
  late TextEditingController _contentController;
  final List<File> _cameraImages = []; // 카메라 전용 바구니
  final List<File> _galleryImages = []; // 갤러리 전용 바구니
  final List<AssetEntity> _selectedAssets = []; // 갤러리 체크 상태 유지용

  // 기존 이미지 관리용 (수정 모드 전용)
  late List<dynamic> _existingImages;
  final List<int> _imageIdsToDelete = [];

  final ScrollController _scrollController = ScrollController();
  ImageVerificationStatus _verifyStatus = ImageVerificationStatus.idle;
  bool _showShadow = true;

  bool get isEditMode => widget.existingPost != null;
  List<File> get _newImages => [..._cameraImages, ..._galleryImages];
  List<File> get _allImages => [..._cameraImages, ..._galleryImages];

  // 버튼 활성화 조건
  // 생성: 사진 1장 이상 + 텍스트 필수
  // 수정: (기존사진 - 삭제예정 + 새사진)이 1장 이상 + 텍스트 필수
  bool get _isFormValid {
    // 1. 챌린지 상세 정보를 구독 (Named Parameter 사용)
    final challengeDetail = ref.watch(
      challengeDetailProvider(challengeId: widget.challengeId),
    );

    // 2. 사진 필수 여부 파악 (데이터 로딩 전에는 기본값 true로 설정하여 방어)
    final bool isPhotoRequired = challengeDetail.value?.photoRequired ?? true;

    // 3. 사진 및 텍스트 상태 계산
    final int existingCount = widget.existingPost?.images.length ?? 0;
    final int activeExistingCount = existingCount - _imageIdsToDelete.length;
    final int totalPhotos = activeExistingCount + _newImages.length;
    final bool isContentNotEmpty = _contentController.text.trim().isNotEmpty;

    if (isPhotoRequired) {
      // 📸 사진 필수: 사진 1장 이상 AND 텍스트 필수
      return totalPhotos > 0 && isContentNotEmpty;
    } else {
      // ✍️ 사진 자유: 사진 0장이어도 텍스트만 있으면 활성화
      return isContentNotEmpty;
    }
  }

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: isEditMode ? widget.existingPost!.content : '',
    );
    // 기존 이미지 데이터 초기화
    _existingImages = isEditMode ? List.from(widget.existingPost!.images) : [];

    _scrollController.addListener(_onScroll);
    _contentController.addListener(() => setState(() {})); // 글자수 실시간 반영
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
  // TODO: 백엔드 api 수정 중이라서 임시 성공 처리
  Future<void> _runImageVerification(File file) async {
    setState(() => _verifyStatus = ImageVerificationStatus.loading);

    // 실제 리포지토리 호출 주석 처리
    // final repository = ref.read(challengeRepositoryProvider);
    // final isSuccess = await repository.verifyImage(file);

    // ⏳ AI가 열심히 사진을 분석하는 척 2초간 대기합니다.
    await Future.delayed(const Duration(seconds: 2));

    // 💡 무조건 성공으로 설정
    const isSuccess = true;

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

  Widget _buildStatusBox() {
    // 사진이 한 장도 없는 경우 -> 검증 UI를 아예 보여주지 않고 가이드만 노출
    if (_allImages.isEmpty) {
      return const Column(
        children: [
          VerificationInfoBox(),
          SizedBox(height: 8),
          VerificationTipBox(),
        ],
      );
    }

    Widget mainBox; // 상단 박스
    Widget subBox; // 하단 박스

    switch (_verifyStatus) {
      case ImageVerificationStatus.loading:
        mainBox = const AiVerificationBox();
        subBox = const VerificationTipBox();
        break;
      case ImageVerificationStatus.success:
        mainBox = const AiSuccessBox();
        subBox = const VerificationTipBox();
        break;
      case ImageVerificationStatus.fail:
        mainBox = const AiFailBox();
        subBox = const ReverificationGuideBox();
        break;
      default:
        mainBox = const VerificationInfoBox();
        subBox = const VerificationTipBox();
    }

    return Column(
      children: [
        mainBox,
        const SizedBox(height: 8), // 두 박스 사이 간격
        subBox,
      ],
    );
  }

  // 기존 이미지 리스트 UI (수정 모드일 때만 호출)
  Widget _buildExistingImagesList() {
    // articleImageUrl이 String 리스트이므로 인덱스로 관리하거나 ID가 필요함
    // 만약 post.images 객체 리스트가 있다면 ID 추출이 가능합니다.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDynamicLabel(
          '기존 인증 사진',
          _existingImages.length - _imageIdsToDelete.length,
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _existingImages.length,
            itemBuilder: (context, index) {
              final PostImage image = _existingImages[index];
              final int realImageId = image.imageId; // ID 추출

              if (_imageIdsToDelete.contains(realImageId))
                return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _imageIdsToDelete.add(realImageId)),
                        child: _buildDeleteIcon(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDeleteIcon() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.close, size: 16, color: Colors.white),
    );
  }

  // 인증글 공통 팝업 호출 로직 (작성 취소할 경우, 수정 취소할 경우)
  void _handleBackAction() async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x7F1A1D1B),
      builder: (context) => VerificationCancelDialog(
        title: isEditMode ? '수정을 취소하시겠어요?' : '작성을 취소하시겠어요?',
        message: isEditMode
            ? '지금 나가면 수정 중인 내용은\n저장되지 않고 삭제됩니다.'
            : '지금 나가면 작성 중인 내용은\n저장되지 않고 삭제됩니다.',
        cancelLabel: isEditMode ? '수정 취소' : '작성 취소',
      ),
    );

    // 팝업에서 나감을 선택했을 경우에만 이전 화면으로 이동
    if (shouldExit == true && mounted) {
      // 단순히 뒤로 가는 경우라면 Navigator.pop(context),
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackAction();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _handleBackAction,
            icon: SvgPicture.asset(
              'assets/images/icons/arrow_left.svg',
              width: 24,
              height: 24,
            ),
          ),
          title: Text(
            isEditMode ? '인증글 수정' : '챌린지 인증하기',
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
                    if (isEditMode && _existingImages.isNotEmpty)
                      _buildExistingImagesList(),
                    _buildDynamicLabel(
                      isEditMode ? '새 사진 추가' : '인증 사진',
                      _newImages.length,
                    ),
                    _buildPhotoUploadBox(), // 헬퍼 함수 호출
                    const SizedBox(height: 8),

                    // 검증 상태에 따른 박스 로직
                    _buildStatusBox(),

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
        // 하단 버튼 통합
        bottomNavigationBar: VerificationSubmitButton(
          label: isEditMode ? '수정하기' : '인증하기',
          showShadow: _showShadow,
          onPressed: _isFormValid ? _onSave : null,
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final now = DateTime.now();
    bool success = false;
    final content = _contentController.text.trim();

    try {
      if (isEditMode) {
        success = await ref
            .read(articleUpdateNotifierProvider.notifier)
            .editArticle(
              postId: widget.existingPost!.postId,
              content: content,
              deleteImageIds: _imageIdsToDelete,
              newImages: _newImages,
            );
      } else {
        success = await ref
            .read(articleCreateNotifierProvider.notifier)
            .submitArticle(
              challengeId: widget.challengeId,
              content: content,
              imageFiles: _newImages,
            );
      }
    } catch (e) {
      debugPrint('❌ 인증 저장 중 오류 발생: $e');
      success = false;
    }

    if (success && mounted) {
      // 💡 [에러 해결] 이 프로바이더만 이름 없이 숫자만 넣습니다 (Positional)
      ref.invalidate(challengeCalendarDataProvider(widget.challengeId));

      // 💡 아래 프로바이더들은 정의된 대로 이름을 명시합니다 (Named)
      ref.invalidate(
        challengeCalendarPhotosProvider(
          challengeId: widget.challengeId,
          year: now.year,
          month: now.month,
        ),
      );
      ref.invalidate(
        challengePostsProvider(
          challengeId: widget.challengeId,
          year: now.year,
          month: now.month,
        ),
      );

      ref.invalidate(challengeHomeNotifierProvider);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(isEditMode ? '수정 완료!' : '인증 완료!')));

      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('인증에 실패했습니다. 다시 시도해주세요.')));
    }
  }
}
