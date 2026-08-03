// 최초 작성자 : 강선욱
// 피드 인증글의 스타일을 정의한 클래스
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/features/feed/screens/post_detail_screen.dart'; // 인증글 상세 불러오기
import 'package:intl/intl.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
//import 'package:haenaem/features/challenge/models/challenge_model.dart';
import '../provider/post_detail_provider.dart';
import 'package:haenaem/shared/models/post.dart';
import 'package:haenaem/features/feed/widgets/post_popup_menu.dart';
import 'package:haenaem/shared/widgets/slider_indicator.dart';

class FeedPostCard extends ConsumerWidget {
  final Post post;
  final VoidCallback? onTap;
  final dynamic provider; // 어떤 Provider(친구/둘러보기)인지 받음

  const FeedPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    /*
    final displayDate = post.updatedAt ?? post.createdAt;

    String formattedDate = displayDate != null
        ? DateFormat('yyyy년 MM월 dd일 HH:mm').format(displayDate)
        : "";
      */
    // 💡 날짜 처리: post.date 하나로 통합
    String formattedDate = DateFormat('yyyy년 MM월 dd일 HH:mm').format(post.date);

    return InkWell(
      onTap:
          onTap ??
          () async {
            // 상세 페이지로 이동하고, 상세 페이지가 pop(닫힘) 될 때까지 기다립니다.
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(
                  postId: post.id,
                  post: post,
                  feedProvider: provider, // 기존에 넘겨주던 프로바이더
                ),
              ),
            );
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20, // 반지름
                  backgroundImage:
                      (post.writer.profileUrl != null &&
                          post.writer.profileUrl!.isNotEmpty)
                      ? NetworkImage(post.writer.profileUrl!) as ImageProvider
                      : null,
                  child:
                      (post.writer.profileUrl == null ||
                          post.writer.profileUrl!.isEmpty)
                      ? SvgPicture.asset(
                          'assets/images/icons/default_profile_icon.svg',
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.writer.nickname, style: AppTypography.b1),
                    ],
                  ),
                ),
                PostPopupMenu(post: post),
              ],
            ),
          ),
          // 2. 텍스트 본문
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        post.title,
                        style: AppTypography.b3.copyWith(
                          color: appColors.blackToWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (post.isEdited)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text(
                          '수정됨',
                          style: AppTypography.b2.copyWith(
                            color: appColors.gray3,
                          ), // 조금 연한 회색 스타일 적용
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4), // 간격 추가
                Text(
                  post.content,
                  style: AppTypography.b1.copyWith(color: appColors.gray1),
                  // 사진이 없을 때는 본문을 더 길게 보여줘도 좋습니다.
                  maxLines: post.hasImage ? 3 : 10,
                  overflow: TextOverflow.ellipsis,
                ),
                // 사진이 없을 때는 하단 아이콘과의 간격을 확보합니다.
                if (!post.hasImage) const SizedBox(height: 15),
              ],
            ),
          ),
          // 3. 이미지
          if (post.hasImage && post.pictureUrl.isNotEmpty)
            _PostImageSlider(post: post),
          // 4. 하단 아이콘 정보
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    // [로컬 업데이트] 서버 응답 기다리지 않고 즉시 UI 변경
                    if (provider != null) {
                      ref.read(provider.notifier).toggleLikeLocally(post.id);
                    }

                    // [서버 통신] 백그라운드에서 조용히 처리
                    ref
                        .read(postLikeNotifierProvider.notifier)
                        .toggleLike(
                          postId: post.id,
                          isCurrentlyLiked: post.isLiked,
                        );
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        post.isLiked
                            ? 'assets/images/icons/like_filled_icon.svg'
                            : 'assets/images/icons/like_icon.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          post.isLiked
                              ? appColors.notification
                              : appColors.gray2,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.likeCount.toString(),
                        style: AppTypography.b2.copyWith(
                          color: post.isLiked
                              ? appColors.notification
                              : appColors.gray2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildIconInfo(
                  'assets/images/icons/comment_icon.svg',
                  post.commentCount.toString(),
                  appColors,
                ),
                const Spacer(),
                Text(
                  formattedDate,
                  style: AppTypography.b2.copyWith(color: appColors.gray2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconInfo(
    String iconPath,
    String count,
    AppColorsExtension appColors,
  ) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(appColors.gray2, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Text(count, style: AppTypography.b2.copyWith(color: appColors.gray2)),
      ],
    );
  }
}

// 이미지 슬라이더와 인디케이터 상태를 관리하기 위한 내부 위젯
class _PostImageSlider extends StatefulWidget {
  final Post post;

  const _PostImageSlider({required this.post});

  @override
  State<_PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<_PostImageSlider> {
  int _currentImagePage = 0; // 인디케이터 상태 관리

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      children: [
        SizedBox(
          height: 375, // 기존 FeedPostCard 이미지 높이와 통일
          width: double.infinity,
          child: PageView.builder(
            itemCount: widget.post.pictureUrl.length,
            onPageChanged: (index) {
              setState(() {
                _currentImagePage = index;
              });
            },
            itemBuilder: (context, index) {
              final String path = widget.post.pictureUrl[index].imageUrl;

              // 아래 부분은 백엔드 데이터가 어떤 형태로 들어오든 앱에서 이미지 에러(엑스박스) 안 나고 무조건 안전하게 주소를 완성해서 띄우기 위함
              // dioProvider를 사용해 현재 활성화된 baseUrl을 동적으로 가져옵니다.
              // Stateful 내부이므로 Consumer 위젯으로 감싸서 ref를 쓰거나, 아래처럼 1회성으로 읽어올 수 있습니다.
              final container = ProviderScope.containerOf(context);
              final dioBaseUrl = container.read(dioProvider).options.baseUrl;

              // 경로 처리: http로 시작하지 않으면 동적 baseUrl을 붙여주기
              final String fullUrl = path.startsWith('http')
                  ? path
                  : '$dioBaseUrl$path';

              return Image.network(
                fullUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: appColors.gray5,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: appColors.gray5,
                    child: Center(
                      child: Icon(Icons.broken_image, color: appColors.gray3),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // 이미지가 2장 이상일 때만 하단에 페이지 점(Indicator) 표시
        if (widget.post.pictureUrl.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            child: SliderIndicator(
              count: widget.post.pictureUrl.length,
              currentIndex: _currentImagePage,
            ),
          ),
      ],
    );
  }
}
