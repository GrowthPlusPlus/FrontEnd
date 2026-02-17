// 최초 작성자 : 김채영
// 서버의 영문 카테고리를 앱 내 한글 명칭으로 변환
class TagMapper {
  static String getKoreanCategory(String englishCategory) {
    switch (englishCategory.toUpperCase()) {
      case 'AGE':
        return '연령/상태';
      case 'HEALTH':
        return '운동/건강';
      case 'STUDY':
        return '학업/시험';
      case 'HOBBY':
        return '취미/여가';
      case 'GROUP':
        return '그룹 활동';
      default:
        return englishCategory; // 매핑되지 않은 경우 원래 문자열 반환
    }
  }
}
