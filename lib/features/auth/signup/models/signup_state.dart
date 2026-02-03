// 최초 작성자: 김채영
// 회원가입 진행 상태를 담는 DTO

import 'dart:io';

/// 회원가입 과정에서 입력되는 모든 정보를 관리하는 모델
class SignupState {
  final String nickname; // 닉네임 (1~15자)
  final File? profileImage; // 프로필 이미지 (null일 경우 서버에서 기본 이미지 처리)
  final String bio; // 한 줄 소개 (최대 50자)
  final List<String> tags; // 사용자가 선택한 태그 '이름'들
  final Map<String, List<String>> categorizedTags; // 서버에서 받은 {카테고리: [태그이름들]}
  final bool isLoading; // 서버 전송 중 로딩 상태

  SignupState({
    this.nickname = '',
    this.profileImage,
    this.bio = '',
    this.tags = const [],
    this.categorizedTags = const {}, // 초기값은 빈 맵
    this.isLoading = false,
  });

  // 유효성 검사를 위한 Getter들
  bool get isNicknameValid =>
      nickname.isNotEmpty &&
      nickname.length <= 15 &&
      RegExp(r'^[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣._-]{1,15}$').hasMatch(nickname);

  bool get isTagsValid => tags.length >= 2 && tags.length <= 6;

  // 모든 필수 단계가 완료되었는지 확인 (최종 가입 버튼 활성화용)
  bool get isComplete => isNicknameValid && isTagsValid;

  // Riverpod 상태 업데이트를 위한 copyWith
  SignupState copyWith({
    String? nickname,
    File? profileImage,
    String? bio,
    List<String>? tags,
    Map<String, List<String>>? categorizedTags,
    bool? isLoading,
  }) {
    return SignupState(
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      tags: tags ?? this.tags,
      categorizedTags: categorizedTags ?? this.categorizedTags,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() {
    return 'SignupState(nickname: $nickname, hasImage: ${profileImage != null}, bio: $bio, tagsCount: ${tags.length})';
  }
}
