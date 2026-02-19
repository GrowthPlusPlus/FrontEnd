// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

import 'package:haenaem/features/challenge/widgets/ChallengeFeedPopupMenu.dart';
import 'package:haenaem/features/challenge/model/challenge_model.dart';
import 'package:haenaem/features/challenge/widgets/comment_popup_menu.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final CertificationPostModel post;
  final dynamic feedProvider;
  const PostDetailScreen({super.key, required this.post, this.feedProvider});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  // 1. 텍스트 제어를 위한 컨트롤러 선언
  final TextEditingController _commentController = TextEditingController();
  bool _isButtonActive = false; // 버튼 활성화 상태 추적
  int _currentImagePage = 0; // 현재 보고 있는 이미지의 인덱스를 저장할 변수

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
    // 데이터 구독
    final detailAsync = ref.watch(
      articleDetailProvider(postId: widget.post.postId),
    );
    final commentsAsync = ref.watch(
      articleCommentsProvider(postId: widget.post.postId),
    );

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
      // 로딩/에러/데이터 처리
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러올 수 없습니다: $err')),
        data: (latestPost) {
          final displayDate = latestPost.updatedAt ?? latestPost.createdAt;

          String formattedDate = displayDate != null
              ? DateFormat('yyyy년 MM월 dd일 HH:mm').format(displayDate)
              : "";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 게시글 상단 (프로필/헤더) ---
                _buildPostHeader(latestPost),
                _buildPostContent(latestPost),
                _buildPostImage(latestPost),
                _buildPostStats(formattedDate, latestPost),

                const Divider(thickness: 1),

                // --- 댓글 리스트 영역 ---
                commentsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('댓글 로드 실패')),
                  ),
                  data: (comments) {
                    if (comments.isEmpty) return _buildEmptyComments();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) =>
                          _buildCommentItem(comments[index]),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomSheet: _buildCommentInputField(),
    );
  }

  Widget _buildPostHeader(CertificationPostModel post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 5, 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child: post.userImageUrl != null && post.userImageUrl!.isNotEmpty
                  ? Image.network(
                      post.userImageUrl!,
                      fit: BoxFit.cover, // 사진이 찌그러지지 않게 꽉 채움
                      errorBuilder: (_, __, ___) => SvgPicture.asset(
                        'assets/images/icons/default_profile_icon.svg',
                        width: 40,
                        height: 40,
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/images/icons/default_profile_icon.svg',
                      width: 40,
                      height: 40,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.userName ?? '익명', style: AppTypography.b1),
                Text(
                  '챌린지 모험가',
                  style: AppTypography.c1.copyWith(color: AppColors.gray2),
                ),
              ],
            ),
          ),
          // 팝업 메뉴에도 최신 정보 전달
          ChallengeFeedPopupMenu(post: post),
        ],
      ),
    );
  }

  Widget _buildPostContent(CertificationPostModel post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        post.content,
        style: AppTypography.b2.copyWith(color: AppColors.gray1),
      ),
    );
  }

  Widget _buildPostImage(CertificationPostModel post) {
    debugPrint('📸 이미지 경로: ${post.imageUrl}');
    debugPrint('📸 이미지 존재 여부: ${post.hasImage}');

    // hasImage가 false이거나 url이 없으면 안 보임
    if (post.images.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 300, // 기존 높이 유지
          width: double.infinity,
          child: PageView.builder(
            itemCount: post.images.length,
            onPageChanged: (index) {
              // 💡 페이지가 바뀔 때마다 상태 업데이트 (인디케이터용)
              setState(() {
                _currentImagePage = index;
              });
            },
            itemBuilder: (context, index) {
              final String path = post.images[index].imageUrl;
              // 💡 경로 처리: http로 시작하지 않으면 서버 주소 붙여주기
              final String fullUrl = path.startsWith('http')
                  ? path
                  : 'https://hanaem.onrender.com$path';

              return Image.network(
                fullUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.gray5,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.gray5,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: AppColors.gray3),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // 💡 이미지가 2장 이상일 때만 하단에 페이지 점(Indicator) 표시
        if (post.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(post.images.length, (index) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // 현재 페이지면 브랜드 컬러, 아니면 회색
                    color: _currentImagePage == index
                        ? AppColors.primaryAble
                        : AppColors.gray4,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildPostStats(String date, CertificationPostModel post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
      child: Row(
        children: [
          // 💡 좋아요 아이콘 영역
          GestureDetector(
            onTap: () async {
              await ref
                  .read(articleLikeNotifierProvider.notifier)
                  .toggleLike(
                    postId: post.postId,
                    isCurrentlyLiked: post.liked,
                  );

              if (widget.feedProvider != null) {
                ref
                    .read(widget.feedProvider.notifier)
                    .toggleLikeLocally(post.postId);
              }
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  post.liked
                      ? 'assets/images/icons/like_filled_icon.svg' // 빨간 하트
                      : 'assets/images/icons/like_icon.svg', // 안 채워진 하트
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    post.liked ? AppColors.notification : AppColors.gray2,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  post.likeNumber.toString(),
                  style: AppTypography.b2.copyWith(
                    color: post.liked
                        ? AppColors.notification
                        : AppColors.gray2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildStatIcon(
            'assets/images/icons/comment_icon.svg',
            post.commentNumber.toString(),
          ),
          const Spacer(),
          Text(date, style: AppTypography.b2.copyWith(color: AppColors.gray2)),
        ],
      ),
    );
  }

  Widget _buildStatIcon(String iconPath, String count) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 20,
          colorFilter: const ColorFilter.mode(AppColors.gray2, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Text(count, style: AppTypography.b2.copyWith(color: AppColors.gray2)),
      ],
    );
  }

  Widget _buildEmptyComments() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          '첫 댓글을 남겨보세요!',
          style: AppTypography.b2.copyWith(color: AppColors.gray1),
        ),
      ),
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
              autofocus: false, // 화면 리빌드될 때마다 키보드 불러오지 않기!
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
                ? () async {
                    // 💡 댓글 작성 API 호출
                    final contents = _commentController.text.trim();
                    final success = await ref
                        .read(articleCommentCreateNotifierProvider.notifier)
                        .addComment(
                          postId: widget.post.postId,
                          contents: contents,
                        );

                    if (success && mounted) {
                      // 피드 화면에서 댓글 수 업데이트를 위해 필요한 코드
                      if (widget.feedProvider != null) {
                        // 목록의 댓글 수를 로컬에서 +1 시켜서 UI를 즉시 갱신
                        ref
                            .read(widget.feedProvider.notifier)
                            .incrementCommentCountLocally(widget.post.postId);
                      }

                      // 성공 시 입력창 초기화 및 키보드 내리기
                      _commentController.clear();
                      FocusScope.of(context).unfocus();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('댓글이 작성되었습니다.')),
                      );
                    }
                  }
                : null,
            child: CircleAvatar(
              radius: 22.5,
              backgroundColor: _isButtonActive
                  ? AppColors.primaryAble
                  : AppColors.disable,
              child: SvgPicture.asset(
                'assets/images/icons/comment_upload_icon.svg',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 댓글 아이템 빌더
  Widget _buildCommentItem(ChallengeComment comment) {
    String commentDate = DateFormat(
      'yyyy년 MM월 dd일 HH:mm',
    ).format(comment.updatedAt ?? comment.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬 유지
        children: [
          // 프로필 이미지
          SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child:
                  comment.userPicture != null && comment.userPicture!.isNotEmpty
                  ? Image.network(
                      comment.userPicture!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => SvgPicture.asset(
                        'assets/images/icons/default_profile_icon.svg',
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/images/icons/default_profile_icon.svg',
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // 댓글 본문 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이름과 뱃지를 하나의 Column으로 묶어 아이콘 공간 확보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment.userNickname, style: AppTypography.b1),
                          Text(
                            '일반 모험가',
                            style: AppTypography.c1.copyWith(
                              color: AppColors.gray2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CommentPopupMenu(
                      postId: widget.post.postId, // 새로고침을 위해 필요
                      comment: comment,
                      // 피드 화면 댓글 수 업데이트를 위해 필요
                      feedProvider: widget.feedProvider,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(comment.contents, style: AppTypography.b2),
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
