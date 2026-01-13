// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:haenaem/shared/widgets/custom_bottom_sheet.dart';
import 'package:haenaem/features/challenge/widgets/challenge_create_success_dialog.dart';

// -- 챌린지 생성 화면 --
class ChallengeCreatePage extends StatefulWidget {
  const ChallengeCreatePage({super.key});

  @override
  State<ChallengeCreatePage> createState() => _ChallengeCreatePageState();
}

// 스크롤 제어를 위한 컨트롤러 추가 - 사진 첨부 필수 버튼을 누르면 notice가 뿅 나타나게
final ScrollController _scrollController = ScrollController();

class _ChallengeCreatePageState extends State<ChallengeCreatePage> {
  // 현재 선택된 방식을 저장 (0: 미선택, 1: 사진 필수, 2: 체크 자유)
  int selectedType = 0;

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
        _selectedTags.isNotEmpty && // 태그 1개 이상
        _descriptionController.text.trim().isNotEmpty && // 설명 입력
        selectedType != 0; // 인증 방식 선택
  }

  // 선택된 태그들을 담을 리스트
  final List<String> _selectedTags = [];

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
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 챌린지 생성 데이터 제출 준비 로직
  void _submitChallenge() {
    // 선택된 값들을 백엔드 전송용 데이터로 가공
    final String title = _nameController.text.trim();
    final String startDate = _selectedDay != null
        ? "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}"
        : "";

    // "30일" -> 30 (숫자만 추출)
    final int duration =
        int.tryParse(_selectedDuration?.replaceAll('일', '') ?? '0') ?? 0;

    final String frequency = _selectedFrequency ?? "";
    final List<String> tags = List.from(_selectedTags);
    final String description = _descriptionController.text.trim();
    final String authType = selectedType == 1 ? "PHOTO" : "FREE";

    // 콘솔에 예쁘게 출력 (백엔드에게 줄 데이터 미리보기)
    print("====================================");
    print("🚀 [챌린지 생성 요청 데이터]");
    print("제목: $title");
    print("시작일: $startDate");
    print("기간: $duration일");
    print("빈도: $frequency");
    print("태그: ${tags.join(', ')}");
    print("설명: $description");
    print("인증방식: $authType");
    print("====================================");

    // 성공 팝업 띄우기
    showDialog(
      context: context,
      barrierColor: const Color(0x7F1A1D1B),
      builder: (context) => const ChallengeCreateSuccessDialog(),
    );
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
      isScrollControlled: true, // 높이 조절을 위해 true
      backgroundColor: Colors.transparent,

      builder: (context) {
        return CustomBottomSheet(
          title: "챌린지 시작일",
          heightFactor: 0.59,
          child: StatefulBuilder(
            // 시트 내의 상태 변화를 위해 사용
            builder: (context, setBottomState) {
              // 현재 달이 시작 달(이번 달)인지 체크
              bool isFirstMonth =
                  _focusedDay.year == _today.year &&
                  _focusedDay.month == _today.month;

              // Transform.translate로 전체 내용을 위로 이동
              return Transform.translate(
                offset: const Offset(0, 0), // 0, -20 == 위로 20픽셀 이동
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  // 달력 위젯
                  child: TableCalendar(
                    locale: 'ko_KR', // 한국어 설정
                    firstDay: DateTime(_today.year, _today.month, 1),
                    lastDay: DateTime(_today.year + 5, 12, 31), // 향후 5년까지 선택 가능
                    focusedDay: _focusedDay,

                    // 간격 및 높이 정밀 조정
                    rowHeight: 45, // 행 간격 축소 (숫자 사이 간격 확보)
                    daysOfWeekHeight: 33, // 요일 라벨 높이 확보 (가려짐 방지)
                    // 커스텀 빌더
                    calendarBuilders: CalendarBuilders(
                      selectedBuilder: (context, date, events) {
                        return Center(
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.selected,
                              borderRadius: BorderRadius.circular(8),
                              shape: BoxShape.rectangle,
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: AppTypography.b1.copyWith(
                                  color: AppColors.primaryAble,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // 과거 날짜 선택 차단
                    enabledDayPredicate: (day) {
                      return !day.isBefore(
                        DateTime(_today.year, _today.month, _today.day),
                      );
                    },

                    // 요일 텍스트 스타일
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: AppTypography.b2.copyWith(
                        color: AppColors.gray2,
                      ),
                      weekendStyle: AppTypography.b2.copyWith(
                        color: AppColors.gray2,
                      ),
                    ),

                    // 달 변경 시 상태 업데이트
                    onPageChanged: (focusedDay) {
                      setBottomState(() {
                        _focusedDay = focusedDay;
                      });
                    },

                    headerStyle: HeaderStyle(
                      headerPadding: const EdgeInsets.only(top: 0, bottom: 5),
                      headerMargin: EdgeInsets.zero, // 헤더 자체 마진 제거
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: AppTypography.h3.copyWith(
                        color: AppColors.black,
                      ),

                      // 이전 달 이동 아이콘
                      leftChevronIcon: SvgPicture.asset(
                        'assets/images/icons/tab_previous.svg',
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          isFirstMonth ? AppColors.gray3 : AppColors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      leftChevronMargin: const EdgeInsets.only(left: 50),

                      // 다음 달 이동 아이콘
                      rightChevronIcon: SvgPicture.asset(
                        'assets/images/icons/tab_next.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          AppColors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      rightChevronMargin: const EdgeInsets.only(right: 50),
                    ),

                    calendarStyle: CalendarStyle(
                      // 비활성화된 날짜 스타일
                      disabledTextStyle: AppTypography.b1.copyWith(
                        color: AppColors.gray3,
                      ),
                      disabledDecoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                      ),

                      // 오늘 날짜 효과 제거
                      todayDecoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.rectangle,
                      ),
                      todayTextStyle: AppTypography.b1.copyWith(
                        color: AppColors.black,
                      ),

                      // 선택된 날짜 효과
                      selectedDecoration: BoxDecoration(
                        color: AppColors.selected,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      selectedTextStyle: AppTypography.b1.copyWith(
                        color: AppColors.primaryAble,
                      ),

                      // 일반 날짜 스타일
                      defaultTextStyle: AppTypography.b1.copyWith(
                        color: AppColors.black,
                      ),
                      weekendTextStyle: AppTypography.b1.copyWith(
                        color: AppColors.black,
                      ),

                      // 이번 달 외 날짜 스타일
                      outsideDaysVisible: true,
                      outsideTextStyle: AppTypography.b1.copyWith(
                        color: AppColors.gray3,
                      ),
                      outsideDecoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                      ),
                    ),

                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                    onDaySelected: (selectedDay, focusedDay) {
                      setBottomState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      setState(() {
                        _selectedDay = selectedDay;
                        _dateHintText =
                            "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
                      });

                      Future.delayed(const Duration(milliseconds: 150), () {
                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 인증 기간 탭
  void showDurationBottomSheet() {
    bool isCustomMode = false;
    bool isButtonEnabled = false;
    final TextEditingController customController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            // 입력값 검증 리스너 (1~365일)
            void validate(String text) {
              final val = int.tryParse(text);
              bool valid = val != null && val >= 1 && val <= 365;
              if (isButtonEnabled != valid) {
                setBottomState(() => isButtonEnabled = valid);
              }
            }

            return CustomBottomSheet(
              title: "인증 기간 선택",
              // 직접 입력 모드일 때 0.75로 확장
              heightFactor: isCustomMode ? 0.80 : 0.55,
              // 스크롤 가능
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 기존 기간 리스트
                    ...["7일", "30일", "50일", "100일", "365일"].map((item) {
                      return buildListItem(
                        label: item,
                        isSelected: _selectedDuration == item && !isCustomMode,
                        onTap: () {
                          setBottomState(() => _selectedDuration = item);
                          setState(() => _selectedDuration = item);
                          Future.delayed(
                            const Duration(milliseconds: 150),
                            () => Navigator.pop(context),
                          );
                        },
                      );
                    }),

                    // 직접 입력 (눌렀을 때 아래에 폼이 나타남)
                    Container(
                      width: double.infinity,
                      color: isCustomMode
                          ? AppColors.selected
                          : Colors.transparent,
                      child: Column(
                        children: [
                          buildListItem(
                            label: "직접 입력",
                            isSelected: isCustomMode,
                            onTap: () =>
                                setBottomState(() => isCustomMode = true),
                          ),

                          // 직접 입력을 눌렀을 때 나타나는 입력 폼
                          if (isCustomMode) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 23,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '• 1일 이상의 기간을 입력해주세요',
                                            style: AppTypography.b2.copyWith(
                                              color: AppColors.gray2,
                                              height: 1.5,
                                            ),
                                          ),
                                          Text(
                                            '• 1~365일까지 설정할 수 있습니다.',
                                            style: AppTypography.b2.copyWith(
                                              color: AppColors.gray2,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    '인증 기간 (일)',
                                    style: AppTypography.c1.copyWith(
                                      color: AppColors.gray2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColors.gray3,
                                          width: 0.75,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: customController,
                                            onChanged: validate,
                                            keyboardType: TextInputType.number,
                                            style: AppTypography.b1,
                                            decoration: InputDecoration(
                                              hintText: "숫자를 입력하세요",
                                              hintStyle: AppTypography.b1
                                                  .copyWith(
                                                    color: AppColors.gray3,
                                                  ),
                                              border: InputBorder.none,
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '일',
                                          style: AppTypography.b1.copyWith(
                                            color: AppColors.gray1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // 완료 버튼
                                  GestureDetector(
                                    onTap: isButtonEnabled
                                        ? () {
                                            setState(() {
                                              _selectedDuration =
                                                  "${customController.text}일";
                                            });
                                            Navigator.pop(context);
                                          }
                                        : null,
                                    child: Container(
                                      width: double.infinity,
                                      height: 44,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isButtonEnabled
                                            ? AppColors.primaryAble
                                            : AppColors.disable,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '완료',
                                        style: AppTypography.b1.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        ],
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

  // 인증 빈도 탭
  void showFrequencyBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomBottomSheet(
          title: "인증 빈도",
          heightFactor: 0.55,
          child: StatefulBuilder(
            builder: (context, setBottomState) {
              final items = ["매일", "주 2회", "주 3회", "주 4회", "주 5회", "주 6회"];
              return ListView(
                shrinkWrap: true,
                children: items.map((item) {
                  return buildListItem(
                    label: item,
                    isSelected: _selectedFrequency == item,
                    onTap: () {
                      setBottomState(() => _selectedFrequency = item);
                      setState(() => _selectedFrequency = item);
                      Future.delayed(
                        const Duration(milliseconds: 150),
                        () => Navigator.pop(context),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  // 리스트 스타일
  Widget buildListItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        // 텍스트를 위한 내부 패딩 추가
        //padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selected : Colors.transparent,
        ),
        // 가운데 정렬
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.b1.copyWith(
            color: isSelected ? AppColors.primaryAble : AppColors.black,
          ),
        ),
      ),
    );
  }

  // 챌린지 태그 선택 시트
  void showChallengeTagBottomSheet() {
    // 바텀 시트 내에서 사용할 태그 데이터
    final Map<String, List<String>> tagCategories = {
      '연령/상태': ['10대', '20대', '30대', '고3', '편준생', 'n수생'],
      '운동/건강': ['운동', '러닝', '홈트', '다이어트', '건강', '식단', '수면패턴'],
      '학업/시험': ['입시', '공시', '시험', '어학', '자격증', '취준', '과제'],
      '취미/여가': ['취미', '독서', '악기', '그림/드로잉', '필사/글쓰기'],
      '그룹 활동': ['스터디', '동아리'],
      '기타': ['기타'],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            // 완료 버튼 활성화 조건 (1~2개 선택 시)
            bool isButtonEnabled =
                _selectedTags.isNotEmpty && _selectedTags.length <= 2;

            return CustomBottomSheet(
              title: "챌린지 태그",
              heightFactor: 0.80,
              child: Column(
                children: [
                  // 상단 안내 문구
                  const SizedBox(height: 10),
                  Text(
                    '태그를 통해 관심 분야를 알려주세요\n1~2개를 골라주세요',
                    textAlign: TextAlign.center,
                    style: AppTypography.b1.copyWith(
                      color: AppColors.black,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 카테고리별 태그 리스트 (스크롤 영역)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tagCategories.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: AppTypography.c1.copyWith(
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 12, // 태그 간 가로 간격
                                  runSpacing: 8, // 태그 간 세로 간격
                                  children: entry.value.map((tag) {
                                    final isSelected = _selectedTags.contains(
                                      tag,
                                    );
                                    return buildTagChip(
                                      label: tag,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setBottomState(() {
                                          if (isSelected) {
                                            _selectedTags.remove(tag);
                                          } else {
                                            if (_selectedTags.length < 2) {
                                              _selectedTags.add(tag);
                                            }
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // 하단 완료 버튼
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    // 완료 버튼 기준 위(12), 아래(12) 여백 설정
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: GestureDetector(
                        onTap: isButtonEnabled
                            ? () {
                                setState(() {});
                                Navigator.pop(context);
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isButtonEnabled
                                ? AppColors.primaryAble
                                : AppColors.disable,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '완료',
                            style: AppTypography.h3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 태그
  Widget buildTagChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28, // 고정 높이
        padding: const EdgeInsets.symmetric(horizontal: 11),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          // 선택 시 테두리 추가, 배경색 변경
          color: isSelected ? AppColors.selected : AppColors.gray5,
          shape: RoundedRectangleBorder(
            side: isSelected
                ? const BorderSide(width: 2, color: AppColors.primaryAble)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.b2.copyWith(
                color: isSelected ? AppColors.primaryAble : AppColors.black,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 선택된 챌린지 태그 목록 표시
  Widget buildSelectedTags() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        // Row 대신 Wrap을 사용하여 태그가 길어져도 줄바꿈이 되도록 함
        spacing: 10, // 태그 간 간격
        children: _selectedTags
            .map(
              (tag) => Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 11),
                decoration: ShapeDecoration(
                  color: AppColors.gray5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  tag,
                  style: AppTypography.b2.copyWith(color: AppColors.black),
                ),
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
                iconPath: 'assets/images/icons/down.svg',
                onTap: _showCalendarBottomSheet,
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '인증 기간'),
              ChallengeInputBox(
                hintText: _selectedDuration ?? '인증 기간을 선택하세요',
                textColor: _selectedDuration == null
                    ? AppColors.gray3
                    : AppColors.black,
                iconPath: 'assets/images/icons/down.svg',
                onTap: showDurationBottomSheet,
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '인증 빈도'),
              ChallengeInputBox(
                hintText: _selectedFrequency ?? '인증 빈도를 선택하세요',
                textColor: _selectedFrequency == null
                    ? AppColors.gray3
                    : AppColors.black,
                iconPath: 'assets/images/icons/down.svg',
                onTap: showFrequencyBottomSheet,
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '챌린지 태그'),
              ChallengeInputBox(
                hintText: '태그를 선택하세요',
                iconPath: 'assets/images/icons/down.svg',
                onTap: showChallengeTagBottomSheet,
                tag: _selectedTags.isEmpty ? null : buildSelectedTags(),
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '챌린지 설명'),
              ChallengeInputBox(
                controller: _descriptionController,
                hintText: '예: 오전 6시~8시 사이 운동 인증샷 업로드',
                height: 139,
              ),

              const SizedBox(height: 16),

              const ChallengeLabel(label: '챌린지 인증 방식'),
              Row(
                spacing: 10,
                children: [
                  ChallengeSelectButton(
                    label: "사진 첨부 필수",
                    isSelected: selectedType == 1,
                    onTap: () {
                      setState(() {
                        selectedType = 1;
                      });

                      // 화면 하단으로 스크롤
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent, // 가장 아래로
                          duration: const Duration(
                            milliseconds: 300,
                          ), // 0.3초 동안
                          curve: Curves.easeOut, // 부드러운 속도 곡선
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChallengeSelectButton(
                    label: "체크(사진 첨부 자유)",
                    isSelected: selectedType == 2,
                    onTap: () => setState(() => selectedType = 2),
                  ),
                ],
              ),

              // selectedType이 1(사진 첨부 필수)일 때만 안내 박스 표시
              if (selectedType == 1) ...[
                const SizedBox(height: 12),
                const AiNoticeBox(),
              ],
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

// 재사용 목적 - 텍스트 라벨
class ChallengeLabel extends StatelessWidget {
  final String label;

  const ChallengeLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // 박스와의 간격 고정
      child: Text(label, style: AppTypography.b1),
    );
  }
}

// 재사용 목적 - 입력 박스 (입력/선택 전환 가능)
class ChallengeInputBox extends StatelessWidget {
  final String hintText;
  final double height;
  final String? iconPath; // SVG 아이콘 경로 (선택)
  final String? leadingIconPath; // 캘린더 svg
  final VoidCallback? onTap; // 클릭 시 동작 (선택)
  final TextEditingController? controller; // 입력용 컨트롤러
  final Widget? tag; // 태그 넣기

  // 입력박스 안 색상 변경
  final Color? textColor;

  const ChallengeInputBox({
    super.key,
    required this.hintText,
    this.height = 48,
    this.iconPath,
    this.leadingIconPath,
    this.onTap,
    this.controller,
    this.textColor,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray4, width: 1),
        ),
        // 박스 내부 내용물 배치
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center, // 아이콘 중앙 정렬
          children: [
            // 왼쪽 영역 (앞 아이콘 + 텍스트/입력필드)을 묶어서 Expanded로 확장
            Expanded(
              child: Row(
                children: [
                  // leadingIconPath가 있으면 표시
                  if (leadingIconPath != null) ...[
                    SvgPicture.asset(
                      leadingIconPath!,
                      width: 15,
                      height: 15,
                      colorFilter: const ColorFilter.mode(
                        AppColors.gray3,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    // onTap이 있으면 일반 Text(선택 모드), 없으면 TextField(입력 모드)
                    child:
                        tag ??
                        TextField(
                          controller: controller,
                          readOnly: onTap != null,

                          enabled: true,
                          onTap: onTap,
                          style: AppTypography.b2.copyWith(
                            color: AppColors.black,
                          ),

                          // 챌린지 설명 hintText 위로 올리기
                          textAlignVertical: height > 48
                              ? TextAlignVertical.top
                              : TextAlignVertical.center,
                          expands: height > 48,
                          maxLines: height > 48 ? null : 1,
                          minLines: height > 48 ? null : 1,

                          // ------------------------------------
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: AppTypography.b2.copyWith(
                              color: textColor ?? AppColors.gray3,
                            ),
                            border: InputBorder.none,
                            isDense: true,

                            // 챌린지 설명 - 텍스트가 상단 테두리에 너무 붙지 않게 조정
                            contentPadding: height > 48
                                ? const EdgeInsets.symmetric(vertical: 12)
                                : EdgeInsets.zero,
                          ),
                        ),
                  ),

                  if (iconPath != null)
                    SvgPicture.asset(iconPath!, width: 20, height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 버튼들
class ButtonTypesExample extends StatelessWidget {
  const ButtonTypesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          Spacer(),
          ButtonTypesGroup(enabled: true),
          ButtonTypesGroup(enabled: false),
          Spacer(),
        ],
      ),
    );
  }
}

// 버튼 타입별 디자인 가이드 점검 및 활성 상태(enabled) 테스트를 위한 컴포넌트 그룹
class ButtonTypesGroup extends StatelessWidget {
  const ButtonTypesGroup({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onPressed = enabled ? () {} : null;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ElevatedButton(onPressed: onPressed, child: const Text('Elevated')),
          FilledButton(onPressed: onPressed, child: const Text('Filled')),
          FilledButton.tonal(
            onPressed: onPressed,
            child: const Text('Filled Tonal'),
          ),
          OutlinedButton(onPressed: onPressed, child: const Text('Outlined')),
          TextButton(onPressed: onPressed, child: const Text('Text')),
        ],
      ),
    );
  }
}

// 하단 +만들기 버튼
class PlusButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool showShadow;

  const PlusButton({
    super.key,
    this.showShadow = true, // 기본값은 true
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // onPressed가 null이면 비활성화 색상, 아니면 활성화 색상
    final bool isEnabled = onPressed != null;

    return Container(
      // 바깥쪽 그림자 및 배경 설정
      decoration: BoxDecoration(
        color: Colors.white,

        // showShadow가 true일 때만 그림자 등장
        boxShadow: showShadow
            ? [
                const BoxShadow(
                  color: Color(0x28000000),
                  blurRadius: 175.60,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        height: 90,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              height: 60,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: isEnabled ? AppColors.primaryAble : AppColors.disable,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 플러스 아이콘
                  SvgPicture.asset(
                    'assets/images/icons/plus.svg',
                    width: 20,
                    height: 20,
                    // 아이콘 색상도 텍스트와 맞춰 white로 변경
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),

                  // 텍스트와 아이콘 사이 간격
                  const SizedBox(width: 10),

                  // "만들기" 텍스트
                  Text(
                    label,
                    style: AppTypography.h3.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 챌린지 인증 방식의 버튼
class ChallengeSelectButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ChallengeSelectButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            // 활성화 시 selected 색상, 비활성 시 gray5
            color: isSelected ? AppColors.selected : AppColors.gray5,
            borderRadius: BorderRadius.circular(8),
            // 활성화 시에만 primaryAble 외곽선 추가
            border: isSelected
                ? Border.all(color: AppColors.primaryAble, width: 1)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.b2.copyWith(
              // 활성화 시 Bold + primaryAble 색상
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryAble : AppColors.gray2,
            ),
          ),
        ),
      ),
    );
  }
}

// 사진 첨부 필수를 누를 경우 안내 박스
class AiNoticeBox extends StatelessWidget {
  const AiNoticeBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray4, width: 0.75),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 아이콘이 문구 상단에 맞게
        children: [
          SvgPicture.asset(
            'assets/images/icons/ai_notice.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.gray1,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '정확한 인증을 위해 AI 검증 단계를 거치게 됩니다. \n환경에 따라 인식이 지연되거나 재촬영이 필요할 수 있습니다.',
              style: AppTypography.c1.copyWith(color: AppColors.gray1),
            ),
          ),
        ],
      ),
    );
  }
}
