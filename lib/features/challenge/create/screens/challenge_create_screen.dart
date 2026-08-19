// 최초 작성자 : 김채영
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/shared/models/tag_model.dart';
// import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
// import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/user/provider/my_challenge_provider.dart';
import 'package:haenaem/shared/provider/home_provider.dart';
import '../provider/create_provider.dart';
// import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
// import 'package:haenaem/features/challenge/models/challenge_model.dart';
import 'dart:convert';

import '../../../../shared/widgets/challenge_label.dart';
import '../../../../shared/widgets/challenge_input_box.dart';
import 'package:haenaem/shared/widgets/app_tag_chip.dart';
import 'package:haenaem/features/challenge/create/widgets/ai_notice_box.dart';
// import 'package:haenaem/features/challenge/create/widgets/plus_button.dart';
// import 'package:haenaem/features/challenge/create/widgets/challenge_select_button.dart';
import 'package:haenaem/shared/widgets/bottom_action_button.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_calendar_bottom_sheet.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_duration_bottom_sheet.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_frequency_bottom_sheet.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_tag_bottom_sheet.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_visibility_selector.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_type_selector.dart';
import 'package:haenaem/features/challenge/detail/screens/challenge_main_screen.dart';
import 'package:haenaem/shared/widgets/animated_toast.dart';
import 'package:haenaem/features/challenge/create/provider/challenge_preview_provider.dart';

// -- 챌린지 생성 화면 --
class ChallengeCreateScreen extends ConsumerStatefulWidget {
  const ChallengeCreateScreen({super.key});

  @override
  ConsumerState<ChallengeCreateScreen> createState() =>
      _ChallengeCreateScreenState();
}

class _ChallengeCreateScreenState extends ConsumerState<ChallengeCreateScreen> {
  final List<ChallengeTagModel> _selectedTagModels = []; // 선택된 태그를 모델 리스트로 관리
  int selectedType = 0; // 현재 선택된 방식을 저장 (0: 미선택, 1: 사진 필수, 2: 체크 자유)
  int selectedVisibility = 2; // 1: 비공개, 2: 공개(기본값), 3: 친구 공개

  // AI 사진 검증 사전 안내용 상태
  bool? _autoVerifiable; // null: 미검사, true/false: 검사 결과
  bool _isCheckingPreview = false;

  // 스크롤 제어를 위한 컨트롤러 추가 - 사진 첨부 필수 버튼을 누르면 notice가 뿅 나타나게
  final ScrollController _scrollController = ScrollController();

  // 그림자 표시 여부 (끝까지 내리면 그림자 없어지게)
  bool _showShadow = true;

  // 날짜 상태 관리를 위한 변수
  late DateTime _focusedDay; // 현재 기준일 (2026년)
  DateTime? _selectedDay; // 사용자가 선택한 날
  String _dateHintText = '연도-월-일'; // 박스에 표시될 텍스트
  final DateTime _today = DateTime.now();

  // 선택된 값들을 저장할 상태 변수
  String? _selectedDuration = '30일'; // 인증 기간 (기본값: 30일)
  String? _selectedFrequency; // 인증 빈도

  bool _isSubmitting = false;

  // 인증 기간 직접 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Timer? _debounceTimer;

  // 모든 조건이 충족되었는지 확인
  bool get _isFormValid {
    // 사진 필수 선택 + AI 이름 검사가 진행 중이면, 아직 최종 결과를 못 봤으니 버튼 잠금
    final bool blockedByPreviewCheck = selectedType == 1 && _isCheckingPreview;

    // 사진 필수 선택 + 이름 검사 결과가 "판별 어려움(false)"이면 생성 자체를 막음
    final bool blockedByUnsupportedName =
        selectedType == 1 && _autoVerifiable == false;

    return _nameController.text.trim().isNotEmpty && // 이름 입력
        _selectedDay != null && // 시작일 선택
        _selectedDuration != null && // 기간 선택
        _selectedFrequency != null && // 빈도 선택됨
        _selectedTagModels.isNotEmpty && // 태그
        _descriptionController.text.trim().isNotEmpty && // 설명 입력
        selectedType != 0 && // 인증 방식 선택
        selectedVisibility != 0 && // 공개범위 선택
        !blockedByPreviewCheck && // AI 검사 진행 중이면 버튼 잠금
        !blockedByUnsupportedName; // AI 검사 결과가 false면 버튼 잠금
  }

  // 상태 초기화
  @override
  void initState() {
    super.initState();

    _focusedDay = _today;
    _selectedDay = _today;
    _dateHintText =
        "${_today.year}-${_today.month.toString().padLeft(2, '0')}-${_today.day.toString().padLeft(2, '0')}";

    _scrollController.addListener(_onScroll); // 스크롤 리스너 추가

    // 텍스트 입력 시마다 버튼 활성화 여부 판단 + (사진 필수 선택 시) 이름 재검사
    _nameController.addListener(_onNameChanged);
    _descriptionController.addListener(_updateState);
  }

