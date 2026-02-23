// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/features/home/home_screen.dart';
import 'package:haenaem/features/social/social_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:haenaem/features/user/screens/my_page_screen.dart';
import 'package:haenaem/features/feed/screens/feed_screen.dart';

// 내비게이션 바를 넣은 화면
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 하단 바를 통해 전환될 화면 리스트
  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("통계 화면")),
    const FeedScreen(),
    const SocialScreen(),
    const MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      // 분리한 하단 바 위젯 호출
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
