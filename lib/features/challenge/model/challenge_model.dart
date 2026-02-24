// 최초 작성자: 강선욱
// 챌린지 관련 데이터 관리 모델
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:haenaem/features/challenge/model/user_model.dart';
import 'package:haenaem/features/challenge/model/image_model.dart';

// 챌린지의 상태(완료, 실패 위기, 일반)를 정의하는 열거형
enum ChallengeStatus {
  completed, // 초록색 카드
  urgent, // 빨간색 카드
  normal, // 회색 카드
}

// 메인화면에서 관리하는 챌린지 모델
class ChallengeMainModel {
  final int notificationNumber;
  final List<Map<String, dynamic>> myChallenges;

  ChallengeMainModel({
    required this.notificationNumber,
    required this.myChallenges,
  });

  factory ChallengeMainModel.fromJson(Map<String, dynamic> json) {
    return ChallengeMainModel(
      notificationNumber: json['notificationNumber'] ?? 0,
      myChallenges: List<Map<String, dynamic>>.from(json['myChallenges'] ?? []),
    );
  }

  /// 특정 인덱스의 챌린지 상태를 가져오는 함수
  ChallengeStatus getStatus(int index) {
    final challenge = myChallenges[index];
    if (challenge['doIt'] == true) return ChallengeStatus.completed;
    if (challenge['warning'] == true) return ChallengeStatus.urgent;
    return ChallengeStatus.normal;
  }

  /// 특정 인덱스의 참여 인원 정보를 반환하는 함수
  String getParticipantInfo(int index) {
    final challenge = myChallenges[index];
    return "${challenge['todaySuccessCount']}/${challenge['participantNumber']}명";
  }
}

// class ChallengeModel {
//   final int challengeId; // 챌린지 id
//   final String title; // 챌린지 제목
//   final String content; // 챌린지 소개
//   final int maxParticipantNumber; // 최대 인원수
//   final int participantNumber; // 참여 인원수
//   final int duringDate; // 시작 경과일
//   final bool isDoneToday; // API의 'doIt' 매핑
//   final bool isUrgent; // API의 'warning' 매핑

//   ChallengeModel({
//     required this.challengeId,
//     required this.title,
//     required this.content,
//     required this.maxParticipantNumber,
//     required this.participantNumber,
//     required this.duringDate,
//     required this.isDoneToday,
//     required this.isUrgent,
//   });

//   // API(Map) 데이터를 모델 객체로 변환하는 생성자
//   factory ChallengeModel.fromJson(Map<String, dynamic> json) {
//     return ChallengeModel(
//       challengeId: json['challengeId'] ?? 0,
//       title: json['title'] ?? '',
//       content: json['content'] ?? '',
//       maxParticipantNumber: json['maxParticipantNumber'] ?? 0,
//       participantNumber: json['participantNumber'] ?? 0,
//       duringDate: json['duringDate'] ?? 0,
//       isDoneToday: json['doIt'] ?? false,
//       isUrgent: json['warning'] ?? false,
//     );
//   }

//   // 함수의 용도: 모델의 데이터를 기반으로 UI에 표시할 상태값을 계산함
//   ChallengeStatus getStatus() {
//     if (isDoneToday) {
//       return ChallengeStatus.completed; // 완료 상태 (초록색)
//     } else if (isUrgent) {
//       return ChallengeStatus.urgent; // 긴급 상태 (빨간색)
//     }
//     return ChallengeStatus.normal; // 일반 상태 (회색)
//   }
// }

// 챌린지 상세정보에서 사용하는 챌린지 모델
class ChallengeDetailModel {
  final String title;
  final String startDate;
  final String endDate;
  final int requiredWeeklyCount;
  final bool photoRequired;
  final List<ChallengeTagModel> tags;
  final String description;
  final HostModel host;
  final int participantCount;
  final List<ParticipantModel> todaySuccessUsers;

  ChallengeDetailModel({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.requiredWeeklyCount,
    required this.photoRequired,
    required this.tags,
    required this.description,
    required this.host,
    required this.participantCount,
    required this.todaySuccessUsers,
  });

