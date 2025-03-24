import 'package:flutter/material.dart';

class DiscountCouponsScreen extends StatelessWidget {
  const DiscountCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("할인쿠폰")),
      body: const Center(
        child: Text("할인쿠폰 기능은 추후 추가 예정입니다.", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
