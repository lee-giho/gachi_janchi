import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: const Center(
        child: Text('깃 브랜치 테스트 로그인 성공! 홈 화면입니다.', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
