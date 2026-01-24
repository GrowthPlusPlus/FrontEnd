// 최초 작성자: 김채영

import 'package:flutter/material.dart';
import 'features/challenge/create/challenge_create_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // theme:,
      home: ChallengeCreatePage(),
    );
    // MaterialApp
  }
}
