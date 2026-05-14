// 최초 작성자 : 김채영
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
// import 'package:haenaem/features/challenge/create/widgets/ai_notice_box.dart';
import 'package:haenaem/features/challenge/create/widgets/plus_button.dart';
// import 'package:haenaem/features/challenge/create/widgets/challenge_select_button.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_calendar_bottom_sheet.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_duration_bottom_sheet.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_frequency_bottom_sheet.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_tag_bottom_sheet.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_visibility_selector.dart';
import 'package:haenaem/features/challenge/create/widgets/challenge_type_selector.dart';
import 'package:haenaem/features/challenge/detail/screens/challenge_main_screen.dart';

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
  int selectedVisibility = 0; // 1: 비공개, 2: 공개, 3: 친구 공개

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
  String? _selectedDuration; // 인증 기간
  String? _selectedFrequency; // 인증 빈도

  // 인증 기간 직접 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // 모든 조건이 충족되었는지 확인
  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty && // 이름 입력
        _selectedDay != null && // 시작일 선택
        _selectedDuration != null && // 기간 선택
        _selectedFrequency != null && // 빈도 선택됨
        _selectedTagModels.isNotEmpty && // 태그
        _descriptionController.text.trim().isNotEmpty && // 설명 입력
        selectedType != 0 && // 인증 방식 선택
        selectedVisibility != 0; // 공개범위 선택
  }

  // 상태 초기화
  @override
  void initState() {
    super.initState();

    _focusedDay = _today;
    // 스크롤 리스너 추가
    _scrollController.addListener(_onScroll);

    // 텍스트 입력 시마다 버튼 활성화 여부를 판단
    _nameController.addListener(_updateState);
    _descriptionController.addListener(_updateState);
  }

  // 상태 업데이트 함수
  void _updateState() {
    setState(() {});
  }

  // 리스너 제거 및 해제
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
    final requestData = _buildRequestData(); // ✅ 데이터 가공 분리
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('챌린지 생성 중 오류가 발생했습니다.')));
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 뒤로 가기 버튼
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
          ),
        ),
        title: Text(
          "챌린지 만들기",
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
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
                hintText: '챌린지 이름을 입력하세요',
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '챌린지 시작일'),
              ChallengeInputBox(
                leadingIconPath: 'assets/images/icons/calendar.svg',
                hintText: _dateHintText,
                // 선택된 날짜가 없으면 gray3, 날짜가 선택되면 black으로 설정
                textColor: _selectedDay == null
                    ? AppColors.gray3
                    : AppColors.black,
                iconPath: 'assets/images/icons/big_down_arrow.svg',
                onTap: _showCalendarBottomSheet,
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '인증 기간'),
              ChallengeInputBox(
                hintText: _selectedDuration ?? '인증 기간을 선택하세요',
                textColor: _selectedDuration == null
                    ? AppColors.gray3
                    : AppColors.black,
                iconPath: 'assets/images/icons/big_down_arrow.svg',
                onTap: showDurationBottomSheet,
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '인증 빈도'),
              ChallengeInputBox(
                hintText: _selectedFrequency ?? '인증 빈도를 선택하세요',
                textColor: _selectedFrequency == null
                    ? AppColors.gray3
                    : AppColors.black,
                iconPath: 'assets/images/icons/big_down_arrow.svg',
                onTap: showFrequencyBottomSheet,
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '챌린지 태그'),
              ChallengeInputBox(
                hintText: '태그를 선택하세요',
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

              ChallengeTypeSelector(
                selectedType: selectedType,
                onChanged: (type) {
                  setState(() => selectedType = type);

                  // 사진 첨부 필수를 눌렀을 때만 하단으로 스크롤 이동
                  if (type == 1) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  }
                },
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
      bottomNavigationBar: PlusButton(
        label: '만들기',
        showShadow: _showShadow, // 상태 전달
        onPressed:
            _isFormValid // 모든 필드가 입력되었을 때만 활성화
            ? () {
                _submitChallenge(); // 데이터 수집 및 팝업 실행!
              }
            : null,
      ),
    );
  }
}
