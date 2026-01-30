// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';

class ExploreFeedView extends StatelessWidget {
  final ScrollController scrollController;
  const ExploreFeedView({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('둘러보기 피드 화면'));
  }
}
