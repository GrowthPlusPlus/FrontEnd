// 최초 작성자: 정승빈

import 'package:flutter/material.dart';

import '../../../shared/models/user.dart';
import 'package:haenaem/shared/widgets/user_list_tile.dart';

class FriendListTile extends StatelessWidget {
  final User user;

  const FriendListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return UserListTile(user: user);
  }
}
