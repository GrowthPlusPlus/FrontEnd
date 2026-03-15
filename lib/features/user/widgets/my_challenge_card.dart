// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../challenge/models/challenge_model.dart';

class MyChallengeCard extends StatelessWidget {
  final ChallengeInProgressModel item;

  const MyChallengeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final serverStatus = item.status.toUpperCase();

    if (serverStatus == "FAIL" || serverStatus == "FAILED") {
      return _buildCard(
        statusText: '실패',
        themeColor: AppColors.notification,
        dateLabel: '실패일',
        duringLabel: '최대',
        showBorder: true,
      );
    }

    if (serverStatus == "SUCCESS") {
      return _buildCard(
        statusText: '완료',
        themeColor: AppColors.primaryAble,
        dateLabel: '완료일',
        duringLabel: '총',
        showBorder: true,
      );
    }

    // 기본: 진행중
    return _buildCard(
      statusText: '진행중',
      themeColor: AppColors.blue,
      dateLabel: '',
      duringLabel: '',
      showBorder: false,
    );
  }

  // 통합된 카드 빌더 (상태에 따라 컬러와 텍스트만 바뀜)
  Widget _buildCard({
    required String statusText,
    required Color themeColor,
    required String dateLabel,
    required String duringLabel,
    required bool showBorder,
  }) {
    final bool isInProgress = statusText == '진행중';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: showBorder
            ? Border.all(color: AppColors.gray5, width: 0.69)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: AppTypography.b3.copyWith(
                              color: AppColors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 7.35),
                        _buildStatusBadge(statusText, themeColor),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // 날짜 정보
                    Text(
                      isInProgress
                          ? item.dateInfo
                          : '$dateLabel ${item.endDate.replaceAll('-', '/')}',
                      style: AppTypography.b2.copyWith(color: AppColors.gray2),
                    ),
                    if (!isInProgress) const SizedBox(height: 2),
                    // 불 아이콘 및 기간 정보 (완료/실패 시에만 아래로 내려감, 진행중은 _buildInfoRow에서 처리)
                    if (!isInProgress)
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/icons/small_fire_icon.svg',
                            width: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$duringLabel ${item.duringDate}일',
                            style: AppTypography.b2.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              _buildProgressText(item.progress, themeColor),
            ],
          ),
          const SizedBox(height: 8),
          if (isInProgress) _buildInProgressInfoRow(item),
          if (isInProgress) const SizedBox(height: 8),
          _buildGaugeBar(item.progress, themeColor),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: AppTypography.c1.copyWith(color: color)),
    );
  }

  Widget _buildProgressText(double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${(progress * 100).toInt()}%',
          style: AppTypography.h2.copyWith(color: color),
        ),
        Text('달성률', style: AppTypography.c1.copyWith(color: AppColors.gray2)),
      ],
    );
  }

  Widget _buildInProgressInfoRow(ChallengeInProgressModel item) {
    return Row(
      children: [
        SvgPicture.asset('assets/images/icons/small_fire_icon.svg', width: 16),
        const SizedBox(width: 4),
        Text(
          '${item.duringDate}일째',
          style: AppTypography.b2.copyWith(color: AppColors.black),
        ),
        const SizedBox(width: 12),
        SvgPicture.asset(
          'assets/images/icons/mini_success_icon.svg',
          width: 16,
        ),
        const SizedBox(width: 4),
        Text(
          item.countInfo,
          style: AppTypography.b2.copyWith(color: AppColors.black),
        ),
      ],
    );
  }

  Widget _buildGaugeBar(double progress, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 4,
        backgroundColor: AppColors.gray5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
