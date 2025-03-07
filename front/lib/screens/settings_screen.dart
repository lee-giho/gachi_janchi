import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("설정")),
      body: const Center(
        child: Text("설정 기능은 추후 추가 예정입니다.", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
