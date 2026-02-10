class KoreanStringUtils {
  static const int hangeulBase = 0xAC00;
  static const String koreanRegex = r'^[가-힣]';
  static const List<String> choseongList = [
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ];

  /// 한글 문자열에서 초성만 추출 (검색용)
  static String getChoseongString(String text) {
    String result = "";
    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      if (charCode >= 0xAC00 && charCode <= 0xD7A3) {
        int choseongIndex = (charCode - hangeulBase) ~/ (21 * 28);
        result += choseongList[choseongIndex];
      } else {
        result += text[i];
      }
    }
    return result;
  }

  /// 문자 타입별 우선순위 점수 부여
  /// 낮은 점수일수록 앞에 정렬됨
  static int _getPriority(String char) {
    if (char.isEmpty) return 6;
    int code = char.codeUnitAt(0);

    // 1. 한글 (가-힣)
    if (code >= 0xAC00 && code <= 0xD7A3) return 1;
    // 2. 영문 대문자 (A-Z)
    if (code >= 65 && code <= 90) return 2;
    // 3. 영문 소문자 (a-z)
    if (code >= 97 && code <= 122) return 3;
    // 4. 숫자 (0-9)
    if (code >= 48 && code <= 57) return 4;
    // 5. 특수문자 및 기타
    return 5;
  }

  /// 정렬 로직: 한글 > 대문자 > 소문자 > 숫자 > 특수문자
  static int compareKoreanFirst(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 0;
    if (a.isEmpty) return 1;
    if (b.isEmpty) return -1;

    int priorityA = _getPriority(a[0]);
    int priorityB = _getPriority(b[0]);

    if (priorityA != priorityB) {
      return priorityA.compareTo(priorityB);
    }

    // 동일한 타입 내에서는 사전순 정렬
    return a.compareTo(b);
  }
}
