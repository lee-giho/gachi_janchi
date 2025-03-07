import 'package:flutter/material.dart';

class CollectedIngredientsScreen extends StatelessWidget {
  const CollectedIngredientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("모은재료")),
      body: const Center(
        child: Text("모은재료 기능은 추후 추가 예정입니다.", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
