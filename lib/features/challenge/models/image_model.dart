// // 리팩토링: 강선욱
// // 이미지 관련 정보 관리 클래스

// // 인증글 사진 정보를 관리하는 클래스
// @Deprecated('shared/models/post.dart에 함께 정의. 이 모델은 사용 X')
// class PostImage {
//   final int imageId;
//   final String imageUrl;

//   PostImage({required this.imageId, required this.imageUrl});

//   factory PostImage.fromJson(Map<String, dynamic> json) {
//     return PostImage(
//       imageId: json['imageId'] ?? 0,
//       imageUrl: json['imageUrl'] ?? '',
//     );
//   }
// }
