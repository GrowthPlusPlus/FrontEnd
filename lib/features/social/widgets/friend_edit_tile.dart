// 최초 작성자: 정승빈

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../shared/models/user.dart';
import 'package:haenaem/shared/widgets/user_list_tile.dart';

class FriendEditTile extends StatelessWidget {
  final User user;
  final VoidCallback onDeleteTap;

  const FriendEditTile({
    super.key,
    required this.user,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    return UserListTile(
      user: user,
      trailing: IconButton(
        onPressed: onDeleteTap,
        icon: SvgPicture.asset(
          'assets/images/icons/big_trash_icon.svg',
          width: 24,
          colorFilter: ColorFilter.mode(
            appColors.notification,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
