// 최초 작성자 : 김채영
// 최초 작성자 : 김채영, 리팩토링: 정승빈
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:haenaem/features/user/models/user_model.dart';
import 'package:haenaem/shared/models/tag_data.dart';
import 'package:haenaem/shared/widgets/app_tag_chip.dart';
import 'package:haenaem/shared/widgets/image_source_sheet.dart';
import '../../../../shared/widgets/bottom_action_button.dart';
import 'package:haenaem/features/auth/signup/screens/profile_image_edit_screen.dart';
import '../widgets/profile_image_menu.dart';
import '../provider/tag_provider.dart';
import '../provider/user_profile_provider.dart';

// 프로필 편집 화면
class ProfileEditScreen extends ConsumerStatefulWidget {
  final UserProfileModel profile;
  const ProfileEditScreen({super.key, required this.profile});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _introController;
  bool _showImageMenu = false; // 이미지 관리 메뉴 노출 상태
  File? _selectedImageFile;
  bool _isImageDeleted = false; // 이미지 삭제 여부를 추적하는 상태
  final ImagePicker _picker = ImagePicker();
  bool _isDuplicate = false;
  bool _isInvalidFormat = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.profile.nickname);
    _introController = TextEditingController(text: widget.profile.introduction);

    _nicknameController.addListener(_validateNickname);
    _introController.addListener(() => setState(() {}));

    // 화면 진입 시 tagProvider 초기화 호출
    Future.microtask(() => ref.read(tagProvider.notifier).initialize());
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _introController.dispose();
    super.dispose();
  }

  // --- 이미지 소스 선택 (카메라/갤러리) ---
  void _showImageSourceSheet() {
    setState(() => _showImageMenu = false); // 팝업 메뉴 닫기
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ImageSourceSheet(onSourceSelected: (source) => _getImage(source)),
    );
  }

  // --- 이미지 가져오기 및 편집 화면 이동 ---
  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null && mounted) {
      Navigator.pop(context); // 시트 닫기

      // 편집 화면(Crop)으로 이동
      final File? editedFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProfileImageEditScreen(imageFile: File(pickedFile.path)),
        ),
      );

      if (editedFile != null) {
        setState(() {
          _selectedImageFile = editedFile;
          _isImageDeleted = false; // 새 이미지를 골랐으므로 삭제 상태 해제
        });
      }
    }
  }

  // --- 💡 이미지 삭제: 로직을 Provider로 위임 ---
  Future<void> _handleDeleteImage() async {
    try {
      await ref.read(userProfileProvider.notifier).deleteProfileImage();
      setState(() {
        _selectedImageFile = null;
        _isImageDeleted = true;
        _showImageMenu = false;
      });
    } catch (e) {
      debugPrint('삭제 실패: $e');
    }
  }

  // 닉네임 실시간 유효성 검사
  void _validateNickname() {
    final text = _nicknameController.text;
    setState(() {
      if (text.isEmpty) {
        _isInvalidFormat = false;
      } else {
        // 한글, 영문, 숫자, 마침표(.), 언더바(_), 하이픈(-) 1~15자
        final regExp = RegExp(r'^[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣._-]{1,15}$');
        _isInvalidFormat = !regExp.hasMatch(text);
      }
      if (_isDuplicate) _isDuplicate = false; // 입력 시작 시 중복 에러 초기화
    });
  }

  // --- 💡 최종 저장: 복잡한 API 호출을 모두 Provider로 위임 ---
  Future<void> _handleSave() async {
    try {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(
            currentNickname: widget.profile.nickname,
            newNickname: _nicknameController.text,
            currentIntro: widget.profile.introduction,
            newIntro: _introController.text,
            newImageFile: _selectedImageFile,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('프로필 수정이 완료되었습니다.')));
      }
    } catch (e) {
      final errorMsg = e.toString();
      // 닉네임 중복 에러 처리
      if (errorMsg.contains('DUPLICATE')) {
        setState(() => _isDuplicate = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagState = ref.watch(tagProvider);
    final profileEditState = ref.watch(userProfileProvider); // 💡 프로필 저장 상태 구독

    final selectedTagsFromProvider = tagState.tags;
    final bool isNicknameValid =
        _nicknameController.text.isNotEmpty && !_isInvalidFormat;

    // 💡 Provider가 작업 중(loading)일 때는 저장 버튼을 비활성화하여 중복 터치 방지
    final bool isEnabled =
        isNicknameValid &&
        selectedTagsFromProvider.length >= 2 &&
        selectedTagsFromProvider.length <= 6 &&
        !tagState.isLoading &&
        !profileEditState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildProfileImageSection(),
                            const SizedBox(height: 40),
                            _buildNicknameSection(),
                            const SizedBox(height: 10),
                            _buildTextFieldSection(
                              label: '한 줄 소개',
                              controller: _introController,
                              maxLength: 50,
                            ),
                            const SizedBox(height: 10),
                            _buildTagSection(),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),

                      if (_showImageMenu) ...[
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () => setState(() => _showImageMenu = false),
                            behavior: HitTestBehavior.translucent,
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        Positioned(
                          top: 180,
                          right: 30,
                          child: ProfileImageMenu(
                            onChangePressed: _showImageSourceSheet,
                            onDeletePressed: _handleDeleteImage,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomActionButton(
              text: '수정사항 저장하기',
              backgroundColor: isEnabled
                  ? AppColors.primaryAble
                  : AppColors.disable,
              onPressed: isEnabled ? _handleSave : () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFDFE1DC),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _isImageDeleted
                    ? SvgPicture.asset(
                        'assets/images/placeholders/default_profile.svg',
                      ) // 1순위: 삭제됨
                    : _selectedImageFile != null
                    ? Image.file(_selectedImageFile!, fit: BoxFit.cover)
                    // 2순위: 새로 고름
                    : widget.profile.profileImageUrl.isNotEmpty
                    ? Image.network(
                        widget.profile.profileImageUrl,
                        fit: BoxFit.cover,
                      ) // 3순위: 기존 이미지
                    : SvgPicture.asset(
                        'assets/images/placeholders/default_profile.svg',
                      ), // 4순위: 기본값
              ),
            ),
            Positioned(
              left: 105,
              top: 105,
              child: InkWell(
                onTap: () => setState(() => _showImageMenu = !_showImageMenu),
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: SvgPicture.asset(
                    'assets/images/icons/profile_settings.svg',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNicknameSection() {
    String? errorMessage;
    if (_isInvalidFormat) {
      errorMessage = '마침표(.), 언더바(_), 하이픈(-) 외의 특수문자나 띄어쓰기는 포함할 수 없어요';
    } else if (_isDuplicate) {
      errorMessage = '중복된 닉네임이에요';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('닉네임', style: AppTypography.b3.copyWith(color: AppColors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: _nicknameController,
          maxLength: 15,
          decoration: InputDecoration(
            counterText: "",
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorMessage != null
                    ? AppColors.notification
                    : AppColors.gray4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorMessage != null
                    ? AppColors.notification
                    : AppColors.primaryAble,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: errorMessage != null
                  ? Text(
                      '* $errorMessage',
                      style: AppTypography.c1.copyWith(
                        color: AppColors.notification,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Text(
              '${_nicknameController.text.length}/15',
              style: AppTypography.c1.copyWith(color: AppColors.gray2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFieldSection({
    required String label,
    required TextEditingController controller,
    required int maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.b3.copyWith(color: AppColors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: maxLength,
          decoration: InputDecoration(
            counterText: "",
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryAble),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${controller.text.length}/$maxLength',
            style: AppTypography.c1.copyWith(color: AppColors.gray2),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSection() {
    final selectedTags = ref.watch(tagProvider).tags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관심 태그 (2~6개 선택)',
          style: AppTypography.b3.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 16),
        ...TagMapper.categoryOrder.map((engCategory) {
          final korCategory = TagMapper.getKoreanCategory(engCategory);
          final tagsInCat = TagMapper.tagInternalOrder[engCategory] ?? [];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  korCategory,
                  style: AppTypography.b2.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: tagsInCat
                      .map(
                        (tag) => AppTagChip(
                          label: tag,
                          isSelected: selectedTags.contains(tag),
                          onTap: () => _toggleTag(tag),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _toggleTag(String tag) {
    ref.read(tagProvider.notifier).toggleTag(tag);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/images/icons/arrow_left.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        '프로필 편집',
        style: AppTypography.h3.copyWith(color: AppColors.black),
      ),
    );
  }
}
