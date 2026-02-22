// 최상위 화면 (TabBar와 TabBarView 포함)
import 'package:flutter/material.dart';
import 'package:haenaem/features/notification/views/challenge_invites_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../views/all_notifications_view.dart';

class NotificationMainScreen extends StatelessWidget {
  const NotificationMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭 개수
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('알림', style: AppTypography.h3),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryAble,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primaryAble,
            unselectedLabelColor: AppColors.gray2,
            labelStyle: AppTypography.b1,
            tabs: [
              Tab(text: '모두'),
              Tab(text: '챌린지 초대'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AllNotificationsView(), // '모두' 탭
            ChallengeInvitesView(), // '챌린지 초대' 탭
          ],
        ),
      ),
    );
  }
}
