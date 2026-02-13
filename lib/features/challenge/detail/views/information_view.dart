import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/challenge/detail/widgets/challenge_detail_content.dart';

// class InformationView extends ConsumerWidget {
//   final int challengeId;
//   final ScrollController scrollController;

//   const InformationView({
//     super.key,
//     required this.challengeId,
//     required this.scrollController,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 1. Provider 구독 (ID 전달)
//     final challengeAsync = ref.watch(
//       challengeDetailProvider(challengeId: challengeId),
//     );

//     // 2. AsyncValue 상태에 따른 대응
//     return challengeAsync.when(
//       loading: () => const Center(
//         child: CircularProgressIndicator(color: AppColors.primaryAble),
//       ),
//       error: (error, stack) => Center(
//         child: Text(
//           '데이터를 불러오지 못했습니다.\n잠시 후 다시 시도해주세요.',
//           textAlign: TextAlign.center,
//           style: AppTypography.b1.copyWith(color: AppColors.gray2),
//         ),
//       ),
//       data: (challenge) {
//         String formattedStart = challenge.startDate.isNotEmpty
//             ? DateFormat(
//                 'yyyy년 MM월 dd일',
//               ).format(DateTime.parse(challenge.startDate))
//             : "";
//         String formattedEnd = challenge.endDate.isNotEmpty
//             ? DateFormat(
//                 'yyyy년 MM월 dd일',
//               ).format(DateTime.parse(challenge.endDate))
//             : "";

//         String dDayString = "";
//         if (challenge.endDate.isNotEmpty) {
//           DateTime end = DateTime.parse(challenge.endDate);
//           DateTime now = DateTime.now();

//           // 시간 정보를 제외하고 날짜만 비교하기 위해 정리 (옵션)
//           DateTime today = DateTime(now.year, now.month, now.day);
//           DateTime targetDay = DateTime(end.year, end.month, end.day);

//           int difference = targetDay.difference(today).inDays;

//           if (difference == 0) {
//             dDayString = "(D-Day)";
//           } else if (difference > 0) {
//             dDayString = "(D-$difference)";
//           } else {
//             dDayString = "(종료됨)";
//           }
//         }