  factory ChallengeDetailModel.fromJson(Map<String, dynamic> json) {
    return ChallengeDetailModel(
      title: json['title'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      requiredWeeklyCount: json['requiredWeeklyCount'] ?? 0,
      photoRequired: json['photoRequired'] ?? false,
      tags: (json['tags'] as List? ?? []).map((t) {
        if (t is String) {
          return ChallengeTagModel(id: 0, tag: t, tagCategory: 'ETC');
        } else if (t is Map<String, dynamic>) {
          return ChallengeTagModel.fromJson(t);
        } else {
          return ChallengeTagModel(id: 0, tag: '', tagCategory: 'ETC');
        }
      }).toList(),
      description: json['description'] ?? '',
      host: HostModel.fromJson(json['host'] ?? {}),
      participantCount: json['participantCount'] ?? 0,
      todaySuccessUsers:
          (json['todaySuccessUsers'] as List?)
              ?.map((e) => ParticipantModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// 챌린지 생성 데이터 관리 클래스
class ChallengeCreateResponse {
  final int id;
  final String challengeLink;
  final List<FriendModel> friends;

  ChallengeCreateResponse({
    required this.id,
    required this.challengeLink,
    required this.friends,
  });

  factory ChallengeCreateResponse.fromJson(Map<String, dynamic> json) {
    final String link = json['challengeLink'] ?? '';
    int finalId = 0;

    // 💡 서버가 'id'를 주면 그걸 쓰고, 없거나 null이면 링크에서 숫자를 추출합니다.
    if (json['id'] != null && json['id'] != 0) {
      finalId = json['id'];
    } else if (link.isNotEmpty) {
      // 링크 예시: http://localhost:3000/challenges/14
      try {
        finalId = int.parse(Uri.parse(link).pathSegments.last);
        print(
          '🎯 링크에서 ID 추출 성공: $finalId',
        ); // TODO: 링크에서 id 추출하지 않고 백엔드한테 받아야 함.
      } catch (e) {
        // Uri 파싱이 안 될 경우를 대비한 split 백업 로직
        finalId = int.tryParse(link.split('/').last) ?? 0;
      }
    }

    return ChallengeCreateResponse(
      id: finalId,
      challengeLink: link,
      friends: (json['friends'] as List? ?? [])
          .map((f) => FriendModel.fromJson(f))
          .toList(),
    );
  }
}

// 챌린지 내 현황 탭 데이터 관리 클래스
class ChallengeCalendarModel {
  final int totalSuccessDays;
  final int currentStreakDays;
  final bool challengeOwner;

  ChallengeCalendarModel({
    required this.totalSuccessDays,
    required this.currentStreakDays,
    required this.challengeOwner,
  });

  factory ChallengeCalendarModel.fromJson(Map<String, dynamic> json) {
    return ChallengeCalendarModel(
      totalSuccessDays: json['totalSuccessDays'] ?? 0,
      currentStreakDays: json['currentStreakDays'] ?? 0,
      challengeOwner: json['challengeOwner'] ?? false,
    );
  }
}

// 챌린지 내 현황 달력 그리드 모델
class ChallengeCalendarPhoto {
  final int postId;
  final String postDate;
  final String? imageUrl;

  ChallengeCalendarPhoto({
    required this.postId,
    required this.postDate,
    this.imageUrl,
  });

  factory ChallengeCalendarPhoto.fromJson(Map<String, dynamic> json) {
    return ChallengeCalendarPhoto(
      postId: json['postId'] ?? 0,
      postDate: json['postDate'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

// 댓글 데이터 관리
class ChallengeComment {
  final int commentId;
  final String userNickname;
  final String? userPicture;
  final String contents;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool mine;

  ChallengeComment({
    required this.commentId,
    required this.userNickname,
    this.userPicture,
    required this.contents,
    required this.createdAt,
    required this.updatedAt,
    required this.mine,
  });

  factory ChallengeComment.fromJson(Map<String, dynamic> json) {
    return ChallengeComment(
      commentId: json['commentId'] ?? 0,
      userNickname: json['userNickname'] ?? '익명',
      userPicture: json['userPicture'],
      contents: json['contents'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      mine: json['mine'] ?? false,
    );
  }

  // 업데이트 시 상태 유지를 위한 copyWith
  ChallengeComment copyWith({
    int? commentId,
    String? userNickname,
    String? userPicture,
    String? contents,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? mine,
  }) {
    return ChallengeComment(
      commentId: commentId ?? this.commentId,
      userNickname: userNickname ?? this.userNickname,
      userPicture: userPicture ?? this.userPicture,
      contents: contents ?? this.contents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mine: mine ?? this.mine,
    );
  }
}

// 개별 인증글 모델
class CertificationPostModel {
  final int postId;
  final String challengeTitle;
  final int totalSuccessDays;
  final String content;
  final String? userNickname;
  final String? userImageUrl;
  final List<PostImage> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int likeNumber;
  final int commentNumber;
  final bool liked;
  final List<ChallengeComment> comments;

  // 기존 UI 코드 호환성을 위한 Getter
  String get postDate =>
      createdAt != null ? DateFormat('yyyy-MM-dd').format(createdAt!) : "";
  // 수정 여부를 확인하는 Getter (필요 시 활용)
  // bool get isEdited => updatedAt != null && updatedAt != createdAt;

  String? get imageUrl => images.isNotEmpty ? images.first.imageUrl : null;
  String? get userName => userNickname;
  int get likeCount => likeNumber;
  bool get hasImage => images.isNotEmpty;

  CertificationPostModel({
    required this.postId,
    required this.challengeTitle,
    required this.totalSuccessDays,
    required this.content,
    required this.images,
    this.userNickname,
    this.userImageUrl,
    this.createdAt,
    this.updatedAt,
    this.likeNumber = 0,
    this.commentNumber = 0,
    this.liked = false,
    this.comments = const [],
  });

  // 피드 탭에서 좋아요 수 업데이트를 위해 필요한 copyWith 메서드
  CertificationPostModel copyWith({
    int? postId,
    String? challengeTitle,
    int? totalSuccessDays,
    String? content,
    String? userNickname,
    String? userImageUrl,
    List<PostImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeNumber,
    int? commentNumber,
    bool? liked,
    List<ChallengeComment>? comments,
  }) {
    return CertificationPostModel(
      postId: postId ?? this.postId,
      challengeTitle: challengeTitle ?? this.challengeTitle,
      totalSuccessDays: totalSuccessDays ?? this.totalSuccessDays,
      content: content ?? this.content,
      userNickname: userNickname ?? this.userNickname,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeNumber: likeNumber ?? this.likeNumber,
      commentNumber: commentNumber ?? this.commentNumber,
      liked: liked ?? this.liked,
      comments: comments ?? this.comments,
    );
  }

  factory CertificationPostModel.fromJson(Map<String, dynamic> json) {
    // 1. 상세 조회용 'images' 리스트 처리 (객체 형태)
    List<PostImage> extractedImages = [];

    // 1. 신규 규격 (객체 리스트: images) 처리
    if (json['images'] != null && json['images'] is List) {
      extractedImages = (json['images'] as List)
          .map((item) => PostImage.fromJson(item))
          .toList();
    }
    // 2. 구 규격 대응 (문자열 리스트 혹은 단일 URL일 경우 ID 0으로 생성)
    else if (json['imageUrl'] != null) {
      extractedImages.add(PostImage(imageId: 0, imageUrl: json['imageUrl']));
    } else if (json['articleImageUrl'] != null &&
        json['articleImageUrl'] is List) {
      extractedImages = (json['articleImageUrl'] as List)
          .map((url) => PostImage(imageId: 0, imageUrl: url.toString()))
          .toList();
    }

    return CertificationPostModel(
      postId: json['postId'] ?? 0,
      challengeTitle: json['challengeTitle'] ?? '제목 없음',
      totalSuccessDays: json['totalSuccessDays'] ?? 0,
      content: json['content'] ?? '',
      images: extractedImages, // 💡 사진이 없으면 빈 리스트 [] 가 됩니다.
      userNickname: json['userNickname'] ?? '익명',
      userImageUrl: json['userImageUrl'],
      createdAt: DateTime.tryParse(json['postDate'] ?? json['createdAt'] ?? ''),
      likeNumber: json['likeNumber'] ?? 0,
      commentNumber: json['commentNumber'] ?? 0,
      liked: json['liked'] ?? false,
      comments: (json['comments'] as List? ?? [])
          .map((c) => ChallengeComment.fromJson(c))
          .toList(),
    );
  }
}

// 마이페이지 사용자 프로필 부분
class UserProfileModel {
  final String nickname;
  final String introduction;
  final String profileImageUrl;
  final List<String> tags;

  UserProfileModel({
    required this.nickname,
    required this.introduction,
    required this.profileImageUrl,
    required this.tags,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      nickname: json['nickname'] ?? '',
      introduction: json['introduction'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

// 마이페이지 탭 구분을 위한 전용 이름
enum MyPageTab { inProgress, success, fail }

// 내 페이지 - 나의 챌린지 - 진행중인 챌린지
class ChallengeInProgressModel {
  final int challengeId;
  final String title;
  final int requiredWeeklyCount; // 필수는 유지하되
  final int todaySuccessCount;
  final int participantNumber;
  final int duringDate;
  final String endDate;
  final double achievementRate;
  final String status;

  ChallengeInProgressModel({
    required this.challengeId,
    required this.title,
    required this.requiredWeeklyCount,
    required this.todaySuccessCount,
    required this.participantNumber,
    required this.duringDate,
    required this.endDate,
    required this.achievementRate,
    required this.status,
  });

  factory ChallengeInProgressModel.fromJson(Map<String, dynamic> json) {
    double rate = (json['achievementRate'] ?? 0).toDouble();

    // 💡 방어 로직: 0%일 때 직접 계산하는 로직에서도 null 체크 강화
    final int today = json['todaySuccessCount'] ?? 0;
    final int weekly = json['requiredWeeklyCount'] ?? 0;

    if (rate == 0 && weekly > 0) {
      rate = today / weekly;
    } else if (rate > 1.0) {
      rate = rate / 100.0;
    }

    return ChallengeInProgressModel(
      challengeId: json['challengeId'] ?? 0,
      title: json['title'] ?? '',
      requiredWeeklyCount: json['requiredWeeklyCount'] ?? 0,
      todaySuccessCount: json['todaySuccessCount'] ?? 0,
      participantNumber: json['participantNumber'] ?? 0,
      duringDate: json['duringDate'] ?? 0,
      endDate: json['endDate'] ?? '',
      achievementRate: rate,
      status: json['status'] ?? 'IN_PROGRESS',
    );
  }

  // 기존 UI 위젯 수정을 최소화하기 위한 Getter
  String get dateInfo => "완료일까지 D-${_calculateDDay()}";
  String get countInfo => "$todaySuccessCount/$participantNumber명";
  double get progress => achievementRate;

  int _calculateDDay() {
    try {
      final end = DateTime.parse(endDate);
      final dDay = end.difference(DateTime.now()).inDays;
      return dDay < 0 ? 0 : dDay;
    } catch (_) {
      return 0;
    }
  }
}

// 챌린지 검색
// TODO: 챌린지 아이디 부분 수정
class SearchChallengeModel {
  final int challengeId;
  final String title;
  final int participantNumber;
  final int requiredWeeklyCount;
  final bool photoRequired;
  final List<ChallengeTagModel> tags;

  SearchChallengeModel({
    required this.challengeId,
    required this.title,
    required this.participantNumber,
    required this.requiredWeeklyCount,
    required this.photoRequired,
    required this.tags,
  });

  factory SearchChallengeModel.fromJson(Map<String, dynamic> json) {
    return SearchChallengeModel(
      challengeId: json['id'] ?? 0,
      title: json['title'] ?? '',
      participantNumber: json['participantNumber'] ?? 0,
      requiredWeeklyCount: json['requiredWeeklyCount'] ?? 0,
      photoRequired: json['photoRequired'] ?? true,
      tags: (json['tags'] as List? ?? [])
          .map((t) => ChallengeTagModel.fromJson(t))
          .toList(),
    );
  }
}

// 태그 모델
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

// 챌린지 초대 탭 응답 모델 (GET /api/challenges/{challengeId}/invite)
class ChallengeInviteResponse {
  final String challengeLink; // 초대 링크
  final List<ChallengeInviteFriend> friends; // 친구 목록 (초대 상태 포함)

  ChallengeInviteResponse({required this.challengeLink, required this.friends});

  factory ChallengeInviteResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeInviteResponse(
      // 초대 링크 매핑
      challengeLink: json['inviteLink'] ?? '',

      friends: ((json['responseList'] ?? []) as List)
          .map((e) => ChallengeInviteFriend.fromJson(e))
          .toList(),
    );
  }
}

class ChallengeInviteFriend {
  final int userId;
  final String nickname;
  final String? profileImageUrl;
  final bool isInvited; // 이미 초대되었는지 여부

  ChallengeInviteFriend({
    required this.userId,
    required this.nickname,
    this.profileImageUrl,
    required this.isInvited,
  });

  factory ChallengeInviteFriend.fromJson(Map<String, dynamic> json) {
    return ChallengeInviteFriend(
      // API 명세: a. 유저id
      userId: json['userId'] ?? 0,
      // API 명세: b. 유저 닉네임
      nickname: json['nickname'] ?? '',
      // API 명세: b. 유저 프로필 이미지 url
      profileImageUrl: json['profileImageUrl'],
      // API 명세: c. 이미 해당 챌린지에 초대되었는지에 대한 여부
      // 초대 상태 체크 ('INVITED' 문자열이거나 true일 경우)
      isInvited: json['inviteStatus'] == 'INVITED',
    );
  }
}
