// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/tag_model.dart';
import '../../../shared/widgets/tag_badge.dart';
import 'package:haenaem/shared/widgets/user_profile_circle.dart';

// 이미지, 닉네임, 소개글, 그리고 복잡했던 태그 정렬 로직
class ProfileHeaderView extends StatelessWidget {
  final String nickname;
  final String introduction;
  final String profileImageUrl;
  final List<String> tags;

  const ProfileHeaderView({
    super.key,
    required this.nickname,
    required this.introduction,
    required this.profileImageUrl,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImage(),
        const SizedBox(height: 17),
        Text(nickname, style: AppTypography.h2),
        const SizedBox(height: 2),
        Text(
          introduction,
          style: AppTypography.b1.copyWith(color: AppColors.gray3),
        ),
        const SizedBox(height: 17),
        _buildTagList(tags),
      ],
    );
  }

  Widget _buildImage() {
    return UserProfileCircle(
      // URL이 비어있으면 null을 넘겨 UserProfileCircle이 기본 아이콘을 그리게 함.
      imageUrl: profileImageUrl.isNotEmpty ? profileImageUrl : null,
      size: 150,
    );
  }

  Widget _buildTagList(List<String> tags) {
    if (tags.isEmpty) return const SizedBox.shrink();

    // 1. 정렬 로직
    final List<String> sortedTags = List.from(tags);
    final priorityList = TagMapper.tagInternalOrder.values
        .expand((e) => e)
        .toList();
    sortedTags.sort((a, b) {
      final indexA = priorityList.indexOf(a);
      final indexB = priorityList.indexOf(b);
      return (indexA == -1 ? 99 : indexA).compareTo(indexB == -1 ? 99 : indexB);
    });

    // 2. 태그 리스트를 3개씩 묶기 (Chunking)
    List<List<String>> rows = [];
    for (var i = 0; i < sortedTags.length; i += 3) {
      rows.add(
        sortedTags.sublist(
          i,
          i + 3 > sortedTags.length ? sortedTags.length : i + 3,
        ),
      );
    }

    // 3. UI 생성 (Column 안에 Row 배치)
    return Column(
      children: rows.map((rowTags) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0), // 줄 사이(세로) 간격
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
            children: [
              for (int i = 0; i < rowTags.length; i++) ...[
                TagBadge(label: rowTags[i]),
                if (i != rowTags.length - 1)
                  const SizedBox(width: 10), // 태그 사이(가로) 간격 10
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
