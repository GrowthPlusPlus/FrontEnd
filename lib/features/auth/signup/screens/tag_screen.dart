// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/auth/signup/widgets/signup_page_layout.dart';
import 'package:haenaem/shared/models/tag_data.dart';
import 'package:haenaem/shared/widgets/app_tag_chip.dart';

// 태그 설정 화면
class TagScreen extends StatefulWidget {
  final VoidCallback onNext;

  const TagScreen({super.key, required this.onNext});

  @override
  State<TagScreen> createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  // 선택된 태그들을 담는 리스트
  final List<String> _selectedTags = [];

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else if (_selectedTags.length < 6) {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled =
        _selectedTags.length >= 2 && _selectedTags.length <= 6;

    return SignupPageLayout(
      title: '태그를 통해\n관심 분야를 알려주세요',
      subTitle: '관심 태그를 2~6개 골라주세요',
      isButtonEnabled: isButtonEnabled,
      onNext: widget.onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: TagData.categories.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: AppTypography.b2.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: entry.value.map((tag) {
                    return AppTagChip(
                      label: tag,
                      isSelected: _selectedTags.contains(tag),
                      onTap: () => _toggleTag(tag),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
