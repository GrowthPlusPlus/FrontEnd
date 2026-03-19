// // 최초 작성자 : 김채영
// import 'package:flutter/material.dart';
// import 'package:haenaem/core/theme/app_colors.dart';
// import 'package:haenaem/core/theme/app_typography.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/services.dart'; // 클립보드 복사
// import 'package:share_plus/share_plus.dart'; // 공유
// import 'package:haenaem/features/challenge/model/challenge_model.dart'; // 💡 Response 및 Friend 모델 임포트

// // 챌린지 생성 성공했을 경우 띄우는 작은 화면
// class ChallengeCreateSuccessDialog extends StatefulWidget {
//   // 💡 response 모델 전체를 넘겨받습니다.
//   final ChallengeCreateResponse createdData;

//   const ChallengeCreateSuccessDialog({super.key, required this.createdData});

//   @override
//   State<ChallengeCreateSuccessDialog> createState() =>
//       _ChallengeCreateSuccessDialogState();
// }

// // 챌린지 생성 성공 화면의 로직 및 상태 관리 클래스
// class _ChallengeCreateSuccessDialogState
//     extends State<ChallengeCreateSuccessDialog> {
//   // 💡 초대한 친구들의 ID를 저장 (FriendModel의 id 타입에 맞춰 dynamic 또는 int/String 설정)
//   final Set<dynamic> _invitedFriends = {};

//   // 💡 모델의 친구 데이터를 기반으로 필터링 리스트 관리
//   List<FriendModel> _filteredFriends = [];

//   // 검색창 제어를 위한 컨트롤러
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // 💡 초기에는 모델에서 받은 실제 친구 목록을 보여주기
//     _filteredFriends = widget.createdData.friends;

//     // 검색창 입력 감지 리스너 추가
//     _searchController.addListener(onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // 초대 버튼 누를 경우 뜨는 토스트 메시지
//   void _showToast(BuildContext context, String name) {
//     OverlayEntry overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         bottom: 100,
//         left: 20,
//         right: 20,
//         child: Material(
//           color: Colors.transparent,
//           child: Center(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               decoration: ShapeDecoration(
//                 color: const Color(0xff1B1D1B).withAlpha(200),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 '$name 님에게 챌린지 초대를 보냈습니다!',
//                 textAlign: TextAlign.center,
//                 style: AppTypography.b1.copyWith(color: Colors.white),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context).insert(overlayEntry);

//     Future.delayed(const Duration(seconds: 2), () {
//       overlayEntry.remove();
//     });
//   }

//   // 클립보드 복사 로직: 실제 응답받은 링크 사용
//   void copyToClipboard(BuildContext context) {
//     Clipboard.setData(
//       ClipboardData(text: widget.createdData.challengeLink),
//     ).then((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('링크가 클립보드에 복사되었습니다.'),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     });
//   }

//   // 공유창 로직: 실제 응답받은 링크 사용
//   void shareChallenge(BuildContext context) async {
//     final box = context.findRenderObject() as RenderBox?;

//     await Share.share(
//       '[해냄] 새로운 챌린지에 초대받았어요!\n지금 바로 확인해보세요: ${widget.createdData.challengeLink}',
//       subject: '해냄 챌린지 초대',
//       sharePositionOrigin: box != null
//           ? box.localToGlobal(Offset.zero) & box.size
//           : null,
//     );
//   }

