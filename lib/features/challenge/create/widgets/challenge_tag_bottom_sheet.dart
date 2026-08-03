// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/shared/models/tag_model.dart';
import 'package:haenaem/shared/provider/tag_provider.dart';
// import 'package:haenaem/features/challenge/models/challenge_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/challenge/create/widgets/plus_button.dart';
import 'package:haenaem/shared/widgets/custom_bottom_sheet.dart';
import 'package:haenaem/shared/widgets/app_tag_chip.dart';

// 서버에서 태그 목록을 불러와 카테고리별로 표시하고 선택을 관리하는 바텀시트
class ChallengeTagBottomSheet extends ConsumerStatefulWidget {
  final List<ChallengeTagModel> initialSelectedTags;
  final Function(List<ChallengeTagModel> selectedTags) onCompleted;

  const ChallengeTagBottomSheet({
    super.key,
    required this.initialSelectedTags,
    required this.onCompleted,
  });

  @override
  ConsumerState<ChallengeTagBottomSheet> createState() =>
      _ChallengeTagBottomSheetState();
}

class _ChallengeTagBottomSheetState
    extends ConsumerState<ChallengeTagBottomSheet> {
  late List<ChallengeTagModel> _tempSelectedModels;

  final ScrollController _scrollController = ScrollController();
  bool _showShadow = true;

  @override
  void initState() {
    super.initState();
    _tempSelectedModels = List.from(widget.initialSelectedTags);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // 💡 3. 컨트롤러 해제
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 💡 4. 스크롤 위치에 따라 그림자 상태 업데이트 함수
  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_showShadow) setState(() => _showShadow = false);
    } else {
      if (!_showShadow) setState(() => _showShadow = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final tagsAsync = ref.watch(allTagsProvider);

    // 💡 화면 전체 높이의 95% 계산
    final screenHeight = MediaQuery.of(context).size.height;
    final targetHeight = screenHeight * 0.95;

    return Container(
      height: targetHeight, // 높이를 95%로 고정
      decoration: BoxDecoration(
        color: appColors.whiteToBlack,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text("태그 로드 실패")),
        data: (allTags) {
          final categorized = <String, List<ChallengeTagModel>>{};
          for (var tag in allTags) {
            categorized.putIfAbsent(tag.tagCategory, () => []).add(tag);
          }
          // 카테고리 정렬
          final sortedCategoryKeys = categorized.keys.toList()
            ..sort((a, b) {
              final indexA = TagMapper.categoryOrder.indexOf(a);
              final indexB = TagMapper.categoryOrder.indexOf(b);
              // 혹시 정의되지 않은 카테고리가 오면 뒤로 보냄
              return (indexA == -1 ? 99 : indexA).compareTo(
                indexB == -1 ? 99 : indexB,
              );
            });

          bool isButtonEnabled =
              _tempSelectedModels.isNotEmpty && _tempSelectedModels.length <= 2;

          return Column(
            // Column이 전체 높이를 다 쓰도록 설정
            children: [
              // 1. 상단 헤더 (타이틀 및 닫기 버튼)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 23,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      '챌린지 태그 선택',
                      style: AppTypography.h3.copyWith(
                        color: appColors.blackToWhite,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Text(
                        '×',
                        style: TextStyle(fontSize: 28, color: appColors.gray2),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // 2. 서브 타이틀
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '태그를 통해 관심 분야를 알려주세요\n1~2개를 골라주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appColors.blackToWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. 스크롤 가능한 태그 영역
              // 💡 Expanded를 사용하여 남은 모든 공간(95% 중 헤더와 버튼을 제외한 공간)을 차지하게 함
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedCategoryKeys.map((categoryKey) {
                      final tags = categorized[categoryKey]!;

                      // 카테고리 내부의 개별 태그 정렬
                      if (TagMapper.tagInternalOrder.containsKey(categoryKey)) {
                        final orderList =
                            TagMapper.tagInternalOrder[categoryKey]!;
                        tags.sort((a, b) {
                          final indexA = orderList.indexOf(a.tag);
                          final indexB = orderList.indexOf(b.tag);
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
                                color: appColors.blackToWhite,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: tags.map((tagModel) {
                                final isSelected = _tempSelectedModels.any(
                                  (t) => t.tagId == tagModel.tagId,
                                );
                                return AppTagChip(
                                  label: tagModel.tag,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _tempSelectedModels.removeWhere(
                                          (t) => t.tagId == tagModel.tagId,
                                        );
                                      } else if (_tempSelectedModels.length <
                                          2) {
                                        _tempSelectedModels.add(tagModel);
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
                ),
              ),

              PlusButton(
                label: "완료",
                showShadow: _showShadow, // 스크롤 상태 전달
                onPressed: isButtonEnabled
                    ? () {
                        widget.onCompleted(_tempSelectedModels);
                        Navigator.pop(context);
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
