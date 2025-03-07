import 'package:flutter/material.dart';

class VisitHistoryScreen extends StatelessWidget {
  const VisitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("방문내역")),
      body: const Center(
        child: Text("방문내역 기능은 추후 추가 예정입니다.", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