//   // 검색 로직: 입력값이 바뀔 때마다 FriendModel 리스트를 필터링
//   void onSearchChanged() {
//     String query = _searchController.text.toLowerCase();
//     setState(() {
//       if (query.isEmpty) {
//         _filteredFriends = widget.createdData.friends;
//       } else {
//         _filteredFriends = widget.createdData.friends
//             .where((friend) => friend.nickname.toLowerCase().contains(query))
//             .toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       alignment: const Alignment(0, -0.3),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 20),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         width: double.infinity,
//         height: 600,
//         clipBehavior: Clip.antiAlias,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           children: [
//             buildGradientHeader(),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     buildLinkShareSection(),
//                     const SizedBox(height: 10),
//                     buildFriendSearchBar(),
//                     const SizedBox(height: 10),
//                     if (_filteredFriends.isEmpty)
//                       Center(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 20),
//                           child: Text(
//                             '검색 결과가 없습니다.',
//                             style: AppTypography.b2.copyWith(
//                               color: AppColors.gray3,
//                             ),
//                           ),
//                         ),
//                       )
//                     else
//                       ..._filteredFriends.map(
//                         (friend) => buildInviteItem(friend),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             buildLaterButton(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildGradientHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 24),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFF009951), Color(0xFF00C94D)],
//         ),
//       ),
//       child: Column(
//         children: [
//           SvgPicture.asset(
//             'assets/images/icons/challenge_create_success_check.svg',
//             width: 44,
//             height: 44,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             '챌린지 생성 완료!',
//             style: AppTypography.h2.copyWith(color: Colors.white),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '친구들을 초대해서 함께 도전해보세요',
//             style: AppTypography.b1.copyWith(
//               color: Colors.white.withAlpha(200),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildLinkShareSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '챌린지 링크 공유',
//           style: AppTypography.b2.copyWith(color: AppColors.gray1),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(10),
//           decoration: ShapeDecoration(
//             color: Colors.white,
//             shape: RoundedRectangleBorder(
//               side: const BorderSide(width: 1, color: AppColors.gray4),
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: Text(
//             // 💡 실제 응답받은 링크 텍스트 표시
//             widget.createdData.challengeLink,
//             style: AppTypography.c1.copyWith(color: const Color(0xFF3E7E60)),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: buildActionButton(
//                 label: '복사',
//                 color: AppColors.gray5,
//                 iconPath: 'assets/images/icons/link_copy.svg',
//                 onTap: (ctx) => copyToClipboard(ctx),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: buildActionButton(
//                 label: '공유',
//                 color: AppColors.gray5,
//                 iconPath: 'assets/images/icons/link_share.svg',
//                 onTap: (ctx) => shareChallenge(ctx),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget buildActionButton({
//     required String label,
//     required Color color,
//     required String iconPath,
//     required Function(BuildContext) onTap,
//   }) {
//     return Builder(
//       builder: (context) {
//         return GestureDetector(
//           onTap: () => onTap(context),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 8),
//             decoration: ShapeDecoration(
//               color: AppColors.gray5,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SvgPicture.asset(
//                   iconPath,
//                   width: 16,
//                   height: 16,
//                   colorFilter: const ColorFilter.mode(
//                     AppColors.gray2,
//                     BlendMode.srcIn,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   label,
//                   textAlign: TextAlign.center,
//                   style: AppTypography.b2.copyWith(color: AppColors.gray2),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget buildFriendSearchBar() {
//     return Container(
//       width: double.infinity,
//       height: 37.98,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: ShapeDecoration(
//         shape: RoundedRectangleBorder(
//           side: const BorderSide(width: 1, color: AppColors.gray3),
//           borderRadius: BorderRadius.circular(9.50),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SvgPicture.asset(
//             'assets/images/icons/friend_search.svg',
//             width: 18.99,
//             height: 18.99,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               style: AppTypography.b2.copyWith(color: AppColors.black),
//               decoration: InputDecoration(
//                 hintText: '친구 검색',
//                 hintStyle: AppTypography.b2.copyWith(color: AppColors.gray3),
//                 border: InputBorder.none,
//                 isDense: true,
//                 contentPadding: EdgeInsets.zero,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 💡 FriendModel 객체를 받아 스타일대로 렌더링
//   Widget buildInviteItem(FriendModel friend) {
//     bool isInvited = _invitedFriends.contains(friend.id);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 0),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
//       child: Row(
//         children: [
//           // 💡 프로필 이미지 연동 (null일 경우 기본 색상)
//           CircleAvatar(
//             radius: 20,
//             backgroundColor: const Color(0xFFD9D9D9),
//             backgroundImage: friend.profileImageUrl != null
//                 ? NetworkImage(friend.profileImageUrl!)
//                 : null,
//           ),
//           const SizedBox(width: 10),
//           Text(
//             friend.nickname,
//             style: AppTypography.b2.copyWith(color: AppColors.black),
//           ),
//           const Spacer(),
//           GestureDetector(
//             onTap: isInvited
//                 ? null
//                 : () {
//                     setState(() {
//                       _invitedFriends.add(friend.id);
//                     });
//                     _showToast(context, friend.nickname);
//                   },
//             child: isInvited ? buildInvitedButton() : buildActiveInviteButton(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildInvitedButton() {
//     return Container(
//       width: 54.08,
//       height: 33.99,
//       decoration: ShapeDecoration(
//         color: AppColors.disable,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       child: Center(
//         child: Text(
//           '초대함',
//           textAlign: TextAlign.center,
//           style: AppTypography.c1.copyWith(color: AppColors.gray2),
//         ),
//       ),
//     );
//   }

//   Widget buildActiveInviteButton() {
//     return Container(
//       width: 54.08,
//       height: 33.99,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: AppColors.primaryAble,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text('초대', style: AppTypography.c1.copyWith(color: Colors.white)),
//     );
//   }

//   Widget buildLaterButton(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       child: GestureDetector(
//         onTap: () => Navigator.pop(context),
//         child: Container(
//           width: double.infinity,
//           height: 44,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.gray2),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             '나중에 초대하기',
//             style: AppTypography.b1.copyWith(color: AppColors.gray2),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/models/challenge_model.dart';
import 'package:haenaem/features/challenge/invite/widgets/challenge_invite_content.dart';

class ChallengeCreateSuccessDialog extends StatelessWidget {
  final ChallengeCreateResponse createdData;

  const ChallengeCreateSuccessDialog({super.key, required this.createdData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: const Alignment(0, -0.3),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        height: 600, // 전체 높이 유지
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // 1. 상단 그라데이션 헤더 (김채영님 스타일 유지)
            _buildGradientHeader(),

            // 2. 본문 (정승빈님의 InviteContent 위젯 사용)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ChallengeInviteContent(
                  challengeId: createdData.id,
                  challengeUrl: createdData.challengeLink,
                ),
              ),
            ),

            // 3. 하단 닫기 버튼 (김채영님 스타일 유지)
            _buildLaterButton(context),
          ],
        ),
      ),
    );
  }

  // 상단 그라데이션 헤더
  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF009951), Color(0xFF00C94D)],
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/icons/challenge_create_success_check.svg',
            width: 44,
            height: 44,
          ),
          const SizedBox(height: 12),
          Text(
            '챌린지 생성 완료!',
            style: AppTypography.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '친구들을 초대해서 함께 도전해보세요',
            style: AppTypography.b1.copyWith(
              color: Colors.white.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  // 나중에 초대하기 버튼
  Widget _buildLaterButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '나중에 초대하기',
            style: AppTypography.b1.copyWith(color: AppColors.gray2),
          ),
        ),
      ),
    );
  }
}
