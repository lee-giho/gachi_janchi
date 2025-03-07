import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("리뷰")),
      body: const Center(
        child: Text("리뷰 기능은 추후 추가 예정입니다.", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
