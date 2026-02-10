// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';
import '../models/signup_state.dart';
import 'package:haenaem/features/auth/signup/widgets/signup_page_layout.dart';
import 'package:haenaem/shared/widgets/app_tag_chip.dart';

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
    // 서버에 태그 ID 리스트 전송
    final success = await ref.read(signupProvider.notifier).submitTags();

    if (!mounted) return;

    if (success) {
      widget.onNext(); // 성공 시 '성공 화면'으로!
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('태그 저장에 실패했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 리버팟에서 서버로부터 분류된 태그 데이터를 감시
    final signupState = ref.watch(signupProvider);
    final categorizedTags = signupState.categorizedTags;
    final selectedTags = ref.watch(signupProvider).tags;

    return SignupPageLayout(
      title: '태그를 통해\n관심 분야를 알려주세요',
      subTitle: '관심 태그를 2~6개 골라주세요',
      isButtonEnabled:
          selectedTags.length >= 2 &&
          selectedTags.length <= 6 &&
          !signupState.isLoading,
      onNext: _handleNext,
      child: categorizedTags.isEmpty
          ? const Center(child: CircularProgressIndicator()) // 데이터 로딩 중 표시
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categorizedTags.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: AppTypography.b2.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: entry.value.map((tagName) {
                          return AppTagChip(
                            label: tagName,
                            isSelected: selectedTags.contains(tagName),
                            // 클릭 시 프로바이더의 토글 함수 호출
                            onTap: () => ref
                                .read(signupProvider.notifier)
                                .toggleTag(tagName),
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
