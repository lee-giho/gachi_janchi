import 'package:flutter/material.dart';
import 'package:gachi_janchi/screens/favorite_screen.dart';
import 'package:gachi_janchi/screens/home_screen.dart';
import 'package:gachi_janchi/screens/mypage_main_screen.dart';
import 'package:gachi_janchi/screens/ranking_collection_screen.dart';
import 'package:gachi_janchi/screens/visit_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> screens = [
      HomeScreen(
        changeTap: changeTab
      ),
      RankingCollectionScreen(),
      FavoriteScreen(),
      VisitScreen(),
      MyPageMainScreen()
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          changeTab(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.military_tech,
                size: 30,
              ),
              label: '랭킹'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.star,
                size: 30,
              ),
              label: '즐겨찾기'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.history,
                size: 30,
              ),
              label: '방문내역'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 30,
              ),
              label: '마이페이지'),
        ],
        selectedItemColor: Color.fromRGBO(138, 50, 50, 1),
        unselectedItemColor: Color.fromRGBO(31, 31, 31, 1),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
