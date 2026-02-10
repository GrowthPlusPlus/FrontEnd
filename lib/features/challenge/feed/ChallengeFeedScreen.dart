// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:haenaem/features/challenge/widgets/UserChallengeData.dart'; // 모델 경로 확인
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/widgets/ChallengeFeedPopupMenu.dart';

class ChallengeFeedScreen extends StatefulWidget {
  final CertificationPost post;

  const ChallengeFeedScreen({super.key, required this.post});

  @override
  State<ChallengeFeedScreen> createState() => _ChallengeFeedScreenState();
}

class _ChallengeFeedScreenState extends State<ChallengeFeedScreen> {
  // 1. 텍스트 제어를 위한 컨트롤러 선언
  final TextEditingController _commentController = TextEditingController();
  bool _isButtonActive = false; // 버튼 활성화 상태 추적

  @override
  void initState() {
    super.initState();
    // 2. 리스너를 추가하여 텍스트가 바뀔 때마다 버튼 상태 업데이트
    _commentController.addListener(() {
      setState(() {
        _isButtonActive = _commentController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 날짜 포맷팅
    String formattedDate = DateFormat(
      'yyyy년 MM월 dd일 HH:mm',
    ).format(widget.post.date);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '피드',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 게시글 상단 (프로필/헤더) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 5, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    // 데이터 모델에 profileUrl이 있다면 사용, 없으면 기본 아이콘
                    child: SvgPicture.asset(
                      'assets/images/icons/default_profile_icon.svg',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName ?? 'Growth', // 1. 데이터 반영
                          style: AppTypography.b1.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '초보 모험가', // 칭호 시스템이 있다면 post.userBadge 등으로 대체 가능
                          style: AppTypography.c1.copyWith(
                            color: AppColors.gray2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ChallengeFeedPopupMenu(),
                ],
              ),
            ),

            // --- 게시물 본문 텍스트 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  // 인증글 본문 데이터 반영
                  Text(
                    widget.post.content,
                    style: AppTypography.b2.copyWith(color: AppColors.gray1),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),

            // --- 게시물 이미지 ---
            if (widget.post.hasImage && widget.post.imageUrl != null)
              Image.asset(
                widget.post.imageUrl!,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: AppColors.disable,
                  child: const Icon(Icons.error),
                ),
              ),

            // --- 좋아요 및 댓글 수 정보 ---
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
              child: Row(
                children: [
                  // 1. 좋아요 섹션
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/like_icon.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.gray2,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.post.likeCount}',
                          style: AppTypography.b2.copyWith(
                            color: AppColors.gray2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 2. 댓글 섹션
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/icons/comment_icon.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.gray2,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.post.comments.length}', // 2. 댓글 리스트 길이를 자동으로 반영
                          style: AppTypography.b2.copyWith(
                            color: AppColors.gray2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 3. 날짜 정보
                  Text(
                    formattedDate,
                    style: AppTypography.b2.copyWith(color: AppColors.gray2),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 1),

            // --- 댓글 리스트 (post.comments 데이터를 순회하며 생성) ---
            if (widget.post.comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    '첫 댓글을 남겨보세요!',
                    style: AppTypography.b2.copyWith(color: AppColors.gray1),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.post.comments.length,
                itemBuilder: (context, index) {
                  final comment = widget.post.comments[index];
                  return _buildCommentItem(comment); // 3. 댓글 객체 전달
                },
              ),

            const SizedBox(height: 80),

            const Divider(thickness: 1),
          ],
        ),
      ),

      bottomSheet: _buildCommentInputField(),
    );
  }

  // 댓글 입력창
  Widget _buildCommentInputField() {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: systemBottomPadding + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController, // 컨트롤러 연결
              decoration: InputDecoration(
                hintText: '댓글을 입력하세요...',
                hintStyle: AppTypography.b2.copyWith(color: AppColors.gray3),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.gray4.withAlpha(150),
                    width: 0.75,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.gray4.withAlpha(150),
                    width: 0.75,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 3. 버튼 활성화 상태에 따라 색상 및 동작 변경
          GestureDetector(
            onTap: _isButtonActive
                ? () {
                    // 전송 로직 실행
                    print("댓글 전송: ${_commentController.text}");
                    _commentController.clear(); // 전송 후 입력창 비우기
                  }
                : null, // 비활성화 시 클릭 안됨
            child: CircleAvatar(
              radius: 22.5, // 45px 크기 유지를 위해 절반 값 설정
              backgroundColor: _isButtonActive
                  ? AppColors
                        .primaryAble // 활성화 시 초록색
                  : AppColors.disable, // 비활성화 시 회색
              child: SvgPicture.asset(
                'assets/images/icons/comment_upload_icon.svg',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 댓글 아이템 빌더 (모델 기반 수정)
  Widget _buildCommentItem(ChallengeComment comment) {
    String commentDate = DateFormat(
      'yyyy년 MM월 dd일 HH:mm',
    ).format(comment.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬 유지
        children: [
          // 1. 프로필 이미지
          SvgPicture.asset(
            'assets/images/icons/default_profile_icon.svg',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 12),

          // 2. 댓글 본문 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start, // 아이콘과 이름 상단 맞춤
                  children: [
                    // 이름과 뱃지를 하나의 Column으로 묶어 아이콘 공간 확보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.userName,
                            style: AppTypography.b1.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 2), // 이름과 뱃지 사이 간격
                          Text(
                            comment.userBadge,
                            style: AppTypography.c1.copyWith(
                              color: AppColors.gray2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 더보기 버튼: IconButton의 여백 문제를 피하기 위해 GestureDetector 사용
                    GestureDetector(
                      onTap: () {
                        // 메뉴 액션
                      },
                      child: SvgPicture.asset(
                        'assets/images/icons/dots_vert_icon.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5), // 텍스트 시작 전 간격 조절
                Text(
                  comment.content,
                  style: AppTypography.b2.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 5),
                Text(
                  commentDate,
                  style: AppTypography.c1.copyWith(color: AppColors.gray2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
