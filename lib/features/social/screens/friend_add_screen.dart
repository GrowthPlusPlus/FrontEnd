// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

import '../views/user_search_view.dart';
import '../views/received_request_view.dart';
import '../views/sent_request_view.dart';

import 'package:haenaem/shared/widgets/custom_tab_bar.dart';

class FriendAddScreen extends StatelessWidget {
  final int initialTabIndex;

  const FriendAddScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: AppBar(
        backgroundColor: appColors.whiteToBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.blackToWhite),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('친구 추가', style: AppTypography.h2),
      ),
      body: CustomTabBar(
        initialIndex: initialTabIndex,
        tabs: const ['친구 신청', '받은 요청', '보낸 요청'],
        children: const [
          UserSearchView(),
          ReceivedRequestView(),
          SentRequestView(),
        ],
      ),
    );
  }
}
