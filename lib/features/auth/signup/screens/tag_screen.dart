// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';
import '../models/signup_state.dart';
import 'package:haenaem/features/auth/signup/widgets/signup_page_layout.dart';
import 'package:haenaem/shared/widgets/app_tag_chip.dart';
import 'package:haenaem/shared/models/tag_data.dart';

// 태그 설정 화면
class TagScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const TagScreen({super.key, required this.onNext});

  @override
  ConsumerState<TagScreen> createState() => _TagScreenState();
}

class _TagScreenState extends ConsumerState<TagScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 서버에서 태그 목록을 가져오기.
    Future.microtask(() => ref.read(signupProvider.notifier).fetchAllTags());
  }

  Future<void> _handleNext() async {
    // 💡 개별 submitTags() 호출을 지우고, 전체 가입 로직을 호출합니다.
    final success = await ref.read(signupProvider.notifier).submitSignup();

    if (!mounted) return;

    if (success) {
      widget.onNext(); // 성공 시 폭죽 화면으로!
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 처리 중 오류가 발생했습니다. (닉네임 중복 등)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupProvider);
    final categorizedTags = signupState.categorizedTags;
    final selectedTags = signupState.tags;

    // 카테고리 정렬 키 리스트 생성
    final sortedCategoryKeys = categorizedTags.keys.toList()
      ..sort((a, b) {
        final indexA = TagMapper.categoryOrder.indexOf(a);
        final indexB = TagMapper.categoryOrder.indexOf(b);
        // 정의되지 않은 카테고리는 맨 뒤로
        return (indexA == -1 ? 99 : indexA).compareTo(
          indexB == -1 ? 99 : indexB,
        );
      });

    return SignupPageLayout(
      title: '태그를 통해\n관심 분야를 알려주세요',
      subTitle: '관심 태그를 2~6개 골라주세요',
      isButtonEnabled: signupState.isTagsValid && !signupState.isLoading,
      onNext: _handleNext,
      child: categorizedTags.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sortedCategoryKeys.map((categoryKey) {
                // 해당 카테고리의 태그 리스트 가져오기 및 내부 정렬
                final tagNames = List<String>.from(
                  categorizedTags[categoryKey]!,
                );

                if (TagMapper.tagInternalOrder.containsKey(categoryKey)) {
                  final orderList = TagMapper.tagInternalOrder[categoryKey]!;
                  tagNames.sort((a, b) {
                    final indexA = orderList.indexOf(a);
                    final indexB = orderList.indexOf(b);
                    return (indexA == -1 ? 99 : indexA).compareTo(
                      indexB == -1 ? 99 : indexB,
                    );
                  });
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TagMapper.getKoreanCategory(categoryKey),
                        style: AppTypography.b2.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: tagNames.map((tagName) {
                          return AppTagChip(
                            label: tagName,
                            isSelected: selectedTags.contains(tagName),
                            onTap: () {
                              Future.microtask(() {
                                if (mounted) {
                                  ref
                                      .read(signupProvider.notifier)
                                      .toggleTag(tagName);
                                }
                              });
                            },
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
