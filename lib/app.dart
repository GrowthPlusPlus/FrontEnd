// 최초 작성자: 김채영

import 'package:flutter/material.dart';
import 'package:haenaem/features/social/social_screen.dart';
import 'features/challenge/create/screens/challenge_create_page.dart';
import 'features/user/my_page_screen.dart';
import 'features/main/screens/main_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // theme:,
      home: MyPageScreen(),
      //home: MainScreen(),
      //home: SocialScreen(),
    );
    // MaterialApp
  }
}
