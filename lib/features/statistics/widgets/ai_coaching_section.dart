// 최초 작성자: 김채영
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'ai_coaching_card.dart';
import '../data/ai_coaching_repository.dart';
import '../models/ai_coaching_data.dart';

// AI 코칭 섹션 위젯
class AiCoachingSection extends ConsumerWidget {
  const AiCoachingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final coachingAsync = ref.watch(aiCoachingRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: coachingAsync.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, stack) {
          // 디버그 콘솔에서 원인을 확인하기 위한 로그
          debugPrint('❌ AiCoaching 로드 실패: $e');
          if (e is DioException) {
            debugPrint('  - type: ${e.type}');
            debugPrint('  - message: ${e.message}');
            debugPrint('  - statusCode: ${e.response?.statusCode}');
            debugPrint('  - responseData: ${e.response?.data}');
            debugPrint('  - requestUrl: ${e.requestOptions.uri}');
          }
          debugPrint(stack.toString());
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '데이터를 불러오지 못했어요',
                    style: AppTypography.b2.copyWith(color: appColors.gray4),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref
                        .read(aiCoachingRepositoryProvider.notifier)
                        .refresh(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        },
        // ✅ 카드 순차 등장 로직은 별도 위젯으로 분리
        data: (cards) => _SequentialCoachingCards(cards: cards),
      ),
    );
  }
}

// 카드를 하나씩 순서대로(이전 카드 타이핑 완료 후 다음 카드 시작) 보여주는 위젯
class _SequentialCoachingCards extends StatefulWidget {
  final List<AiCoachingCardModel> cards;

  const _SequentialCoachingCards({required this.cards});

  @override
  State<_SequentialCoachingCards> createState() =>
      _SequentialCoachingCardsState();
}

class _SequentialCoachingCardsState extends State<_SequentialCoachingCards> {
  int _visibleCount = 0; // 처음엔 카드 0장 — 섹션이 보이기 전엔 아무것도 시작 안 함
  final List<GlobalKey> _cardKeys = [];
  final GlobalKey _sectionKey = GlobalKey();

  Timer? _visibilityPoller; // 섹션이 화면에 들어오는지 주기적으로 확인
  bool _hasStarted = false; // 최초 1회만 트리거되도록

  @override
  void initState() {
    super.initState();
    _ensureKeys();

    // 빌드 직후부터 짧은 주기로 "섹션이 화면에 보이기 시작했는지" 확인
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    _visibilityPoller = Timer.periodic(
      const Duration(milliseconds: 150),
      (_) => _checkVisibility(),
    );
  }

  @override
  void didUpdateWidget(covariant _SequentialCoachingCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards != widget.cards) {
      setState(() {
        _visibleCount = 0;
        _hasStarted = false;
      });
      _visibilityPoller ??= Timer.periodic(
        const Duration(milliseconds: 150),
        (_) => _checkVisibility(),
      );
    }
    _ensureKeys();
  }

  @override
  void dispose() {
    _visibilityPoller?.cancel();
    super.dispose();
  }

  void _ensureKeys() {
    while (_cardKeys.length < widget.cards.length) {
      _cardKeys.add(GlobalKey());
    }
  }

  bool _isSectionVisible() {
    final renderObject = _sectionKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return false;

    final screenHeight = MediaQuery.of(context).size.height;
    final position = renderObject.localToGlobal(Offset.zero);
    final sectionTop = position.dy;
    final sectionBottom = sectionTop + renderObject.size.height;

    return sectionBottom > 0 && sectionTop < screenHeight;
  }

  // 섹션이 처음 화면에 보이는 순간 감지 → 첫 카드 등장 + 타이핑 트리거
  void _checkVisibility() {
    if (_hasStarted || widget.cards.isEmpty) return;
    if (!_isSectionVisible()) return;

    _hasStarted = true;
    _visibilityPoller?.cancel();
    _visibilityPoller = null;

    setState(() => _visibleCount = 1); // 첫 카드 생성 → AiCoachingCard가 즉시 타이핑 시작
  }

  void _revealNextCard() {
    setState(() => _visibleCount++);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCardIfVisible(_visibleCount - 1);
    });
  }

  void _scrollToCardIfVisible(int index) {
    if (!_isSectionVisible()) return;
    if (index < 0 || index >= _cardKeys.length) return;

    final ctx = _cardKeys[index].currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      alignment: 0.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    final visible = _visibleCount.clamp(0, cards.length);
    final currentIndex = visible - 1;

    return Column(
      key: _sectionKey,
      children: [
        for (int i = 0; i < visible; i++) ...[
          if (i != 0) const SizedBox(height: 20),
          KeyedSubtree(
            key: _cardKeys[i],
            child: AiCoachingCard(
              data: cards[i],
              onLineStart: i == currentIndex
                  ? () => WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToCardIfVisible(i),
                    )
                  : null,
              onComplete: i == currentIndex && visible < cards.length
                  ? _revealNextCard
                  : null,
            ),
          ),
        ],
        // 아직 카드가 하나도 안 보일 때도 이 높이만큼은 자리를 차지해야
        // "섹션 위치"를 감지할 수 있음 (감지용 + 하단 여유 공간 겸용)
        const SizedBox(height: 150),
      ],
    );
  }
}
