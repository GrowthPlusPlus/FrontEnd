// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

import '../views/user_search_view.dart';
import '../views/received_request_view.dart';
import '../views/sent_request_view.dart';

class FriendAddScreen extends StatelessWidget {
  final int initialTabIndex;

  const FriendAddScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex, // 초기 탭 인덱스 설정
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text('친구 추가', style: AppTypography.h2),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: TabBar(
              indicatorColor: AppColors.primaryAble,
              labelColor: AppColors.primaryAble,
              unselectedLabelColor: AppColors.gray2,
              labelStyle: AppTypography.b1.copyWith(
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: '친구 신청'),
                Tab(text: '받은 요청'),
                Tab(text: '보낸 요청'),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            UserSearchView(),
            ReceivedRequestView(),
            SentRequestView(),
          ],
        ),
      ),
    );
  }
}
