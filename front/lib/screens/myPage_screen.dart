import 'package:flutter/material.dart';
import 'package:gachi_janchi/screens/test_screen.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text("마이페이지"),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TestScreen())
                );
              },
              child: const Text(
                "테스트 페이지",
                style: TextStyle(
                  color: Color.fromARGB(255, 41, 41, 41)
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}