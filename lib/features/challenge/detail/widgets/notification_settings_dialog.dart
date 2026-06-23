// 최초 작성자 : 강선욱
// 수정: 김채영 (피그마 디자인 반영)
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/notification/data/challenge_notification_repository.dart';

class NotificationSettingsDialog extends ConsumerStatefulWidget {
  final int challengeId;

  const NotificationSettingsDialog({super.key, required this.challengeId});

  @override
  ConsumerState<NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends ConsumerState<NotificationSettingsDialog> {
  // ── 스위치 상태 ───────────────────────────────────────
  bool allNotifications = false;
  bool dailyReminder = false;
  bool likesNotification = false;
  bool commentsNotification = false;
  bool mateVerification = false;
  String selectedTime = '오후 9시';
  bool _isLoading = true;

  // ── 전역 설정에 의해 비활성화된 항목 ────────────────────
  bool _reminderDisabledByGlobal = false;
  bool _likesDisabledByGlobal = false;
  bool _commentsDisabledByGlobal = false;
  bool _verificationDisabledByGlobal = false;

  @override
  void initState() {
    super.initState();
    _loadChallengeSettings();
  }

  // ── 초기 로드 ─────────────────────────────────────────

  Future<void> _loadChallengeSettings() async {
    try {
      final dto = await ref
          .read(challengeNotificationRepositoryProvider)
          .getChallengeNotificationSettings(widget.challengeId);

      // 🔔 임시 로그
      debugPrint(
        '===== 🔔 챌린지 알림 설정 조회 결과 (challengeId: ${widget.challengeId}) =====',
      );
      debugPrint('🔔 전체 알림: ${dto.challengeAllPushEnabled}');
      debugPrint('🔔 일일 리마인더: ${dto.dailyReminderPushEnabled}');
      debugPrint('🔔 일일 리마인더 시간: ${dto.dailyReminderTime}');
      debugPrint(
        '🔔 일일 리마인더 전역 차단: ${dto.dailyReminderDisabledByGlobalSetting}',
      );
      debugPrint('🔔 좋아요: ${dto.likesPushEnabled}');
      debugPrint('🔔 좋아요 전역 차단: ${dto.likesDisabledByGlobalSetting}');
      debugPrint('🔔 댓글: ${dto.commentsPushEnabled}');
      debugPrint('🔔 댓글 전역 차단: ${dto.commentsDisabledByGlobalSetting}');
      debugPrint('🔔 멤버 인증: ${dto.memberCertificationPushEnabled}');
      debugPrint(
        '🔔 멤버 인증 전역 차단: ${dto.memberCertificationDisabledByGlobalSetting}',
      );
      debugPrint(
        '=================================================================',
      );

      setState(() {
        allNotifications = dto.challengeAllPushEnabled;
        dailyReminder = dto.dailyReminderPushEnabled;
        likesNotification = dto.likesPushEnabled;
        commentsNotification = dto.commentsPushEnabled;
        mateVerification = dto.memberCertificationPushEnabled;
        selectedTime = _convertToDisplayTime(dto.dailyReminderTime);

        _reminderDisabledByGlobal = dto.dailyReminderDisabledByGlobalSetting;
        _likesDisabledByGlobal = dto.likesDisabledByGlobalSetting;
        _commentsDisabledByGlobal = dto.commentsDisabledByGlobalSetting;
        _verificationDisabledByGlobal =
            dto.memberCertificationDisabledByGlobalSetting;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('챌린지 알림 설정 로드 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  // ── 시간 변환 헬퍼 ────────────────────────────────────

  String _convertToDisplayTime(String serverTime) {
    final hour = int.parse(serverTime.split(':')[0]);
    if (hour == 0) return '오전 12시';
    if (hour < 12) return '오전 $hour시';
    if (hour == 12) return '오후 12시';
    return '오후 ${hour - 12}시';
  }

  String _convertToServerTime(String period, String hourStr) {
    int hour = int.parse(hourStr.replaceAll('시', ''));
    if (period == '오후' && hour != 12) hour += 12;
    if (period == '오전' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  // ── 전체 알림 동기화 헬퍼 ────────────────────────────

  void _syncAllNotifications() {
    allNotifications =
        dailyReminder &&
        likesNotification &&
        commentsNotification &&
        mateVerification;
  }

  // ── 토글 핸들러 ───────────────────────────────────────

  Future<void> _toggleAll(bool val) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final success = await ref
        .read(challengeNotificationRepositoryProvider)
        .setChallengeAllNotification(widget.challengeId, val);

    if (success) {
      setState(() {
        allNotifications = val;
        dailyReminder = val;
        likesNotification = val;
        commentsNotification = val;
        mateVerification = val;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleReminder(bool val) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final success = await ref
        .read(challengeNotificationRepositoryProvider)
        .setChallengeReminderNotification(widget.challengeId, val);

    if (success) {
      setState(() {
        dailyReminder = val;
        _syncAllNotifications();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleLikes(bool val) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final success = await ref
        .read(challengeNotificationRepositoryProvider)
        .setChallengeLikesNotification(widget.challengeId, val);

    if (success) {
      setState(() {
        likesNotification = val;
        _syncAllNotifications();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleComments(bool val) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final success = await ref
        .read(challengeNotificationRepositoryProvider)
        .setChallengeCommentsNotification(widget.challengeId, val);

    if (success) {
      setState(() {
        commentsNotification = val;
        _syncAllNotifications();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleVerification(bool val) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final success = await ref
        .read(challengeNotificationRepositoryProvider)
        .setChallengeVerificationNotification(widget.challengeId, val);

    if (success) {
      setState(() {
        mateVerification = val;
        _syncAllNotifications();
      });
    }
    setState(() => _isLoading = false);
  }

  // ── UI ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 헤더 ─────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(width: 1, color: AppColors.gray4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '챌린지 알림 설정',
                  style: AppTypography.h3.copyWith(color: AppColors.black),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      'assets/images/icons/close_icon.svg',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 본문 ─────────────────────────────────────
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAble,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    spacing: 20,
                    children: [
                      _buildSwitchRow(
                        '전체 알림',
                        '모든 알림 받기',
                        allNotifications,
                        _toggleAll,
                      ),
                      _buildDailyReminderSection(),
                      _buildSwitchRowWithGlobalWarning(
                        '내 글 좋아요',
                        "내 게시물에 '좋아요' 반응이 올 때 알림",
                        likesNotification,
                        _likesDisabledByGlobal ? null : _toggleLikes,
                        disabledByGlobal: _likesDisabledByGlobal,
                      ),
                      _buildSwitchRowWithGlobalWarning(
                        '댓글',
                        '내 글에 새로운 댓글이 달릴 때 알림',
                        commentsNotification,
                        _commentsDisabledByGlobal ? null : _toggleComments,
                        disabledByGlobal: _commentsDisabledByGlobal,
                      ),
                      _buildSwitchRowWithGlobalWarning(
                        '멤버 인증 소식',
                        '다른 참여자들이 인증 완료 시 알림',
                        mateVerification,
                        _verificationDisabledByGlobal
                            ? null
                            : _toggleVerification,
                        disabledByGlobal: _verificationDisabledByGlobal,
                      ),
                    ],
                  ),
                ),

          // ── 완료 버튼 ─────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(width: 1, color: AppColors.gray4)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAble,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '완료',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 기본 스위치 행 ──────────────────────────────────────

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool>? onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.b1.copyWith(color: AppColors.black),
              ),
              Text(
                subtitle,
                style: AppTypography.b2.copyWith(color: AppColors.gray2),
              ),
            ],
          ),
        ),
        _buildSwitch(value, onChanged),
      ],
    );
  }

  // ── 전역 비활성화 안내 문구 포함 스위치 행 ──────────────

  Widget _buildSwitchRowWithGlobalWarning(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool>? onChanged, {
    bool disabledByGlobal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.b1.copyWith(
                      color: disabledByGlobal
                          ? AppColors.gray2
                          : AppColors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.b2.copyWith(color: AppColors.gray2),
                  ),
                ],
              ),
            ),
            _buildSwitch(
              value,
              (_isLoading || disabledByGlobal) ? null : onChanged,
            ),
          ],
        ),
        if (disabledByGlobal)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '전체 푸시 알림 설정에서 해당 알림이 꺼져 있습니다.',
              style: AppTypography.c1.copyWith(color: AppColors.primaryAble),
            ),
          ),
      ],
    );
  }

  // ── 공통 스위치 위젯 ────────────────────────────────────

  Widget _buildSwitch(bool value, ValueChanged<bool>? onChanged) {
    return Transform.scale(
      scale: 0.8,
      alignment: Alignment.centerRight,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primaryAble,
        activeThumbColor: Colors.white,
        inactiveTrackColor: AppColors.disable,
        inactiveThumbColor: Colors.white,
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: WidgetStateProperty.all(const Icon(null)),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
    );
  }

  // ── 일일 리마인더 섹션 ──────────────────────────────────

  Widget _buildDailyReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '일일 리마인더',
                    style: AppTypography.b1.copyWith(
                      color: _reminderDisabledByGlobal
                          ? AppColors.gray2
                          : AppColors.black,
                    ),
                  ),
                  Text(
                    '매일 $selectedTime 알림',
                    style: AppTypography.b2.copyWith(color: AppColors.gray2),
                  ),
                ],
              ),
            ),
            _buildSwitch(
              dailyReminder,
              (_isLoading || _reminderDisabledByGlobal)
                  ? null
                  : _toggleReminder,
            ),
          ],
        ),
        if (dailyReminder && !_reminderDisabledByGlobal) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _showTimePicker(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedTime,
                    style: AppTypography.b2.copyWith(color: AppColors.gray3),
                  ),
                  Opacity(
                    opacity: 0.5,
                    child: SvgPicture.asset(
                      'assets/images/icons/big_down_arrow.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.gray2,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_reminderDisabledByGlobal)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '전체 푸시 알림 설정에서 해당 알림이 꺼져 있습니다.',
              style: AppTypography.c1.copyWith(color: AppColors.primaryAble),
            ),
          ),
      ],
    );
  }

  // ── 시간 피커 ───────────────────────────────────────────

  void _showTimePicker(BuildContext context) {
    final List<String> hours = List.generate(12, (i) => '${i + 1}시');
    String currentPeriod = selectedTime.contains('오후') ? '오후' : '오전';
    String currentHour = selectedTime.split(' ').last;
    int initialHourIndex = hours.indexOf(currentHour);
    if (initialHourIndex == -1) initialHourIndex = 8;

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(100),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildAnimatedPeriodSelector(
                    currentPeriod,
                    (newPeriod) =>
                        setDialogState(() => currentPeriod = newPeriod),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.gray4.withAlpha(100),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: initialHourIndex,
                        ),
                        onSelectedItemChanged: (index) =>
                            setDialogState(() => currentHour = hours[index]),
                        selectionOverlay: const SizedBox.shrink(),
                        children: hours
                            .map(
                              (h) => Center(
                                child: Text(h, style: AppTypography.b1),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: TextButton(
                    onPressed: () {
                      final newTime = '$currentPeriod $currentHour';
                      final serverTime = _convertToServerTime(
                        currentPeriod,
                        currentHour,
                      );
                      setState(() => selectedTime = newTime);
                      // TODO: 챌린지별 리마인더 시간 변경 API 생기면 연동
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.primaryAble,
                      minimumSize: const Size(double.infinity, 52),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '완료',
                      style: AppTypography.b1.copyWith(
                        color: AppColors.primaryAble,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPeriodSelector(
    String currentPeriod,
    Function(String) onPeriodChanged,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.gray4,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: currentPeriod == '오전'
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: width - 4,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: ['오전', '오후'].map((p) {
                  final bool isSelected = currentPeriod == p;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onPeriodChanged(p),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: AppTypography.b2.copyWith(
                            color: isSelected ? Colors.black : AppColors.gray2,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          child: Text(p),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
