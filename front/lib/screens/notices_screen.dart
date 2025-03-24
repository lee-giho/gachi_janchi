import 'package:flutter/material.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("공지사항")),
      body: const Center(
        child: Text("공지사항 기능은 추후 추가 예정입니다.", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