//         // 성공적으로 데이터를 가져온 경우
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: SingleChildScrollView(
//             controller: scrollController,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 챌린지 제목
//                 Text(
//                   challenge.title,
//                   style: AppTypography.h3.copyWith(color: AppColors.black),
//                 ),
//                 const SizedBox(height: 24), // 제목과 아래 정보 사이 간격

//                 _buildInfoSection('챌린지 시작일', formattedStart),
//                 // 날짜 데이터가 모델에 추가되기 전이므로 임시 텍스트 유지 (D-Day는 활용 가능)
//                 _buildInfoSection('챌린지 마감일', '$formattedEnd $dDayString'),
//                 _buildInfoSection('인증 빈도', '매일'),

//                 Text(
//                   '챌린지 태그',
//                   style: AppTypography.b1.copyWith(color: AppColors.gray2),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     _buildTag('label'), // 추후 List<String> tags 등이 생기면 map으로 구현
//                     const SizedBox(width: 8),
//                     _buildTag('label'),
//                   ],
//                 ),

//                 const _CustomDivider(),

//                 Text(
//                   '챌린지 설명',
//                   style: AppTypography.b1.copyWith(color: AppColors.gray2),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   challenge.description, // 모델의 content 연결
//                   style: AppTypography.b1.copyWith(
//                     color: AppColors.black,
//                     height: 1.5,
//                   ),
//                 ),

//                 const _CustomDivider(),

//                 Text(
//                   '방장',
//                   style: AppTypography.b1.copyWith(color: AppColors.gray2),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     // 방장 프로필 이미지 처리
//                     SizedBox(
//                       width: 36,
//                       height: 36,
//                       child: ClipOval(
//                         child: challenge.host.profileImageUrl.isNotEmpty
//                             ? Image.network(
//                                 challenge.host.profileImageUrl,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     SvgPicture.asset(
//                                       'assets/images/icons/default_profile_icon.svg',
//                                     ),
//                               )
//                             : SvgPicture.asset(
//                                 'assets/images/icons/default_profile_icon.svg',
//                               ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     // 방장 이름
//                     Text(
//                       challenge.host.name,
//                       style: AppTypography.b1.copyWith(color: AppColors.black),
//                     ),
//                   ],
//                 ),

//                 const _CustomDivider(),

//                 // 5. 참여자 수 섹션 (아이콘 포함)
//                 Row(
//                   children: [
//                     const Icon(Icons.person, size: 18, color: AppColors.black),
//                     const SizedBox(width: 4),
//                     Text(
//                       '참여자 수',
//                       style: AppTypography.b1.copyWith(color: AppColors.gray2),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '${challenge.participantCount}명',
//                   style: AppTypography.b1.copyWith(color: AppColors.black),
//                 ),

//                 const _CustomDivider(),

//                 Text(
//                   '오늘의 인증자',
//                   style: AppTypography.b1.copyWith(color: AppColors.gray2),
//                 ),
//                 const SizedBox(height: 12),
//                 challenge.todaySuccessUsers.isEmpty
//                     ? Text(
//                         '아직 오늘의 인증자가 없습니다.',
//                         style: AppTypography.b1.copyWith(
//                           color: AppColors.gray2,
//                         ),
//                       )
//                     : SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         clipBehavior: Clip.none,
//                         child: Row(
//                           children: challenge.todaySuccessUsers.map((user) {
//                             return _buildAttendee(
//                               user.name,
//                               user.profileImageUrl,
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // --- 내부 컴포넌트 위젯 (기존 코드 유지) ---
//   Widget _buildInfoSection(String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: AppTypography.b1.copyWith(color: AppColors.gray2)),
//           const SizedBox(height: 4),
//           Text(
//             content,
//             style: AppTypography.b1.copyWith(color: AppColors.black),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTag(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE8F5E9), // 시안의 연그린
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Text(
//         text,
//         style: AppTypography.b2.copyWith(
//           color: AppColors.primaryAble,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendee(String name, String imageUrl) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 15),
//       child: Column(
//         children: [
//           SizedBox(
//             width: 48,
//             height: 48,
//             child: ClipOval(
//               child: imageUrl.isNotEmpty
//                   ? Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) =>
//                           SvgPicture.asset(
//                             'assets/images/icons/default_profile_icon.svg',
//                           ),
//                     )
//                   : SvgPicture.asset(
//                       'assets/images/icons/default_profile_icon.svg',
//                     ),
//             ),
//           ),
//           const SizedBox(height: 6),
//           SizedBox(
//             width: 50,
//             child: Text(
//               name,
//               style: AppTypography.c1.copyWith(color: AppColors.black),
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // 일관된 간격의 구분선
// class _CustomDivider extends StatelessWidget {
//   const _CustomDivider();

//   @override
//   Widget build(BuildContext context) {
//     return const Padding(
//       padding: EdgeInsets.symmetric(vertical: 20),
//       child: Divider(height: 1, thickness: 1, color: AppColors.gray4),
//     );
//   }
// }

class InformationView extends ConsumerWidget {
  final int challengeId;
  final ScrollController scrollController;

  const InformationView({
    super.key,
    required this.challengeId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(
      challengeDetailProvider(challengeId: challengeId),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: challengeAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryAble),
        ),
        error: (error, stack) => Center(
          child: Text(
            '데이터를 불러오지 못했습니다.\n잠시 후 다시 시도해주세요.',
            textAlign: TextAlign.center,
            style: AppTypography.b1.copyWith(color: AppColors.gray2),
          ),
        ),
        data: (challenge) => ChallengeDetailContent(
          challenge: challenge,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(height: 1, thickness: 1, color: AppColors.gray4),
    );
  }
}