  // 상태 업데이트 함수
  void _updateState() {
    setState(() {});
  }

  // 리스너 제거 및 해제
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {}); // 기존처럼 _isFormValid 즉시 반영

    // 사진 필수가 선택된 상태에서만 재검사 (디바운스)
    if (selectedType == 1) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 700), () {
        _checkAutoVerifiable();
      });
    }
  }

  int _previewRequestId = 0; // 요청 순번 추적용 (같은 제목이라도 최신 요청만 반영하기 위함)

  // 사진 첨부 필수를 선택했을 때, 현재 입력된 이름으로 AI 판별 난이도 사전 안내 조회
  Future<void> _checkAutoVerifiable() async {
    final title = _nameController.text.trim();
    if (title.isEmpty) {
      setState(() => _autoVerifiable = null);
      return;
    }

    final int requestId = ++_previewRequestId; // 이 호출만의 고유 순번 부여

    setState(() => _isCheckingPreview = true);
    try {
      final result = await ref
          .read(challengePreviewNotifierProvider.notifier)
          .checkTitle(title);

      debugPrint(
        '🔍 [AI Notice] title: "$title" → autoVerifiable: ${result.autoVerifiable}, category: ${result.category}',
      );

      // 내가 보낸 이후에 더 최신 요청이 나갔다면, 내 응답은 무시
      if (requestId != _previewRequestId) {
        debugPrint('🔍 [AI Notice] "$title" (id=$requestId) 응답은 낡은 요청이라 무시');
        return;
      }

      if (mounted) setState(() => _autoVerifiable = result.autoVerifiable);
    } catch (e) {
      debugPrint('🔍 [AI Notice] 검사 실패: $e');
      // 사전 검사 실패는 안내를 못 보여줄 뿐, 생성 흐름에는 영향 없음
      if (mounted) setState(() => _autoVerifiable = null);
    } finally {
      if (mounted) setState(() => _isCheckingPreview = false);
    }
  }

  Map<String, dynamic> _buildRequestData() {
    final int duration =
        int.tryParse(_selectedDuration?.replaceAll('일', '') ?? '0') ?? 0;

    int frequency = 7;
    if (_selectedFrequency != "매일") {
      frequency =
          int.tryParse(
            _selectedFrequency?.replaceAll(RegExp(r'[^0-9]'), '') ?? '7',
          ) ??
          7;
    }

    return {
      "title": _nameController.text.trim(),
      "startDate": _selectedDay != null
          ? "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}"
          : "",
      "duration": duration,
      "frequency": frequency,
      "tags": _selectedTagModels.map((t) => t.id).toList(),
      "description": _descriptionController.text.trim(),
      "photoRequired": selectedType == 1,
      "challengeVisibility": selectedVisibility == 1
          ? "PRIVATE"
          : (selectedVisibility == 2 ? "PUBLIC" : "FRIENDS_ONLY"),
      "maxParticipantNumber": 50,
    };
  }

  // 챌린지 생성 데이터 제출 준비 로직
  void _submitChallenge() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      // 1️⃣ AI 사진 검증 관련 로직은 AiNoticeBox에서 이미 안내 완료 (여기선 호출 X)

      // 2️⃣ 기존 챌린지 생성 로직
      final requestData = _buildRequestData();
      debugPrint('🚀 서버 전송 데이터: ${jsonEncode(requestData)}');

      final notifier = ref.read(challengeCreateNotifierProvider.notifier);
      final response = await notifier.create(requestData);

      if (response != null && mounted) {
        debugPrint('✅ 생성된 실제 ID: ${response.id}');
        ref.read(homeNotifierProvider.notifier).refresh();
        ref.invalidate(myInProgressChallengesProvider);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeMainScreen(
              challengeId: response.id,
              challengeTitle: response.title,
              challengeLink: response.challengeLink,
              isJustCreated: true,
            ),
          ),
        );
      } else if (mounted) {
        displayToast(context, '챌린지 생성 중 오류가 발생했습니다.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // 스크롤 감지 함수
  void _onScroll() {
    // 현재 스크롤 위치가 최대치(바닥)에 도달했는지 확인
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_showShadow) setState(() => _showShadow = false);
    } else {
      if (!_showShadow) setState(() => _showShadow = true);
    }
  }

  // 챌린지 시작일 탭
  void _showCalendarBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChallengeCalendarBottomSheet(
        initialFocusedDay: _focusedDay,
        initialSelectedDay: _selectedDay,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _dateHintText =
                "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
          });
        },
      ),
    );
  }

  // 인증 기간 탭
  void showDurationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChallengeDurationBottomSheet(
        initialDuration: _selectedDuration,
        onDurationSelected: (duration) {
          setState(() => _selectedDuration = duration);
        },
      ),
    );
  }

  // 인증 빈도 탭
  void showFrequencyBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ChallengeFrequencyBottomSheet(
        selectedFrequency: _selectedFrequency,
        onFrequencySelected: (frequency) {
          setState(() => _selectedFrequency = frequency);
        },
      ),
    );
  }

  // 챌린지 태그 선택 시트 호출
  void showChallengeTagBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChallengeTagBottomSheet(
        initialSelectedTags: _selectedTagModels,
        onCompleted: (selectedTags) {
          setState(() {
            _selectedTagModels.clear();
            _selectedTagModels.addAll(selectedTags);
          });
        },
      ),
    );
  }

  // 선택된 챌린지 태그 목록 표시
  Widget buildSelectedTags() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: _selectedTagModels
            .map(
              (tagModel) => AppTagChip(
                // 💡 tagModel로 명시
                label: tagModel.tag,
                isSelected: false,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: AppBar(
        // 뒤로 가기 버튼
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              appColors.blackToWhite,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(
          "챌린지 만들기",
          style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: appColors.whiteToBlack,
        backgroundColor: appColors.whiteToBlack,
      ),

      // 입력 폼
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // 아이콘 위치와 정렬
        child: SingleChildScrollView(
          // 입력 항목이 많아질 것을 대비해 스크롤 추가

          // 컨트롤러 연결
          controller: _scrollController,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ChallengeLabel(label: '챌린지 이름'),
              ChallengeInputBox(
                controller: _nameController, // 연결
                hintText: '어떤 챌린지를 시작해볼까요?',
              ),

              const SizedBox(height: 16),

              ChallengeTypeSelector(
                selectedType: selectedType,
                autoVerifiable: _autoVerifiable,
                isCheckingPreview: _isCheckingPreview,
                onChanged: (type) {
                  setState(() => selectedType = type);

                  // 사진 첨부 필수를 눌렀을 때
                  if (type == 1) {
                    _debounceTimer?.cancel(); // 대기 중이던 디바운스 요청 취소
                    _checkAutoVerifiable(); // 즉시 1번만 호출
                  }
                },
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '챌린지 시작일'),
              ChallengeInputBox(
                leadingIconPath: 'assets/images/icons/calendar.svg',
                hintText: _dateHintText,
                // 선택된 날짜가 없으면 gray3, 날짜가 선택되면 black으로 설정
                textColor: _selectedDay == null
                    ? appColors.gray3
                    : appColors.blackToWhite,
                iconPath: 'assets/images/icons/big_down_arrow.svg',
                onTap: _showCalendarBottomSheet,
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '인증 기간'),
              ChallengeInputBox(
                hintText: _selectedDuration ?? '얼마나 해내볼까요?',
                textColor: _selectedDuration == null
                    ? appColors.gray3
                    : appColors.blackToWhite,
                iconPath: 'assets/images/icons/big_down_arrow.svg',
                onTap: showDurationBottomSheet,
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '인증 빈도'),
              ChallengeInputBox(
                hintText: _selectedFrequency ?? '얼마나 자주 인증할까요?',
                textColor: _selectedFrequency == null
                    ? appColors.gray3
                    : appColors.blackToWhite,
                iconPath: 'assets/images/icons/big_down_arrow.svg',
                onTap: showFrequencyBottomSheet,
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '챌린지 태그'),
              ChallengeInputBox(
                hintText: '어떤 주제와 어울릴까요?',
                iconPath: 'assets/images/icons/big_down_arrow.svg',
                onTap: showChallengeTagBottomSheet,
                tag: _selectedTagModels.isEmpty ? null : buildSelectedTags(),
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '챌린지 설명'),
              ChallengeInputBox(
                controller: _descriptionController,
                hintText: '예: 오전 6시~8시 사이 운동 인증샷 업로드',
                height: 139,
              ),

              const SizedBox(height: 16),

              // 챌린지 공개 범위
              ChallengeVisibilitySelector(
                selectedVisibility: selectedVisibility,
                onChanged: (value) =>
                    setState(() => selectedVisibility = value),
              ),
              const SizedBox(height: 26),
            ],
          ),
        ),
      ),

      // 하단 버튼 배치
      bottomNavigationBar: BottomActionButton(
        text: '만들기',
        onPressed: (_isFormValid && !_isSubmitting)
            ? () {
                _submitChallenge();
              }
            : null,
      ),
    );
  }
}
