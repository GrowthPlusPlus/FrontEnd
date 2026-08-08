// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_switch.dart';
import '../../../notification/provider/push_notification_provider.dart';

// 푸시 알림 설정 화면
class PushNotificationSettingsScreen extends ConsumerStatefulWidget {
  const PushNotificationSettingsScreen({super.key});

  @override
  ConsumerState<PushNotificationSettingsScreen> createState() =>
      _PushNotificationSettingsScreenState();
}

class _PushNotificationSettingsScreenState
    extends ConsumerState<PushNotificationSettingsScreen> {
  // ── 시간 변환 헬퍼 ────────────────────────────────────────
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

  // ── 공통 시간 피커 ────────────────────────────────────────
  void _showTimePicker(
    AppColorsExtension appColors,
    BuildContext context,
    String currentDisplayTime,
    void Function(String serverTime) onConfirm,
  ) {
    final List<String> hours = List.generate(12, (i) => '${i + 1}시');
    String currentPeriod = currentDisplayTime.contains('오후') ? '오후' : '오전';
    String currentHour = currentDisplayTime.split(' ').last;
    int initialHourIndex = hours.indexOf(currentHour);
    if (initialHourIndex == -1) initialHourIndex = 8;

    showDialog(
      context: context,
      barrierColor: appColors.blackToWhite.withAlpha(100),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: appColors.whiteToBlack,
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildAnimatedPeriodSelector(
                    appColors,
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
                            color: appColors.gray4.withAlpha(100),
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
                      final serverTime = _convertToServerTime(
                        currentPeriod,
                        currentHour,
                      );
                      onConfirm(serverTime); // ✅ 콜백으로 처리
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: appColors.primaryAble,
                      minimumSize: const Size(double.infinity, 52),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '완료',
                      style: AppTypography.b1.copyWith(
                        color: appColors.primaryAble,
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
    AppColorsExtension appColors,
    String currentPeriod,
    Function(String) onPeriodChanged,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: appColors.gray4,
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
                    color: appColors.whiteToBlack,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: appColors.blackToWhite.withAlpha(20),
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
                            color: isSelected
                                ? appColors.blackToWhite
                                : appColors.gray2,
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

  Widget _buildWeeklyReminderSection(
    AppColorsExtension appColors,
    PushNotificationSettings settings,
    PushNotificationSettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타이틀 + 설명 (스위치 없음)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '실패 방지 리마인더',
                    style: AppTypography.b1.copyWith(
                      color: appColors.blackToWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '챌린지 실패를 방지하는 주간 리마인더 알림',
                    style: AppTypography.b2.copyWith(color: appColors.gray2),
                  ),
                ],
              ),
            ),
          ],
        ),
        // 시간 피커 드롭다운 (항상 표시)
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _showTimePicker(
            appColors,
            context,
            _convertToDisplayTime(settings.weeklyReminderTime),
            (serverTime) => notifier.updateWeeklyReminderTime(serverTime),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appColors.gray5,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _convertToDisplayTime(settings.weeklyReminderTime),
                  style: AppTypography.b2.copyWith(color: appColors.gray3),
                ),
                Opacity(
                  opacity: 0.5,
                  child: SvgPicture.asset(
                    'assets/images/icons/big_down_arrow.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      appColors.gray2,
                      BlendMode.srcIn,
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

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final settings = ref.watch(pushNotificationProvider);
    final notifier = ref.read(pushNotificationProvider.notifier);

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: AppBar(
        backgroundColor: appColors.whiteToBlack,
        elevation: 0,
        surfaceTintColor: appColors.whiteToBlack,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              appColors.blackToWhite,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '푸시 알림 설정',
          style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 전체 알림 ───────────────────────────────
              const SizedBox(height: 16),
              _buildSwitchRow(
                appColors,
                title: '전체 알림',
                subtitle: '모든 알림 받기',
                value: settings.allNotifications,
                onChanged: (val) => notifier.toggleAll(val),
                isMain: true,
              ),
              const SizedBox(height: 20),
              Divider(color: appColors.gray4, height: 1),
              const SizedBox(height: 20),

              // ── 소셜 섹션 ────────────────────────────────
              _buildSectionHeader('소셜', appColors),
              const SizedBox(height: 10),
              Column(
                spacing: 20,
                children: [
                  _buildSwitchRow(
                    appColors,
                    title: '내 글 좋아요',
                    subtitle: "내 게시물에 '좋아요' 반응이 올 때 알림",
                    value: settings.likeNotifications,
                    onChanged: (val) => notifier.toggleLikes(val),
                  ),
                  _buildSwitchRow(
                    appColors,
                    title: '댓글',
                    subtitle: '내 글에 새로운 댓글이 달릴 때 알림',
                    value: settings.commentNotifications,
                    onChanged: (val) => notifier.toggleComments(val),
                  ),
                  _buildSwitchRow(
                    appColors,
                    title: '친구 신청',
                    subtitle: '나에게 새로운 친구 요청이 도착할 때 알림',
                    value: settings.friendRequestNotifications,
                    onChanged: (val) => notifier.toggleFriend(val),
                  ),
                  _buildSwitchRow(
                    appColors,
                    title: '멤버 인증 소식 (전체)',
                    subtitle: '멤버 인증 알림 통합 관리',
                    value: settings.memberAuthNotifications,
                    onChanged: (val) => notifier.toggleMemberAuth(val),
                  ),
                ],
              ),
              const SizedBox(height: 42),

              // ── 챌린지 섹션 ──────────────────────────────
              _buildSectionHeader('챌린지', appColors),
              const SizedBox(height: 10),
              Column(
                spacing: 20,
                children: [
                  _buildSwitchRow(
                    appColors,
                    title: '챌린지 초대',
                    subtitle: '새로운 챌린지 참여 제안을 받았을 때 알림',
                    value: settings.challengeInviteNotifications,
                    onChanged: (val) => notifier.toggleChallengeInvite(val),
                  ),
                  _buildSwitchRow(
                    appColors,
                    title: '동기부여 메시지',
                    subtitle: '꾸준한 챌린지 참여를 돕는 응원 푸시 알림',
                    value: settings.motivationNotifications,
                    onChanged: (val) => notifier.toggleMotivation(val),
                  ),
                  // ── 일일 리마인더 (시간 피커 없음) ──────────────
                  _buildSwitchRow(
                    appColors,
                    title: '일일 리마인더 (전체)',
                    subtitle: '리마인더 알림 통합 관리',
                    value: settings.dailyReminder,
                    onChanged: (val) => notifier.toggleDailyReminder(val),
                  ),
                  // ── 실패 방지 리마인더 ─────────────────────
                  _buildWeeklyReminderSection(appColors, settings, notifier),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── 섹션 헤더 ────────────────────────────────────────────
  Widget _buildSectionHeader(String title, AppColorsExtension appColors) {
    return Text(
      title,
      style: AppTypography.b1.copyWith(color: appColors.gray1),
    );
  }

  // ── 스위치 행 ────────────────────────────────────────────
  Widget _buildSwitchRow(
    AppColorsExtension appColors, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isMain = false,
  }) {
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
                style: AppTypography.b1.copyWith(
                  color: appColors.blackToWhite,
                  fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.b2.copyWith(color: appColors.gray2),
              ),
            ],
          ),
        ),
        CustomSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
