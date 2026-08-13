// 최초 작성자: 김채영

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ai_coaching_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/core/theme/app_colors.dart';

// AI 코칭 카드 위젯
class AiCoachingCard extends StatefulWidget {
  final AiCoachingCardModel data;
  final VoidCallback? onComplete;
  final VoidCallback? onLineStart;

  const AiCoachingCard({
    super.key,
    required this.data,
    this.onComplete,
    this.onLineStart,
  });

  @override
  State<AiCoachingCard> createState() => _AiCoachingCardState();
}

class _AiCoachingCardState extends State<AiCoachingCard>
    with TickerProviderStateMixin {
  static const _typingSpeed = Duration(milliseconds: 35); // 글자당 타이핑 속도
  static const _bulletGap = Duration(milliseconds: 300); // 다음 줄로 넘어가기 전 텀

  late final AnimationController _cursorController; // 커서 깜빡임
  late final AnimationController _entranceController; // 카드 등장(페이드+슬라이드)
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  Timer? _typingTimer;
  Timer? _startTimer;

  int _bulletIndex = 0; // 현재 타이핑 중인 줄
  int _charCount = 0; // 현재 줄에서 보여줄 글자 수
  bool _started = false;

  @override
  void initState() {
    super.initState();

    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_fadeAnim);

    // 위젯이 생성되는 즉시 시작 (언제 생성할지는 부모가 결정)
    _entranceController.forward();
    _started = true;
    widget.onLineStart?.call();
    _typeNextChar();
  }

  // 한 글자씩 타이핑 → 줄 끝나면 다음 줄로 순차 진행
  void _typeNextChar() {
    final bullets = widget.data.bullets;
    if (_bulletIndex >= bullets.length) {
      // 모든 불릿 타이핑 완료 → 살짝 텀을 두고 다음 카드에게 알림
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) widget.onComplete?.call();
      });
      return;
    }

    final currentText = bullets[_bulletIndex];

    if (_charCount < currentText.length) {
      _typingTimer = Timer(_typingSpeed, () {
        if (!mounted) return;
        setState(() => _charCount++);
        _typeNextChar();
      });
    } else {
      _typingTimer = Timer(_bulletGap, () {
        if (!mounted) return;
        setState(() {
          _bulletIndex++;
          _charCount = 0;
        });
        widget.onLineStart?.call(); // 다음 줄 시작할 때마다 알림
        _typeNextChar();
      });
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _startTimer?.cancel();
    _cursorController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    const borderWidth = 4.0;
    const outerRadius = 12.0;
    const innerRadius = outerRadius - borderWidth;

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(borderWidth),
      decoration: ShapeDecoration(
        gradient: aiCoachingCardBorderGradient,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(outerRadius),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: appColors.whiteToBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(innerRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              emoji: widget.data.type.emoji,
              title: widget.data.title,
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < widget.data.bullets.length; i++) ...[
                  if (i != 0) const SizedBox(height: 20),
                  _buildBulletLine(i),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    // ✅ 카드 자체가 페이드인 + 아래에서 위로 슬라이드하며 등장
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(position: _slideAnim, child: card),
    );
  }

  // 인덱스별 불릿 줄 렌더링: 순서 전 → 숨김 / 타이핑 중 → 부분 텍스트+커서 / 완료 → 전체 텍스트
  Widget _buildBulletLine(int index) {
    final fullText = widget.data.bullets[index];

    if (!_started || index > _bulletIndex) {
      // 아직 차례가 안 된 줄: 레이아웃 높이는 유지하되 안 보이게 처리
      return Opacity(opacity: 0, child: _BulletText(text: fullText));
    }

    final isCurrentLine = index == _bulletIndex;
    final visibleText = isCurrentLine
        ? fullText.substring(0, _charCount.clamp(0, fullText.length))
        : fullText;
    final showCursor = isCurrentLine && _charCount < fullText.length;

    return _BulletText(
      text: visibleText,
      cursorAnimation: showCursor ? _cursorController : null,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String emoji;
  final String title;

  const _CardHeader({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '$emoji $title',
            style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
          ),
        ),
        const SizedBox(width: 8),
        SvgPicture.asset('assets/images/icons/ai_analysis_badge.svg'),
      ],
    );
  }
}

/// 불릿(•) + 본문 텍스트 한 줄
/// ✅ cursorAnimation이 주어지면, 텍스트 끝에 깜빡이는 커서를 함께 표시
class _BulletText extends StatelessWidget {
  final String text;
  final Animation<double>? cursorAnimation;

  const _BulletText({required this.text, this.cursorAnimation});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, right: 10),
          child: SizedBox(
            width: 4,
            height: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.b1.copyWith(color: appColors.blackToWhite),
              children: [
                TextSpan(text: text),
                if (cursorAnimation != null)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: FadeTransition(
                      opacity: cursorAnimation!,
                      child: Container(
                        width: 2,
                        height: 16,
                        margin: const EdgeInsets.only(left: 2),
                        color: appColors.primaryAble,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
