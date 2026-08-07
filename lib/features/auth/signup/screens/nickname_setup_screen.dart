// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/auth/signup/widgets/signup_page_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';
import '../models/signup_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

// 닉네임 입력 화면
class NicknameSetupScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const NicknameSetupScreen({super.key, required this.onNext});

  @override
  ConsumerState<NicknameSetupScreen> createState() =>
      _NicknameSetupScreenState();
}

// 닉네임 입력 화면의 상태 관리 클래스
class _NicknameSetupScreenState extends ConsumerState<NicknameSetupScreen> {
  final TextEditingController _nicknameController =
      TextEditingController(); // 닉네임 텍스트 입력을 제어하는 컨트롤러
  bool _isButtonEnabled = false; // 하단 다음 버튼의 활성화 상태
  bool _isDuplicate = false; // 닉네임 중복 여부
  bool _isInvalidFormat = false; // 띄어쓰기 + ./- 외에 다른 특수문자 포함 여부

  @override
  void initState() {
    super.initState();
    // 사용자가 타이핑할 때마다 유효성을 실시간으로 계산하기 위해 리스너 등록
    _nicknameController.addListener(_handleInputChange);

    // 뒤로 돌아왔을 때 이전에 입력한 닉네임 불러오기
    Future.microtask(() {
      final savedNickname = ref.read(signupProvider).nickname;
      if (savedNickname.isNotEmpty) {
        _nicknameController.text = savedNickname;
      }
    });
  }

  // 텍스트 변경 시 호출되어 검사 및 버튼 상태를 업데이트합니다.
  void _handleInputChange() {
    final text = _nicknameController.text;

    setState(() {
      if (text.isEmpty) {
        _isInvalidFormat = false;
      } else {
        // [규칙] 한글(초성/모음/완성형), 영문, 숫자만 1~10자 허용
        final regExp = RegExp(r'^[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣._-]{1,15}$');
        _isInvalidFormat = !regExp.hasMatch(text);
      }

      // 버튼 활성화 여부 판단
      // 1자 이상 15자 이하이며 형식이 올바를 때만 버튼 활성화
      _isButtonEnabled =
          text.isNotEmpty && text.length <= 15 && !_isInvalidFormat;

      // 다시 입력 시작 시 중복 에러 초기화
      if (_isDuplicate) _isDuplicate = false;
    });
  }

  Future<void> _checkNickname() async {
    final nickname = _nicknameController.text;

    // 1. 로딩 상태 시작 (버튼 중복 클릭 방지용)
    setState(() => _isButtonEnabled = false);

    // 2. 서버에 중복 확인 요청 (GET 방식이라 저장되지 않음)
    final isDuplicate = await ref
        .read(signupProvider.notifier)
        .checkNicknameDuplicate(nickname);

    if (isDuplicate) {
      setState(() {
        _isDuplicate = true;
        _isButtonEnabled = true;
      });
    } else {
      // 3. 중복이 아니면 로컬 상태만 업데이트하고 다음 단계로 이동!
      ref.read(signupProvider.notifier).updateNickname(nickname);
      widget.onNext();
    }
  }

  @override
  void dispose() {
    // 위젯 소멸 시 컨트롤러를 해제하여 메모리 누수를 방지
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // 어떤 에러 메시지를 보여줄지 결정 (형식 에러가 중복 에러보다 우선순위 높음)
    String? errorMessage;
    if (_isInvalidFormat) {
      errorMessage = '* 마침표(.), 언더바(_), 하이픈(-) 외의 특수문자나 \n띄어쓰기는 포함할 수 없어요';
    } else if (_isDuplicate) {
      errorMessage = '* 중복된 닉네임이에요';
    }

    return SignupPageLayout(
      title: '해냄에서 사용할 \n닉네임을 입력해주세요',
      subTitle: '한글, 영문, 숫자와 특수문자( . , _ , - )를 포함해 \n15자 이내로 지어주세요.',
      isButtonEnabled: _isButtonEnabled,
      onNext: _checkNickname,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nicknameController,
            maxLength: 15,
            style: AppTypography.b2.copyWith(color: appColors.blackToWhite),
            decoration: InputDecoration(
              hintText: '닉네임을 입력해주세요',
              hintStyle: AppTypography.b2.copyWith(color: appColors.gray3),
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: (errorMessage != null)
                      ? appColors.notification
                      : appColors.gray4,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: (errorMessage != null)
                      ? appColors.notification
                      : appColors.primaryAble,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 에러 메시지 영역
              Expanded(
                child: errorMessage != null
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 별표 기호만 따로 분리
                          Text(
                            '* ',
                            style: AppTypography.c1.copyWith(
                              color: appColors.notification,
                              height: 1.5,
                            ),
                          ),
                          // 실제 메시지 내용
                          Expanded(
                            child: Text(
                              // 기존 메시지에서 '* '를 제거하고 전달
                              errorMessage.replaceFirst('* ', ''),
                              style: AppTypography.c1.copyWith(
                                color: appColors.notification,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(width: 8), // 메시지와 카운터 사이 간격
              // 글자수 카운터
              Text(
                '${_nicknameController.text.length}/15',
                style: AppTypography.c1.copyWith(color: appColors.gray2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
