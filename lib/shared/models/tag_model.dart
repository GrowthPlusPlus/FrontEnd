// 최초 작성자 : 김채영

class ChallengeTagModel {
  final int id;
  final String tag;
  final String tagCategory;

  int get tagId => id;

  ChallengeTagModel({
    required this.id,
    required this.tag,
    required this.tagCategory,
  });

  factory ChallengeTagModel.fromJson(Map<String, dynamic> json) {
    return ChallengeTagModel(
      id: json['tagId'] ?? 0,
      tag: json['tag'] ?? '',
      tagCategory: json['tagCategory'] ?? 'AGE',
    );
  }
}

// 서버의 영문 카테고리를 앱 내 한글 명칭으로 변환
class TagMapper {
  // 카테고리 배치 순서
  static const List<String> categoryOrder = [
    'AGE',
    'HEALTH',
    'STUDY',
    'HOBBY',
    'GROUP',
  ];

  // 카테고리별 내부 태그 순서
  static const Map<String, List<String>> tagInternalOrder = {
    'AGE': ['10대', '20대', '30대', '40대', '50대 이상', '대학생', '고3', '편준생', 'n수생'],
    'HEALTH': ['운동', '러닝', '홈트', '다이어트', '건강', '식단', '수면패턴'],
    'STUDY': ['입시', '공시', '시험', '어학', '자격증', '취준', '과제'],
    'HOBBY': ['취미', '독서', '악기', '그림/드로잉', '필사/글쓰기'],
    'GROUP': ['스터디', '동아리'],
  };

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
